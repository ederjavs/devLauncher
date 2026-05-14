import Foundation

public struct MeetingLink: Identifiable, Codable, Hashable {
    public let id: UUID
    public var name: String
    public var url: String
    
    public init(id: UUID = UUID(), name: String, url: String) {
        self.id = id
        self.name = name
        self.url = url
    }
    
    // Atributo computado para obtener visualmente la plataforma del link
    public var platform: MeetingPlatform {
        let lowercasedUrl = url.lowercased()
        if lowercasedUrl.contains("meet.google.com") {
            return .googleMeet
        } else if lowercasedUrl.contains("zoom.us") {
            return .zoom
        } else if lowercasedUrl.contains("teams.microsoft.com") || lowercasedUrl.contains("teams.live.com") {
            return .teams
        } else if lowercasedUrl.contains("slack.com") {
            return .slack
        } else {
            return .other
        }
    }
}

public enum MeetingPlatform: String, Codable, CaseIterable {
    case googleMeet = "Google Meet"
    case zoom = "Zoom"
    case teams = "Teams"
    case slack = "Slack Huddle"
    case other = "Enlace General"
    
    public var systemIconName: String {
        switch self {
        case .googleMeet: return "video.circle.fill"
        case .zoom: return "video.fill"
        case .teams: return "person.2.fill"
        case .slack: return "bubble.left.and.right.fill"
        case .other: return "link"
        }
    }
    
    // Retorna un color de acento para cada tipo de meet
    public var hexColor: String {
        switch self {
        case .googleMeet: return "#34A853" // Verde Google
        case .zoom: return "#2D8CFF"       // Azul Zoom
        case .teams: return "#6264A7"      // Morado Teams
        case .slack: return "#E01E5A"      // Rosa Slack
        case .other: return "#007AFF"      // Azul Apple genérico
        }
    }
}
