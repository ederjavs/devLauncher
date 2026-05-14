import SwiftUI

public struct AppItemView: View {
    let app: AppItem
    let action: () -> Void
    let onDelete: () -> Void
    
    @State private var isHovered = false
    
    public init(app: AppItem, action: @escaping () -> Void, onDelete: @escaping () -> Void) {
        self.app = app
        self.action = action
        self.onDelete = onDelete
    }
    
    public var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Icono escalado 10px más pequeño (48x48) para un look más estilizado
                AppIconLoader.getIcon(forPath: app.path)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
                    .shadow(color: Color.black.opacity(isHovered ? 0.3 : 0.18), 
                            radius: isHovered ? 10 : 5, 
                            y: isHovered ? 5 : 2.5)
                
                // Texto escalado y espaciado
                Text(app.name)
                    .font(.system(size: 10.5, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 1)
            }
            // Contenedor escalado proporcionalmente (76x82)
            .frame(width: 76, height: 82)
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            // Halo de brillo sutilmente más pequeño y elegante
            .background(
                Circle()
                    .fill(Color.white.opacity(isHovered ? 0.09 : 0))
                    .frame(width: 72, height: 72)
                    .blur(radius: 5)
                    .scaleEffect(isHovered ? 1.12 : 0.92)
                    .animation(.easeOut(duration: 0.2), value: isHovered)
            )
            .scaleEffect(isHovered ? 1.06 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.68), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
        .help(app.name)
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Remove from DevLauncher", systemImage: "trash")
            }
        }
    }
}
