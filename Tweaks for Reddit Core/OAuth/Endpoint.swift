import Foundation

public enum Endpoint: Equatable {
    case me
    case about(user: String)
    case unreadMessages

    public var url: URL {
        switch self {
            case let .about(user: user):
                return URL(string: "https://oauth.reddit.com/user/\(user)/about")!

            case .me:
                return URL(string: "https://oauth.reddit.com/api/v1/me")!

            case .unreadMessages:
                return URL(string: "https://oauth.reddit.com/message/unread")!
        }
    }

    public var method: String {
        switch self {
            default: return "GET"
        }
    }
}
