import SwiftUI

public struct AppsGridView: View {
    @ObservedObject var viewModel: LauncherViewModel
    let categoryId: UUID
    let onAddPressed: () -> Void
    
    @State private var isDropTarget = false  // Highlight cuando algo se arrastra encima
    
    private let columns = [
        GridItem(.adaptive(minimum: 76, maximum: 88), spacing: 20)
    ]
    
    public init(viewModel: LauncherViewModel, categoryId: UUID, onAddPressed: @escaping () -> Void) {
        self.viewModel = viewModel
        self.categoryId = categoryId
        self.onAddPressed = onAddPressed
    }
    
    public var body: some View {
        let apps = viewModel.filteredApps(for: categoryId)
        
        LazyVGrid(columns: columns, alignment: .leading, spacing: 20) {
            ForEach(apps) { app in
                AppItemView(
                    app: app,
                    action: { viewModel.launchApp(app) },
                    onDelete: {
                        withAnimation { viewModel.removeApp(app) }
                    }
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        // Área de "aterrizaje" mínima para cuando la categoría está vacía
        .frame(minHeight: apps.isEmpty ? 60 : 0)
        // ── DROP TARGET ──
        // Resalta toda el área de la categoría cuando una app vuela encima
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.cyan.opacity(isDropTarget ? 0.1 : 0))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(
                            isDropTarget ? Color.cyan.opacity(0.5) : Color.clear,
                            lineWidth: 1.5
                        )
                )
                .animation(.easeInOut(duration: 0.18), value: isDropTarget)
        )
        .dropDestination(for: AppItem.self) { droppedApps, _ in
            // Mueve cada app arrastrada a esta categoría
            withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                droppedApps.forEach { app in
                    viewModel.moveApp(app, toCategoryId: categoryId)
                }
            }
            return true
        } isTargeted: { targeted in
            isDropTarget = targeted
        }
    }
}
