import SwiftUI

public struct CategorySettingsView: View {
    @ObservedObject var viewModel: LauncherViewModel
    let onDismiss: () -> Void
    
    @State private var newCategoryName: String = ""
    @State private var selectedIcon: String = "hammer.fill"
    
    // Iconos SF Symbols predefinidos atractivos para categorías
    private let presetIcons = [
        "hammer.fill", "wrench.and.screwdriver.fill", "paintbrush.fill",
        "terminal.fill", "externaldrive.fill", "server.rack",
        "cube.fill", "cpu", "folder.badge.gearshape",
        "bubble.left.and.right.fill", "doc.richtext.fill", "star.fill"
    ]
    
    public init(viewModel: LauncherViewModel, onDismiss: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Cabecera
            HStack {
                Text("Gestionar Categorías")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 16)
            
            Divider()
            
            // Sección: Crear Nueva Categoría
            VStack(alignment: .leading, spacing: 10) {
                Text("NUEVA CATEGORÍA")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 10) {
                    TextField("Nombre de la categoría...", text: $newCategoryName)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("Añadir") {
                        addCategory()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                
                // Selector horizontal de Iconos
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(presetIcons, id: \.self) { icon in
                            Button(action: {
                                selectedIcon = icon
                            }) {
                                Image(systemName: icon)
                                    .font(.system(size: 14))
                                    .frame(width: 28, height: 28)
                                    .foregroundColor(selectedIcon == icon ? .white : .primary)
                                    .background(
                                        Circle()
                                            .fill(selectedIcon == icon ? Color.accentColor : Color.primary.opacity(0.05))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding(20)
            .background(Color.primary.opacity(0.02))
            
            Divider()
            
            // Lista de categorías actuales
            List {
                Section(header: Text("CATEGORÍAS ACTIVAS").font(.system(size: 10, weight: .bold))) {
                    ForEach(viewModel.categories) { category in
                        HStack(spacing: 12) {
                            Image(systemName: category.iconName)
                                .foregroundColor(.accentColor)
                                .frame(width: 16)
                            
                            Text(category.name)
                                .font(.system(size: 13))
                            
                            Spacer()
                            
                            // Prevenir eliminación de la última categoría obligatoria
                            if viewModel.categories.count > 1 {
                                Button(action: {
                                    withAnimation {
                                        viewModel.removeCategory(category)
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red.opacity(0.8))
                                }
                                .buttonStyle(.plain)
                                .help("Borra categoría y sus apps asociadas")
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .listStyle(.inset)
            .frame(height: 180)
            
            Divider()
            
            // Pie
            HStack {
                Spacer()
                Button("Hecho", action: onDismiss)
                    .buttonStyle(.bordered)
                    .keyboardShortcut(.return, modifiers: [])
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .frame(width: 380, height: 440)
    }
    
    private func addCategory() {
        let name = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        
        withAnimation {
            viewModel.addCategory(name: name, iconName: selectedIcon)
        }
        newCategoryName = ""
    }
}
