import SwiftUI

public struct AddMeetingSheet: View {
    @ObservedObject var viewModel: LauncherViewModel
    let existingMeeting: MeetingLink?
    let onDismiss: () -> Void
    
    @State private var name: String = ""
    @State private var urlString: String = ""
    
    public init(viewModel: LauncherViewModel, existingMeeting: MeetingLink? = nil, onDismiss: @escaping () -> Void) {
        self.viewModel = viewModel
        self.existingMeeting = existingMeeting
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            // Cabecera
            Text(existingMeeting == nil ? "Nuevo Meeting" : "Editar Meeting")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .padding(.top, 10)
            
            // Campos
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Nombre descriptivo")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    TextField("Ej: Daily Standup", text: $name)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("URL del enlace")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    TextField("Ej: meet.google.com/abc-defg", text: $urlString)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer(minLength: 12)
            
            // Acciones
            HStack {
                Button("Cancelar", action: onDismiss)
                    .keyboardShortcut(.escape, modifiers: [])
                
                Spacer()
                
                Button(existingMeeting == nil ? "Añadir" : "Guardar") {
                    saveMeeting()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || urlString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .keyboardShortcut(.return, modifiers: [])
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .frame(width: 320, height: 240)
        .onAppear {
            // Rellenar si estamos editando
            if let meeting = existingMeeting {
                self.name = meeting.name
                self.urlString = meeting.url
            }
        }
    }
    
    private func saveMeeting() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        var trimmedUrl = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !trimmedUrl.lowercased().hasPrefix("http://") && !trimmedUrl.lowercased().hasPrefix("https://") {
            trimmedUrl = "https://" + trimmedUrl
        }
        
        if let existing = existingMeeting {
            var updated = existing
            updated.name = trimmedName
            updated.url = trimmedUrl
            withAnimation {
                viewModel.updateMeeting(updated)
            }
        } else {
            withAnimation {
                viewModel.addMeeting(name: trimmedName, urlString: trimmedUrl)
            }
        }
        
        onDismiss()
    }
}
