import SwiftUI

public struct CategorizedAppsView: View {
    @ObservedObject var viewModel: LauncherViewModel
    let onAddAppToCategory: (AppCategory) -> Void
    let onEditCategories: () -> Void
    
    // Diccionario de estados para seguir el Hover específico de cada categoría
    @State private var hoveredCategoryIds: Set<UUID> = []
    
    public init(viewModel: LauncherViewModel, onAddAppToCategory: @escaping (AppCategory) -> Void, onEditCategories: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onAddAppToCategory = onAddAppToCategory
        self.onEditCategories = onEditCategories
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Sección de cabecera "APPLICATIONS" eliminada para ganar altura vertical masiva
            
            ForEach(viewModel.categories) { category in
                let filteredAppsCount = viewModel.filteredApps(for: category.id).count
                let isHovered = hoveredCategoryIds.contains(category.id)
                
                if filteredAppsCount > 0 || viewModel.searchText.isEmpty {
                    VStack(alignment: .leading, spacing: 14) {
                        
                        // Cabecera de la Categoría con Hover Robusto
                        HStack(spacing: 8) {
                            Image(systemName: category.iconName)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.cyan)
                                
                            Text(category.name)
                                    .font(.system(size: 13.5, weight: .bold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.95))
                                    .shadow(color: Color.black.opacity(0.3), radius: 2, y: 1)
                            
                            // El Botón "+" ahora siempre ocupa su espacio para evitar saltos de cursor
                            // Usamos .opacity para una transición orgánica libre de parpadeos
                            Button(action: { onAddAppToCategory(category) }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 10, weight: .heavy))
                                    .foregroundColor(.cyan.opacity(0.85))
                                    .frame(width: 18, height: 18)
                                    .background(Circle().fill(Color.cyan.opacity(0.18)))
                            }
                            .buttonStyle(.plain)
                            .padding(.leading, 4)
                            .opacity(isHovered ? 1 : 0)
                            .animation(.easeInOut(duration: 0.18), value: isHovered)
                            .help("Add app to \(category.name)")
                            
                            Spacer()
                        }
                        .padding(.horizontal, 28)
                        .contentShape(Rectangle()) // Captura eventos táctiles en toda la línea
                        .onHover { hovering in
                            // Activamos el hover a nivel del CONTENEDOR PADRE, 
                            // así al moverte al botón sigues dentro del contenedor!
                            withAnimation(.easeInOut(duration: 0.15)) {
                                if hovering {
                                    hoveredCategoryIds.insert(category.id)
                                } else {
                                    hoveredCategoryIds.remove(category.id)
                                }
                            }
                        }
                        
                        // Grid de apps adaptativo
                        AppsGridView(viewModel: viewModel, categoryId: category.id) {
                            onAddAppToCategory(category)
                        }
                    }
                }
            }
        }
    }
}
