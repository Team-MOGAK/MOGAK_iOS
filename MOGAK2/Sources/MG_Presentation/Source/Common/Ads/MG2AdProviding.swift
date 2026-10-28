import UIKit

/// 광고 SDK를 화면에서 숨기는 경계. 구현은 MG_App(AdMob). 언제 띄울지는 AdPolicyUseCase가 정하고,
/// Coordinator만 이 프로토콜을 써서 광고를 띄운다.
@MainActor
protocol MG2AdProviding: AnyObject {
    /// 마이페이지 맨 아래(스크롤 안) 적응형 배너.
    func makeBanner(width: CGFloat, rootViewController: UIViewController) -> UIView
    /// 홈 목록 끝 네이티브 광고 카드. 못 불러오면 nil(자리째 숨김).
    func loadNativeAd(rootViewController: UIViewController, completion: @escaping (UIView?) -> Void)
    func presentInterstitial(from viewController: UIViewController, completion: @escaping (Bool) -> Void)
    /// 끝까지 보면 true.
    func presentRewarded(from viewController: UIViewController, completion: @escaping (Bool) -> Void)
}
