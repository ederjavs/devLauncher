import Foundation

public struct AppItem: Identifiable, Codable, Hashable {
    public let id: UUID
    public var name: String
    public var bundleIdentifier: String?
    public var path: String              // Ruta absoluta p.ej. "/Applications/Xcode.app"
    public var categoryId: UUID          // FK hacia AppCategory
    
    public init(id: UUID = UUID(), name: String, bundleIdentifier: String? = nil, path: String, categoryId: UUID) {
        self.id = id
        self.name = name
        self.bundleIdentifier = bundleIdentifier
        self.path = path
        self.categoryId = categoryId
    }
}
