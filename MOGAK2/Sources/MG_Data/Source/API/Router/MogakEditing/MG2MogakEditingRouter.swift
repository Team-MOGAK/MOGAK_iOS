import Foundation
import Alamofire

enum MG2MogakEditingRouter {
    case categories
    case createMogak(modaratId: Int, title: String, category: MG2MogakCategorySelection, color: String)
    case editMogak(mogakId: Int, title: String, category: MG2MogakCategorySelection, color: String)
    case createJogak(mogakId: Int, title: String, schedule: MG2JogakScheduleRequest)
    case editJogak(jogakId: Int, title: String, schedule: MG2JogakScheduleRequest?)
}

extension MG2MogakEditingRouter: RequestTarget {
    var path: String {
        switch self {
        case .categories:
            return "/api/metadata/mogak-categories"
        case .createMogak:
            return "/api/mogaks"
        case .editMogak(let mogakId, _, _, _):
            return "/api/mogaks/\(mogakId)"
        case .createJogak:
            return "/api/jogaks"
        case .editJogak(let jogakId, _, _):
            return "/api/jogaks/\(jogakId)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .categories:
            return .get
        case .createMogak, .createJogak:
            return .post
        case .editMogak, .editJogak:
            return .put
        }
    }

    var requiresAuthorization: Bool {
        if case .categories = self { return false }
        return true
    }

    var body: [String : Any]? {
        switch self {
        case .categories:
            return nil
        case .createMogak(let modaratId, let title, let category, let color):
            var payload: [String: Any] = ["modaratId": modaratId, "title": title, "color": color]
            payload.merge(categoryPayload(category)) { _, new in new }
            return payload
        case .editMogak(_, let title, let category, let color):
            var payload: [String: Any] = ["title": title, "color": color]
            payload.merge(categoryPayload(category)) { _, new in new }
            return payload
        case .createJogak(let mogakId, let title, let schedule):
            return ["mogakId": mogakId, "title": title, "schedule": schedule.body]
        case .editJogak(_, let title, let schedule):
            var payload: [String: Any] = ["title": title]
            if let schedule { payload["schedule"] = schedule.body }
            return payload
        }
    }
}

struct MG2JogakScheduleRequest {
    let body: [String: Any]

    init(schedule: MG2JogakSchedule) {
        switch schedule {
        case .once(let effectiveFrom):
            body = [
                "scheduleType": "ONCE",
                "effectiveFrom": MG2APIDateCoding.encode(effectiveFrom)
            ]
        case .weekly(let effectiveFrom, let effectiveTo, let weekdays):
            var value: [String: Any] = [
                "scheduleType": "WEEKLY",
                "effectiveFrom": MG2APIDateCoding.encode(effectiveFrom),
                "weekdays": MG2APIWeekdayCoding.encode(weekdays)
            ]
            if let effectiveTo {
                value["effectiveTo"] = MG2APIDateCoding.encode(effectiveTo)
            }
            body = value
        }
    }
}

private func categoryPayload(_ category: MG2MogakCategorySelection) -> [String: Any] {
    switch category {
    case .official(let code):
        return ["categoryCode": code]
    case .custom(let name):
        return ["customCategoryName": name]
    }
}
