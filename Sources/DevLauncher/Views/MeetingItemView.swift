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
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [platformColor, platformColor.opacity(0.75)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .shadow(color: platformColor.opacity(isHovered ? 0.4 : 0.22),
                                radius: isHovered ? 10 : 5,
                                y: isHovered ? 5 : 2.5)
                    
                    Circle()
                        .stroke(Color.white.opacity(0.22), lineWidth: 0.9)
                    
                    Image(systemName: meeting.platform.systemIconName)
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 2)
                }
                
                Text(meeting.name)
                    .font(.system(size: 10.5, weight: .bold, design: .rounded))
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
                    .fill(platformColor.opacity(isHovered ? 0.1 : 0))
                    .frame(width: 72, height: 72)
                    .blur(radius: 6)
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
