import SwiftUI

public struct CategorizedAppsView: View {
    @ObservedObject var viewModel: LauncherViewModel
    let onAddAppToCategory: (AppCategory) -> Void
    let onEditCategories: () -> Void
    
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
                        // Cabecera de la Categoría limpia y funcional
                        HStack(spacing: 8) {
                            Image(systemName: category.iconName)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.cyan)
                            
                            Text(category.name)
                                .font(.system(size: 13.5, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.95))
                                .shadow(color: Color.black.opacity(0.3), radius: 2, y: 1)
                            
                            // Botón "+" Elegante, Pequeño y SIEMPRE accesible para evitar fallos de cursor
                            Button(action: { onAddAppToCategory(category) }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 10, weight: .heavy))
                                    .foregroundColor(.cyan.opacity(0.85))
                                    .frame(width: 18, height: 18)
                                    .background(Circle().fill(Color.cyan.opacity(0.18)))
                            }
                            .buttonStyle(.plain)
                            .padding(.leading, 4)
                            .help("Add app to \(category.name)")
                            
                            Spacer()
                        }
                        .padding(.horizontal, 28)
                        
                        // Grid adaptativo sin botones distractores
                        AppsGridView(viewModel: viewModel, categoryId: category.id) {
                            onAddAppToCategory(category)
                        }
                    }
                }
            }
        }
    }
}
