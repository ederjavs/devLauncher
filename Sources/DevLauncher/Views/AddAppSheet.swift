import SwiftUI

public struct AddAppSheet: View {
    @ObservedObject var viewModel: LauncherViewModel
    let targetCategory: AppCategory
    let onDismiss: () -> Void
    
    @State private var query: String = ""
    
    public init(viewModel: LauncherViewModel, targetCategory: AppCategory, onDismiss: @escaping () -> Void) {
        self.viewModel = viewModel
        self.targetCategory = targetCategory
        self.onDismiss = onDismiss
    }
    
    var filteredSystemApps: [(name: String, path: String, bundleId: String?)] {
        if query.isEmpty {
            return viewModel.scannedSystemApps
        }
        return viewModel.scannedSystemApps.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Cabecera
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Agregar Aplicación")
                        .font(.system(size: 14, weight: .bold))
                    Text("Guardar en: \(targetCategory.name)")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // Barra de búsqueda local
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Filtrar aplicaciones instaladas...", text: $query)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .background(Color.primary.opacity(0.05))
            .cornerRadius(8)
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
            
            Divider()
            
            // Lista de Apps detectadas
            if viewModel.scannedSystemApps.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Escaneando /Applications...")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredSystemApps, id: \.path) { systemApp in
                            Button(action: {
                                selectApp(systemApp)
                            }) {
                                HStack(spacing: 12) {
                                    AppIconLoader.getIcon(forPath: systemApp.path)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 28, height: 28)
                                    
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(systemApp.name)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.primary)
                                        Text(systemApp.path)
                                            .font(.system(size: 9))
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                            .truncationMode(.middle)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.accentColor)
                                        .opacity(0.8)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 20)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            
                            Divider().padding(.leading, 60)
                        }
                    }
                }
                .frame(maxHeight: .infinity)
            }
            
            Divider()
            
            // Botón de cierre
            HStack {
                Spacer()
                Button("Cerrar") {
                    onDismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.primary.opacity(0.02))
        }
        .frame(width: 360, height: 400)
        .onAppear {
            viewModel.scanSystemIfNeeded()
        }
    }
    
    private func selectApp(_ app: (name: String, path: String, bundleId: String?)) {
        withAnimation {
            viewModel.addApp(name: app.name, path: app.path, bundleId: app.bundleId, categoryId: targetCategory.id)
        }
        onDismiss()
    }
}
