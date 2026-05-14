import SwiftUI

public struct MeetingsListView: View {
    @ObservedObject var viewModel: LauncherViewModel
    let onAddPressed: () -> Void
    let onEditPressed: (MeetingLink) -> Void
    
    // La misma rejilla simétrica que usamos para Apps para máxima armonía
    private let columns = [
        GridItem(.adaptive(minimum: 88, maximum: 96), spacing: 24)
    ]
    
    public init(viewModel: LauncherViewModel, onAddPressed: @escaping () -> Void, onEditPressed: @escaping (MeetingLink) -> Void) {
        self.viewModel = viewModel
        self.onAddPressed = onAddPressed
        self.onEditPressed = onEditPressed
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Cabecera de Meetings limpia e interactiva
            HStack(spacing: 8) {
                Label("MEETING ROOMS", systemImage: "video.circle.fill")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1.2)
                    .foregroundColor(.white.opacity(0.5))
                
                // Botón "+" Fijo de alta legibilidad
                Button(action: onAddPressed) {
                    Image(systemName: "plus")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundColor(.green.opacity(0.85))
                        .frame(width: 18, height: 18)
                        .background(Circle().fill(Color.green.opacity(0.18)))
                }
                .buttonStyle(.plain)
                .padding(.leading, 4)
                .help("Add a new meeting link")
                
                Spacer()
            }
            .padding(.horizontal, 26)
            
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
