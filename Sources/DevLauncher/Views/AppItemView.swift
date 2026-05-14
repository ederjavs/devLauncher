import SwiftUI

public struct AppItemView: View {
    let app: AppItem
    let action: () -> Void
    let onDelete: () -> Void
    
    @State private var isHovered = false
    @State private var isDragging = false
    
    public init(app: AppItem, action: @escaping () -> Void, onDelete: @escaping () -> Void) {
        self.app = app
        self.action = action
        self.onDelete = onDelete
    }
    
    public var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                AppIconLoader.getIcon(forPath: app.path)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
                    .shadow(color: Color.black.opacity(isHovered ? 0.3 : 0.18),
                            radius: isHovered ? 10 : 5,
                            y: isHovered ? 5 : 2.5)
                
                Text(app.name)
                    .font(.system(size: 10.5, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 1)
            }
            .frame(width: 76, height: 82)
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .background(
                Circle()
                    .fill(Color.white.opacity(isHovered ? 0.09 : 0))
                    .frame(width: 72, height: 72)
                    .blur(radius: 5)
                    .scaleEffect(isHovered ? 1.12 : 0.92)
                    .animation(.easeOut(duration: 0.2), value: isHovered)
            )
            // Efecto visual de levitación al arrastrar (como el Launchpad original)
            .opacity(isDragging ? 0.4 : 1.0)
            .scaleEffect(isDragging ? 0.85 : (isHovered ? 1.06 : 1.0))
            .animation(.spring(response: 0.25, dampingFraction: 0.68), value: isHovered)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isDragging)
        }
        .buttonStyle(.plain)
        .onHover { hovering in isHovered = hovering }
        .help(app.name)
        // ── DRAG SOURCE ──
        // Mantén presionado y arrastra para mover entre categorías
        .draggable(app) {
            // Preview flotante que aparece al arrastrar
            VStack(spacing: 6) {
                AppIconLoader.getIcon(forPath: app.path)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: .black.opacity(0.4), radius: 12, y: 6)
                
                Text(app.name)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.6), radius: 2)
            }
            .padding(10)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .onAppear { isDragging = true }
            .onDisappear { isDragging = false }
        }
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Remove from DevLauncher", systemImage: "trash")
            }
        }
    }
}
