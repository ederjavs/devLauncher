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
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [platformColor, platformColor.opacity(0.75)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 38, height: 38)
                        .shadow(color: platformColor.opacity(isHovered ? 0.35 : 0.18),
                                radius: isHovered ? 8 : 4,
                                y: isHovered ? 4 : 2)
                    
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.8)
                        .frame(width: 38, height: 38)
                    
                    Image(systemName: meeting.platform.systemIconName)
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 1.5)
                }
                
                Text(meeting.name)
                    .font(.system(size: 9.5, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.5), radius: 1.5, x: 0, y: 1)
            }
            .frame(width: 68, height: 66)
            .padding(.vertical, 4)
            .padding(.horizontal, 2)
            .background(
                Circle()
                    .fill(platformColor.opacity(isHovered ? 0.1 : 0))
                    .frame(width: 56, height: 56)
                    .blur(radius: 5)
                    .scaleEffect(isHovered ? 1.1 : 0.9)
                    .animation(.easeOut(duration: 0.18), value: isHovered)
            )
            .scaleEffect(isHovered ? 1.06 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.68), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in isHovered = hovering }
        .help("Join: \(meeting.name)")
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
