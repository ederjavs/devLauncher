import SwiftUI

public struct MeetingsListView: View {
    @ObservedObject var viewModel: LauncherViewModel
    let onAddPressed: () -> Void
    let onEditPressed: (MeetingLink) -> Void
    
    // La misma rejilla simétrica que usamos para Apps para máxima armonía
    private let columns = [
        GridItem(.adaptive(minimum: 88, maximum: 96), spacing: 24)
    ]
    
    @State private var isHeaderHovered = false
    
    public init(viewModel: LauncherViewModel, onAddPressed: @escaping () -> Void, onEditPressed: @escaping (MeetingLink) -> Void) {
        self.viewModel = viewModel
        self.onAddPressed = onAddPressed
        self.onEditPressed = onEditPressed
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Cabecera de Meetings interactiva
            HStack(spacing: 8) {
                Label("MEETING ROOMS", systemImage: "video.circle.fill")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1.2)
                    .foregroundColor(.white.opacity(0.5))
                
                if isHeaderHovered {
                    Button(action: onAddPressed) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 13))
                            Text("New Meeting")
                                .font(.system(size: 10.5, weight: .bold))
                        }
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.green.opacity(0.15)))
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity.combined(with: .move(edge: .leading)))
                }
                
                Spacer()
            }
            .padding(.horizontal, 26)
            .contentShape(Rectangle())
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.15)) {
                    isHeaderHovered = hovering
                }
            }
            
            let meetings = viewModel.filteredMeetings
            
            LazyVGrid(columns: columns, alignment: .leading, spacing: 24) {
                // Renderizamos los iconos de Meetings únicamente
                ForEach(meetings) { meeting in
                    MeetingItemView(
                        meeting: meeting,
                        onAction: { viewModel.openMeeting(meeting) },
                        onEdit: { onEditPressed(meeting) },
                        onDelete: {
                            withAnimation { viewModel.removeMeeting(meeting) }
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
}
