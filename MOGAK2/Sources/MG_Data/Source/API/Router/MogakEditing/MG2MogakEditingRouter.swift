import Foundation
import Alamofire

enum MG2MogakEditingRouter {
    case categories
    case createMogak(modalartID: Int, title: String, category: MG2MogakCategorySelection, color: String)
    case editMogak(mogakID: Int, title: String, category: MG2MogakCategorySelection, color: String)
    case createJogak(mogakID: Int, title: String, schedule: MG2JogakSchedule)
    case editJogak(jogakID: Int, title: String, schedule: MG2JogakSchedule?)
}

extension MG2MogakEditingRouter: RequestTarget {
    var path: String {
        switch self {
        case .categories:
            return "/api/metadata/mogak-categories"
        case .createMogak:
            return "/api/mogaks"
        case .editMogak(let mogakID, _, _, _):
            return "/api/mogaks/\(mogakID)"
        case .createJogak:
            return "/api/jogaks"
        case .editJogak(let jogakID, _, _):
            return "/api/jogaks/\(jogakID)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .categories:
            return .get
        case .createMogak, .createJogak:
            return .post
        case .editMogak, .editJogak:
            return .patch
        }
    }

    var requiresAuthorization: Bool {
        if case .categories = self { return false }
        return true
    }

    var headers: [String: String]? {
        switch self {
        case .categories, .createMogak, .createJogak:
            return Self.jsonHeaders
        case .editMogak, .editJogak:
            return Self.mergePatchHeaders
        }
    }

    var body: [String: Any]? {
        switch self {
        case .categories:
            return nil
        case .createMogak(let modalartID, let title, let category, let color):
            // "modaratId"는 서버 철자 그대로다.
            var payload: [String: Any] = ["modaratId": modalartID, "title": title, "color": MG2APIColorCoding.encode(color)]
            payload.merge(flatCategoryPayload(category)) { _, new in new }
            return payload
        case .editMogak(_, let title, let category, let color):
            return ["title": title, "color": MG2APIColorCoding.encode(color), "category": categoryPayload(category)]
        case .createJogak(let mogakID, let title, let schedule):
            return ["mogakId": mogakID, "title": title, "schedule": createSchedulePayload(schedule)]
        case .editJogak(_, let title, let schedule):
            var payload: [String: Any] = ["title": title]
            if let schedule { payload["schedule"] = editSchedulePayload(schedule) }
            return payload
        }
    }
}

private extension MG2MogakEditingRouter {
    /// 생성 요청의 카테고리는 평면 필드로 보낸다.
    func flatCategoryPayload(_ category: MG2MogakCategorySelection) -> [String: Any] {
        switch category {
        case .official(let code):
            return ["categoryCode": code]
        case .custom(let name):
            return ["customCategoryName": name]
        }
    }

    /// 수정 요청의 카테고리는 태그 유니온으로 보낸다.
    func categoryPayload(_ category: MG2MogakCategorySelection) -> [String: Any] {
        switch category {
        case .official(let code):
            return ["type": "SYSTEM", "code": code]
        case .custom(let name):
            return ["type": "CUSTOM", "name": name]
        }
    }

    /// 생성 일정은 시작일을 함께 보낸다.
    func createSchedulePayload(_ schedule: MG2JogakSchedule) -> [String: Any] {
        switch schedule {
        case .once(let effectiveFrom):
            return ["scheduleType": "ONCE", "effectiveFrom": MG2APIDateCoding.encode(effectiveFrom)]
        case .weekly(let effectiveFrom, let effectiveTo, let weekdays):
            var payload: [String: Any] = ["scheduleType": "WEEKLY", "effectiveFrom": MG2APIDateCoding.encode(effectiveFrom), "weekdays": MG2APIWeekdayCoding.encode(weekdays)]
            if let effectiveTo { payload["effectiveTo"] = MG2APIDateCoding.encode(effectiveTo) }
            return payload
        }
    }

    /// 수정 일정은 시작일을 보내지 않고, 단발 일정은 빈 요일 배열을 보낸다.
    func editSchedulePayload(_ schedule: MG2JogakSchedule) -> [String: Any] {
        switch schedule {
        case .once:
            return ["scheduleType": "ONCE", "weekdays": [String]()]
        case .weekly(_, let effectiveTo, let weekdays):
            var payload: [String: Any] = ["scheduleType": "WEEKLY", "weekdays": MG2APIWeekdayCoding.encode(weekdays)]
            if let effectiveTo { payload["effectiveTo"] = MG2APIDateCoding.encode(effectiveTo) }
            return payload
        }
    }
}
