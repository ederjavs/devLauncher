import SwiftUI
import KeyboardShortcuts

public struct SettingsView: View {
    let onDismiss: () -> Void
    
    public init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Cabecera
            HStack {
                Text("Configuración DevLauncher")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 16)
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Sección Atajo Global
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Acceso Directo", systemImage: "keyboard")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        Text("Define una combinación de teclas global para abrir y ocultar el launcher desde cualquier aplicación.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .padding(.bottom, 4)
                        
                        HStack {
                            Text("Atajo de Apertura:")
                                .font(.system(size: 12, weight: .medium))
                            
                            Spacer()
                            
                            // El Grabador Nativo de la librería
                            KeyboardShortcuts.Recorder(for: .toggleLauncher)
                        }
                        .padding(12)
                        .background(Color.primary.opacity(0.04))
                        .cornerRadius(8)
                    }
                    
                    Divider()
                    
                    // Info de la app
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Acerca de", systemImage: "info.circle")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("DevLauncher v1.0.0")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Creado con Swift y SwiftUI nativo.")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.primary.opacity(0.02))
                        .cornerRadius(8)
                    }
                }
                .padding(20)
            }
            
            Divider()
            
            // Pie
            HStack {
                Spacer()
                Button("Cerrar") {
                    onDismiss()
                }
                .buttonStyle(.bordered)
                .keyboardShortcut(.return, modifiers: [])
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.primary.opacity(0.02))
        }
        .frame(width: 350, height: 320)
    }
}
