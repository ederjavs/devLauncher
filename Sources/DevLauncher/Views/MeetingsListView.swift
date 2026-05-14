import SwiftUI

public struct MeetingsListView: View {
    @ObservedObject var viewModel: LauncherViewModel
    let onAddPressed: () -> Void
    let onEditPressed: (MeetingLink) -> Void
    
    @State private var isHeaderHovered = false
    
    // La misma rejilla simétrica que usamos para Apps para máxima armonía
    private let columns = [
        GridItem(.adaptive(minimum: 64, maximum: 76), spacing: 14)
    ]
    
    public init(viewModel: LauncherViewModel, onAddPressed: @escaping () -> Void, onEditPressed: @escaping (MeetingLink) -> Void) {
        self.viewModel = viewModel
        self.onAddPressed = onAddPressed
        self.onEditPressed = onEditPressed
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Cabecera de Meetings limpia e interactiva con HOVER ROBUSTO
            HStack(spacing: 8) {
                Label("MEETING ROOMS", systemImage: "video.circle.fill")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1.2)
                    .foregroundColor(.white.opacity(0.5))
                
                // Botón "+" animado por opacidad para evitar parpadeos y bugs táctiles
                Button(action: onAddPressed) {
                    Image(systemName: "plus")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundColor(.green.opacity(0.85))
                        .frame(width: 18, height: 18)
                        .background(Circle().fill(Color.green.opacity(0.18)))
                }
                .buttonStyle(.plain)
                .padding(.leading, 4)
                .opacity(isHeaderHovered ? 1 : 0)
                .animation(.easeInOut(duration: 0.18), value: isHeaderHovered)
                .help("Add a new meeting link")
                
                Spacer()
            }
            .padding(.horizontal, 26)
            .contentShape(Rectangle()) // Captura la línea completa de hover
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.15)) {
                    isHeaderHovered = hovering
                }
            }
            
            let meetings = viewModel.filteredMeetings
            
            LazyVGrid(columns: columns, alignment: .leading, spacing: 20) {
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
