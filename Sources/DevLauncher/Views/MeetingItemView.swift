import SwiftUI

public struct MeetingItemView: View {
    let meeting: MeetingLink
    let onAction: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var isHovered = false
    
    public init(meeting: MeetingLink, onAction: @escaping () -> Void, onEdit: @escaping () -> Void, onDelete: @escaping () -> Void) {
        self.meeting = meeting
        self.onAction = onAction
        self.onEdit = onEdit
        self.onDelete = onDelete
    }
    
    private var platformColor: Color { Color(hex: meeting.platform.hexColor) }
    
    public var body: some View {
        Button(action: onAction) {
            VStack(spacing: 10) {
                // Icono Esférico de Reunión (Mismo tamaño que los iconos de App)
                ZStack {
                    // Fondo degradado premium con el color de la plataforma
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [platformColor, platformColor.opacity(0.75)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 58, height: 58)
                        .shadow(color: platformColor.opacity(isHovered ? 0.45 : 0.25), 
                                radius: isHovered ? 12 : 6, 
                                y: isHovered ? 6 : 3)
                    
                    // Reflejo de cristal en la parte superior del círculo
                    Circle()
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    
                    // Simbolo de plataforma centrado y elegante
                    Image(systemName: meeting.platform.systemIconName)
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 2)
                }
                
                // Título del Meeting
                Text(meeting.name)
                    .font(.system(size: 11.5, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.6), radius: 2, x: 0, y: 1)
            }
            .frame(width: 88, height: 94)
            .padding(.vertical, 12)
            .padding(.horizontal, 6)
            // Halo de brillo al pasar el ratón
            .background(
                Circle()
                    .fill(platformColor.opacity(isHovered ? 0.12 : 0))
                    .frame(width: 84, height: 84)
                    .blur(radius: 8)
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
        .help("Join Meeting: \(meeting.name)")
        .contextMenu {
            Button(action: onAction) {
                Label("Join Now", systemImage: "video.fill")
            }
            Button(action: {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(meeting.url, forType: .string)
            }) {
                Label("Copy URL", systemImage: "link")
            }
            Divider()
            Button(action: onEdit) {
                Label("Edit Details", systemImage: "pencil")
            }
            Button(role: .destructive, action: onDelete) {
                Label("Remove", systemImage: "trash")
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}
