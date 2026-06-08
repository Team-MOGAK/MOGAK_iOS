import UIKit

struct MG2TabItem {
    let title: String
    let image: UIImage?
    let selectedImage: UIImage?
}

@MainActor
final class MG2MainTabBarViewModel {
    init() {}

    var items: [MG2TabItem] {
        [
            MG2TabItem(title: "조각시작", image: UIImage(named: "start"), selectedImage: UIImage(named: "selectedStart")),
            MG2TabItem(title: "모다라트", image: UIImage(named: "modalArt"), selectedImage: UIImage(named: "selectedModalArt")),
            MG2TabItem(title: "마이페이지", image: UIImage(named: "mypage"), selectedImage: UIImage(named: "selectedMypage"))
        ]
    }
}
