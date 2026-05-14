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
            VStack(spacing: 10) {
                // Icono Gigante estilo Launchpad
                AppIconLoader.getIcon(forPath: app.path)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 58, height: 58)
                    .shadow(color: Color.black.opacity(isHovered ? 0.35 : 0.2), 
                            radius: isHovered ? 12 : 6, 
                            y: isHovered ? 6 : 3)
                
                // Texto Blanco Refinado con Sombra (Legible en fondos borrosos)
                Text(app.name)
                    .font(.system(size: 11.5, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.6), radius: 2, x: 0, y: 1)
            }
            .frame(width: 88, height: 94)
            .padding(.vertical, 12)
            .padding(.horizontal, 6)
            // Efecto de Brillo Circular traslúcido (Hover Halo) en lugar de tarjeta
            .background(
                Circle()
                    .fill(Color.white.opacity(isHovered ? 0.1 : 0))
                    .frame(width: 84, height: 84)
                    .blur(radius: 6)
                    .scaleEffect(isHovered ? 1.15 : 0.9)
                    .animation(.easeOut(duration: 0.2), value: isHovered)
            )
            .scaleEffect(isHovered ? 1.08 : 1.0)
            .animation(.spring(response: 0.28, dampingFraction: 0.65), value: isHovered)
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
