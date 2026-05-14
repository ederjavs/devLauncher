import SwiftUI

public struct AppsGridView: View {
    @ObservedObject var viewModel: LauncherViewModel
    let categoryId: UUID
    let onAddPressed: () -> Void
    
    // Grid optimizado para iconos 10px más pequeños, ganando ligereza proporcional
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
    }
}
