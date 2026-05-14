import SwiftUI

public struct LauncherView: View {
    @ObservedObject var viewModel: LauncherViewModel
    
    // Estado para la animación Aladino
    @State private var isAppeared = false
    
    // Control de sheets
    @State private var activeSheet: ActiveSheet?
    @State private var categoryForNewApp: AppCategory?
    @State private var meetingToEdit: MeetingLink?
    
    enum ActiveSheet: Identifiable {
        case addApp, addMeeting, editMeeting, editCategories, settings
        var id: Int { hashValue }
    }
    
    public init(viewModel: LauncherViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            if isAppeared {
                VStack(spacing: 0) {
                    // 1. Buscador Flotante y Centrado (Estilo Launchpad)
                    HStack {
                        Spacer()
                        searchBar
                        Spacer()
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    // 2. El Grid Amplio de Apps (Scrolleable)
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 30) {
                            CategorizedAppsView(
                                viewModel: viewModel,
                                onAddAppToCategory: { category in
                                    self.categoryForNewApp = category
                                    self.activeSheet = .addApp
                                },
                                onEditCategories: {
                                    self.activeSheet = .editCategories
                                }
                            )
                            
                            // Separador súper sutil estilo brillo líquido
                            Rectangle()
                                .fill(LinearGradient(
                                    colors: [.clear, .white.opacity(0.1), .clear],
                                    startPoint: .leading, endPoint: .trailing
                                ))
                                .frame(height: 1)
                                .padding(.horizontal, 40)
                            
                            MeetingsListView(
                                viewModel: viewModel,
                                onAddPressed: {
                                    self.meetingToEdit = nil
                                    self.activeSheet = .addMeeting
                                },
                                onEditPressed: { meeting in
                                    self.meetingToEdit = meeting
                                    self.activeSheet = .editMeeting
                                }
                            )
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 10)
                    }
                    
                    // 3. Footer Estilo Vidrio
                    footerBar
                }
                .transition(.genie)
            }
        }
        .frame(width: 750, height: 520)
        // Fondo Launchpad Oficial: Material Nativo de SwiftUI que NO sangra esquinas
        // Con una base negra sólida del 78% para evitar el efecto descolorido
        .background(.ultraThickMaterial)
        .background(Color.black.opacity(0.78))
        .overlay(
            // Brillo de cristal ambiental sutil
            LinearGradient(
                colors: [.white.opacity(0.06), .clear, .black.opacity(0.15)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            // Borde brillante 3D de cristal (Bevel)
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.25), .white.opacity(0.04), .black.opacity(0.3)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: Color.black.opacity(0.55), radius: 35, y: 18)
        .onAppear {
            withAnimation(.genieAnimation()) {
                isAppeared = true
            }
        }
        .onDisappear {
            isAppeared = false
            viewModel.searchText = ""
        }
        // --- SISTEMA DE MODALES INTEGRADO EN CRISTAL (ZStack Custom Sheets) ---
        .overlay(
            ZStack {
                if let sheet = activeSheet {
                    // Fondo oscuro difuminador interactivo
                    Color.black.opacity(0.55)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            activeSheet = nil
                        }
                        .transition(.opacity)
                    
                    // Contenedor del Modal
                    Group {
                        switch sheet {
                        case .addApp:
                            if let category = categoryForNewApp {
                                AddAppSheet(viewModel: viewModel, targetCategory: category) { activeSheet = nil }
                            }
                        case .addMeeting:
                            AddMeetingSheet(viewModel: viewModel, existingMeeting: nil) { activeSheet = nil }
                        case .editMeeting:
                            if let meeting = meetingToEdit {
                                AddMeetingSheet(viewModel: viewModel, existingMeeting: meeting) { activeSheet = nil }
                            }
                        case .editCategories:
                            CategorySettingsView(viewModel: viewModel) { activeSheet = nil }
                        case .settings:
                            SettingsView { activeSheet = nil }
                        }
                    }
                    // Diseño del Modal con Material Nativo para esquinas perfectas
                    .background(.ultraThickMaterial)
                    .background(Color.black.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1.2)
                    )
                    .shadow(color: Color.black.opacity(0.6), radius: 30, y: 15)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.32, dampingFraction: 0.76), value: activeSheet != nil)
            .onExitCommand {
                // Captura la tecla 'Escape' física para cerrar el modal activo
                if activeSheet != nil {
                    activeSheet = nil
                }
            }
        )
    }
    
    // MARK: - Subviews
    
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
            
            TextField("Search", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
            
            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.4))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .frame(width: 280) // Ancho centrado tipo Launchpad
        .background(
            Capsule() // Pill shape perfecto
                .fill(Color.white.opacity(0.08))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
    
    private var footerBar: some View {
        HStack {
            Button(action: { self.activeSheet = .settings }) {
                Label("Settings", systemImage: "gearshape.fill")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.55))
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Button(action: { NSApplication.shared.terminate(nil) }) {
                HStack(spacing: 4) {
                    Text("Quit")
                    Image(systemName: "power.circle.fill")
                }
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.red.opacity(0.75))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 25)
        .padding(.vertical, 14)
        .background(Color.black.opacity(0.1))
    }
}

// Visual Effect View Nativo para el Vidrio Escarchado
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
