import Foundation

public struct AppCategory: Identifiable, Codable, Hashable {
    public let id: UUID
    public var name: String
    public var iconName: String // SF Symbol
    
    public init(id: UUID = UUID(), name: String, iconName: String) {
        self.id = id
        self.name = name
        self.iconName = iconName
    }
    
    // Categorías por defecto para inicializar la app
    public static var defaultCategories: [AppCategory] {
        [
            AppCategory(name: "Desarrollo", iconName: "hammer.fill"),
            AppCategory(name: "Utilidades", iconName: "wrench.and.screwdriver.fill"),
            AppCategory(name: "Diseño", iconName: "paintbrush.fill")
        ]
    }
}
