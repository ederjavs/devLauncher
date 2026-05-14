import SwiftUI

public struct CategorizedAppsView: View {
    @ObservedObject var viewModel: LauncherViewModel
    let onAddAppToCategory: (AppCategory) -> Void
    let onEditCategories: () -> Void
    
    @State private var hoveredCategoryId: UUID? = nil
    
    public init(viewModel: LauncherViewModel, onAddAppToCategory: @escaping (AppCategory) -> Void, onEditCategories: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onAddAppToCategory = onAddAppToCategory
        self.onEditCategories = onEditCategories
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            // Cabecera general de la sección de Apps
            HStack {
                Label("APPLICATIONS", systemImage: "square.grid.3x3.fill")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1.2)
                    .foregroundColor(.white.opacity(0.5))
                
                Spacer()
                
                Button(action: onEditCategories) {
                    HStack(spacing: 4) {
                        Text("Edit Groups")
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.45))
                }
                .buttonStyle(.plain)
                .help("Organize app categories")
            }
            .padding(.horizontal, 26)
            
            // Secciones de Categorías
            ForEach(viewModel.categories) { category in
                let filteredAppsCount = viewModel.filteredApps(for: category.id).count
                
                if filteredAppsCount > 0 || viewModel.searchText.isEmpty {
                    VStack(alignment: .leading, spacing: 14) {
                        // Cabecera de la Categoría Interactiva (Aparece el botón "+" al pasar el mouse)
                        HStack(spacing: 8) {
                            Image(systemName: category.iconName)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.cyan)
                            
                            Text(category.name)
                                .font(.system(size: 13.5, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.95))
                                .shadow(color: Color.black.opacity(0.3), radius: 2, y: 1)
                            
                            // Botón "+" Sutil que se revela al Hover para no distraer
                            if hoveredCategoryId == category.id {
                                Button(action: { onAddAppToCategory(category) }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 13))
                                        Text("Add App")
                                            .font(.system(size: 10.5, weight: .bold))
                                    }
                                    .foregroundColor(.cyan)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Capsule().fill(Color.cyan.opacity(0.15)))
                                }
                                .buttonStyle(.plain)
                                .transition(.opacity.combined(with: .move(edge: .leading)))
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 28)
                        .contentShape(Rectangle()) // Asegura captar el hover en toda el área
                        .onHover { isHovering in
                            withAnimation(.easeInOut(duration: 0.15)) {
                                if isHovering {
                                    hoveredCategoryId = category.id
                                } else if hoveredCategoryId == category.id {
                                    hoveredCategoryId = nil
                                }
                            }
                        }
                        
                        // Grid adaptativo limpio sin botones distractores
                        AppsGridView(viewModel: viewModel, categoryId: category.id) {
                            onAddAppToCategory(category)
                        }
                    }
                }
            }
        }
    }
}
