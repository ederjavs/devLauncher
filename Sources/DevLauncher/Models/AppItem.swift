import Foundation
import CoreTransferable

public struct AppItem: Identifiable, Codable, Hashable, Transferable {
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
    
    // Protocolo Transferable: usa el UUID como payload para el drag & drop
    public static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .data)
    }
}

