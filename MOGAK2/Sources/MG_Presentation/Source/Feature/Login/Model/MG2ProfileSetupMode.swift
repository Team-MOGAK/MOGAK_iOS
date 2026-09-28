/// 회원가입 화면들이 차례로 채워 가는 입력값. 화면을 넘어갈 때 Coordinator가 다음 화면으로 넘긴다.
struct MG2RegistrationDraft {
    var consents = [MG2ConsentAgreement]()
    var nickname = ""
    var profileImageID: Int?
    var job = ""
}

/// 닉네임·직무 화면은 회원가입과 마이페이지 수정에 함께 쓰인다.
enum MG2ProfileSetupMode {
    case registration(MG2RegistrationDraft)
    case editing
}

enum MG2ProfileSetupResult {
    case continueRegistration(MG2RegistrationDraft)
    case profileUpdated
}
