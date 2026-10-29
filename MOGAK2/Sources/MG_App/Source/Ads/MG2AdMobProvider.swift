import AppTrackingTransparency
import GoogleMobileAds
import SnapKit
import UIKit
import UserMessagingPlatform

/// AdMob 어댑터. 지금은 Google 테스트 광고 단위만 쓴다.
@MainActor
final class MG2AdMobProvider: NSObject, MG2AdProviding {
    // TODO(ads): 출시 전 실제 광고 단위 ID와 Info.plist GADApplicationIdentifier로 바꾸기.
    private enum UnitID {
        static let banner = "ca-app-pub-3940256099942544/2435281174"
        static let native = "ca-app-pub-3940256099942544/3986624511"
        static let interstitial = "ca-app-pub-3940256099942544/4411468910"
        static let rewarded = "ca-app-pub-3940256099942544/1712485313"
        static let appOpen = "ca-app-pub-3940256099942544/5575463023"
    }

    private var isStarted = false
    private var nativeLoader: GADAdLoader?
    private var nativeCompletion: ((UIView?) -> Void)?
    private var fullScreenCompletion: ((Bool) -> Void)?
    private var earnedReward = false
    private var presentedAd: AnyObject?

    /// 추적 허용(ATT) → 동의(UMP) → SDK 시작. 첫 화면이 뜬 뒤 한 번만.
    func start() {
        guard !isStarted else { return }
        // 추적 허용 창은 앱이 활성일 때만 뜬다. 알림 권한 창이 막 닫혀 아직 비활성이면 다음 활성화 때 다시 불린다.
        guard UIApplication.shared.applicationState == .active else { return }
        isStarted = true
        Task { @MainActor in
            _ = await ATTrackingManager.requestTrackingAuthorization()
            try? await UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: UMPRequestParameters())
            try? await UMPConsentForm.loadAndPresentIfRequired(from: nil)
            _ = await GADMobileAds.sharedInstance().start()
        }
    }

    /// `.md-banner`: 60 이상 · 모서리 12 · 안쪽 0 12 · 간격 10. 왼쪽에 ‘광고’, 오른쪽에 광고. 표시를 광고 위에 덮지 않는다.
    func makeBanner(width: CGFloat, rootViewController: UIViewController) -> UIView {
        let badge = MG2AdBadgeLabel()
        let adWidth = width - 12 * 2 - 10 - badge.intrinsicContentSize.width
        let banner = GADBannerView(adSize: GADCurrentOrientationInlineAdaptiveBannerAdSizeWithWidth(adWidth))
        banner.adUnitID = UnitID.banner
        banner.rootViewController = rootViewController
        banner.load(GADRequest())

        let container = UIView()
        container.backgroundColor = DS.Color.surface
        container.roundCorners(12)
        container.clipsToBounds = true
        container.layer.borderWidth = 1
        container.layer.borderColor = DS.Color.track.cgColor
        container.addSubviews(badge, banner)
        container.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(60)
            $0.height.equalTo(60).priority(.low)
        }
        badge.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
        }
        banner.snp.makeConstraints {
            $0.leading.equalTo(badge.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.top.greaterThanOrEqualToSuperview()
        }
        return container
    }

    func loadNativeAd(rootViewController: UIViewController, completion: @escaping (UIView?) -> Void) {
        nativeCompletion = completion
        let loader = GADAdLoader(adUnitID: UnitID.native, rootViewController: rootViewController, adTypes: [.native], options: nil)
        loader.delegate = self
        nativeLoader = loader
        loader.load(GADRequest())
    }

    func presentInterstitial(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        GADInterstitialAd.load(withAdUnitID: UnitID.interstitial, request: GADRequest()) { [weak self] ad, _ in
            Task { @MainActor in
                guard let self, let ad else { return completion(false) }
                self.present(ad, completion: completion) { ad.present(fromRootViewController: viewController) }
            }
        }
    }

    func presentRewarded(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        GADRewardedAd.load(withAdUnitID: UnitID.rewarded, request: GADRequest()) { [weak self] ad, _ in
            Task { @MainActor in
                guard let self, let ad else { return completion(false) }
                self.earnedReward = false
                self.present(ad, completion: completion) {
                    ad.present(fromRootViewController: viewController) { [weak self] in self?.earnedReward = true }
                }
            }
        }
    }

    /// 불러오는 사이 다른 화면으로 옮겼을 수 있으니 띄우기 직전에 `isAllowed`를 다시 확인한다.
    func presentAppOpen(from viewController: UIViewController, isAllowed: @escaping () -> Bool, completion: @escaping (Bool) -> Void) {
        GADAppOpenAd.load(withAdUnitID: UnitID.appOpen, request: GADRequest()) { [weak self] ad, _ in
            Task { @MainActor in
                guard let self, let ad, isAllowed(), viewController.presentedViewController == nil else { return completion(false) }
                self.present(ad, completion: completion) { ad.present(fromRootViewController: viewController) }
            }
        }
    }

    private func present(_ ad: GADFullScreenPresentingAd & AnyObject, completion: @escaping (Bool) -> Void, show: () -> Void) {
        ad.fullScreenContentDelegate = self
        presentedAd = ad
        fullScreenCompletion = completion
        show()
    }

    private func finishFullScreen(shown: Bool) {
        let completion = fullScreenCompletion
        let result = presentedAd is GADRewardedAd ? earnedReward : shown
        fullScreenCompletion = nil
        presentedAd = nil
        completion?(result)
    }
}

extension MG2AdMobProvider: GADFullScreenContentDelegate {
    nonisolated func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        Task { @MainActor in self.finishFullScreen(shown: true) }
    }

    nonisolated func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Task { @MainActor in self.finishFullScreen(shown: false) }
    }
}

extension MG2AdMobProvider: GADNativeAdLoaderDelegate {
    nonisolated func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        Task { @MainActor in
            self.nativeCompletion?(MG2NativeAdCardView(nativeAd: nativeAd))
            self.nativeCompletion = nil
        }
    }

    nonisolated func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        Task { @MainActor in
            self.nativeCompletion?(nil)
            self.nativeCompletion = nil
        }
    }
}

/// 홈 목록 끝 네이티브 광고 카드 (`.md-native`): 안쪽 12 14 14 · 간격 10 · 모서리 20.
/// 위 18pt 줄에 ‘광고’, 아이콘 48 옆 제목 15/700 · 본문 13/500 (가운데 정렬, 잘리지 않게 여러 줄), 아래 40pt 회색 CTA.
/// CTA는 앱 주 버튼과 다른 회색, AdChoices는 SDK가 모서리에 그린다.
private final class MG2NativeAdCardView: GADNativeAdView {
    init(nativeAd: GADNativeAd) {
        super.init(frame: .zero)
        backgroundColor = DS.Color.surface
        roundCorners(DS.Radius.row)
        layer.borderWidth = 1
        layer.borderColor = DS.Color.track.cgColor

        let badge = MG2AdBadgeLabel()
        let icon = UIImageView(image: nativeAd.icon?.image)
        icon.roundCorners(12)
        icon.clipsToBounds = true
        icon.backgroundColor = DS.Color.fill
        let headline = UILabel()
        headline.apply(.subhead)
        headline.numberOfLines = 0
        headline.text = nativeAd.headline
        let body = UILabel()
        body.apply(.footnote, color: DS.Color.sub)
        body.numberOfLines = 0
        body.text = nativeAd.body
        body.isHidden = nativeAd.body == nil
        let texts = UIStackView(arrangedSubviews: [headline, body])
        texts.axis = .vertical
        texts.spacing = 2
        let row = UIStackView(arrangedSubviews: [icon, texts])
        row.alignment = .center
        row.spacing = 12
        let cta = UIButton(type: .system)
        cta.setTitle(nativeAd.callToAction, for: .normal)
        cta.setTitleColor(DS.Color.ink, for: .normal)
        cta.titleLabel?.font = .scaledCapped(.pretendard(.bold, size: 14), relativeTo: .subheadline)
        cta.titleLabel?.adjustsFontForContentSizeCategory = true
        cta.titleLabel?.adjustsFontSizeToFitWidth = true
        cta.titleLabel?.minimumScaleFactor = 0.8
        cta.backgroundColor = DS.Color.fill
        cta.roundCorners(12)
        cta.isUserInteractionEnabled = false

        addSubviews(badge, row, cta)
        badge.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.equalToSuperview().inset(14)
        }
        icon.snp.makeConstraints { $0.size.equalTo(48) }
        row.snp.makeConstraints {
            $0.top.equalTo(badge.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(14)
        }
        // 14pt는 accessibility1에서도 줄 높이 약 30이라 40 안에 들어간다.
        cta.snp.makeConstraints {
            $0.top.equalTo(row.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview().inset(14)
            $0.height.equalTo(40)
        }

        headlineView = headline
        bodyView = body
        iconView = icon
        callToActionView = cta
        self.nativeAd = nativeAd
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
