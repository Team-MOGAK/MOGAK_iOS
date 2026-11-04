import Foundation

final class ModalartUseCase {
    /// 제목을 정하기 전 기본 모다라트의 색
    private static let defaultModalartColor = "BFC3D4"

    private let repository: ModalartRepository
    /// 조각 상세 API는 조각 저장소에 있다.
    private let jogakRepository: ScheduleStartRepository

    init(repository: ModalartRepository, jogakRepository: ScheduleStartRepository) {
        self.repository = repository
        self.jogakRepository = jogakRepository
    }

    /// 모다라트 목록. 하나도 없으면 기본 모다라트를 만들어 돌려준다.
    func loadModalarts() async throws -> [MG2ModalartListItemEntity] {
        let modalarts = try await repository.getModalartList()
        guard modalarts.isEmpty else { return modalarts }
        return [try await createDefaultModalart(existing: [])]
    }

    /// "내 모다라트N" 제목으로 새 모다라트를 만든다. N은 이미 쓴 번호 다음.
    func createDefaultModalart(existing: [MG2ModalartListItemEntity]) async throws -> MG2ModalartListItemEntity {
        let created = try await repository.createModalart(title: MG2ModalartDefaultTitle.next(after: existing.map(\.title)), color: Self.defaultModalartColor)
        return MG2ModalartListItemEntity(id: created.id, title: created.title, color: created.color)
    }

    func getModalartDetail(modalartId: Int) async throws -> MG2ModalartDetailEntity? {
        try await repository.getModalartDetail(modalartId: modalartId)
    }

    func getModalartMogaks(modalartId: Int) async throws -> [MG2ModalartMogakItemEntity] {
        try await repository.getModalartMogaks(modalartId: modalartId)
    }

    /// 모각의 조각 전체. 판 칸 순서가 바뀌지 않게 만든 순서로 둔다.
    func getMogakJogaks(mogakId: Int) async throws -> [MG2MogakJogakEntity] {
        try await repository.getMogakJogaks(mogakId: mogakId).sorted { $0.jogakID < $1.jogakID }
    }

    /// 81칸 전체 보기: 모각마다 조각 이름(모각 상세와 같은 순서). 모각마다 한 번씩 차례로 불러온다.
    func loadJogakTitles(for mogaks: [MG2ModalartMogakItemEntity]) async throws -> [Int: [String]] {
        var titlesByMogakID = [Int: [String]]()
        for mogak in mogaks {
            titlesByMogakID[mogak.mogakId] = try await getMogakJogaks(mogakId: mogak.mogakId).map(\.title)
        }
        return titlesByMogakID
    }

    func getWeeklyProgress(modalartId: Int, date: Date) async throws -> MG2WeeklyProgress {
        try await repository.getWeeklyProgress(modalartId: modalartId, date: date)
    }

    func getJogakDetail(jogakId: Int) async throws -> MG2JogakDetailEntity {
        try await jogakRepository.getJogakDetail(jogakId: jogakId)
    }

    func editModalart(id: Int, title: String, color: String) async throws -> MG2ModalartUpsertEntity {
        try await repository.editModalart(id: id, title: title, color: color)
    }

    func deleteModalart(id: Int) async throws {
        try await repository.deleteModalart(id: id)
    }

    func deleteMogak(mogakId: Int) async throws {
        try await repository.deleteMogak(mogakId: mogakId)
    }

    func deleteJogak(jogakId: Int) async throws {
        try await repository.deleteJogak(jogakId: jogakId)
    }
}
