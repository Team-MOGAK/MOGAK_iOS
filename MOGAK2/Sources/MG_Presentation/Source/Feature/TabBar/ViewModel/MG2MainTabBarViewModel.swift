struct MG2TabItem {
    let title: String
    let imageName: String
    let selectedImageName: String
}

final class MG2MainTabBarViewModel {
    init() {}

    var items: [MG2TabItem] {
        [
            MG2TabItem(title: "조각시작", imageName: "start", selectedImageName: "selectedStart"),
            MG2TabItem(title: "모다라트", imageName: "modalArt", selectedImageName: "selectedModalArt"),
            MG2TabItem(title: "마이페이지", imageName: "mypage", selectedImageName: "selectedMypage")
        ]
    }
}
