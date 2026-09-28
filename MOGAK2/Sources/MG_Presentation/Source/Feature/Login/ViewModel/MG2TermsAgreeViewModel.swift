import Foundation

struct MG2AgreementSelection {
    let item: MG2ConsentItemEntity
    var agreed = false
}

struct MG2AgreementState {
    var selections = [MG2AgreementSelection]()
    var hasLoaded = false

    var hasAcceptedRequiredTerms: Bool {
        hasLoaded && selections.allSatisfy { !$0.item.required || $0.agreed }
    }

    var hasAcceptedAllTerms: Bool {
        hasLoaded && !selections.isEmpty && selections.allSatisfy(\.agreed)
    }
}

@MainActor
final class MG2TermsAgreeViewModel {
    private let userUseCase: UserUseCase
    private(set) var agreements = MG2AgreementState()

    init(userUseCase: UserUseCase) {
        self.userUseCase = userUseCase
    }

    var draft: MG2RegistrationDraft {
        MG2RegistrationDraft(consents: agreements.selections.map { MG2ConsentAgreement(consentItemId: $0.item.id, agreed: $0.agreed) })
    }

    func loadConsentItems(completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                let items = try await userUseCase.getConsentItems()
                agreements = MG2AgreementState(selections: items.map { MG2AgreementSelection(item: $0) }, hasLoaded: true)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func toggleAllAgreements() {
        let newValue = !agreements.hasAcceptedAllTerms
        for index in agreements.selections.indices {
            agreements.selections[index].agreed = newValue
        }
    }

    func toggleAgreement(id: Int) {
        guard let index = agreements.selections.firstIndex(where: { $0.item.id == id }) else { return }
        agreements.selections[index].agreed.toggle()
    }
}
