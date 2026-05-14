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
                        .contentShape(Rectangle()) // Asegura que toda el área capture el Scroll de ratón
                    }
                    
                    // 3. Footer Estilo Vidrio
                    footerBar
                }
                .transition(.genie)
            }
        }
        .frame(width: 750, height: 520)
        // El NSPopover gestiona su propio marco, flecha y glassmorphism.
        // Solo necesitamos definir el fondo oscuro Noir encima del material del sistema
        .background(
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow, cornerRadius: 0)
                .overlay(
                    Color.black.opacity(0.80) // Noir oscuro para evitar efecto blanquizco
                )
        )
        // Brillo de cristal ambiental muy sutil (edge highlight)
        .overlay(
            LinearGradient(
                colors: [.white.opacity(0.05), .clear, .black.opacity(0.1)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .allowsHitTesting(false)
        )
        // Fuerza modo oscuro siempre para look premium consistente
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.genieAnimation()) {
                isAppeared = true
            }
        }
        .onDisappear {
            isAppeared = false
            viewModel.searchText = ""
        }
        // --- SISTEMA DE MODALES INTEGRADO ---
        .overlay(
            ZStack {
                if let sheet = activeSheet {
                    Color.black.opacity(0.65)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            activeSheet = nil
                        }
                        .transition(.opacity)
                    
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
                            SettingsView(
                                onManageCategories: { activeSheet = .editCategories },
                                onDismiss: { activeSheet = nil }
                            )
                        }
                    }
                    .background(
                        VisualEffectView(material: .popover, blendingMode: .withinWindow, cornerRadius: 22)
                            .overlay(Color.black.opacity(0.4))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1.2)
                    )
                    .shadow(color: Color.black.opacity(0.65), radius: 30, y: 15)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                }
            }
            // ¡¡CRÍTICO!! allowsHitTesting previene que esta capa bloquee el ScrollView cuando está vacía
            .allowsHitTesting(activeSheet != nil) 
            .animation(.spring(response: 0.32, dampingFraction: 0.76), value: activeSheet != nil)
            .onExitCommand {
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
                .foregroundColor(.white.opacity(0.5))
            
            TextField("Search", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
            
            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .frame(width: 280)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.1))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
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
                .foregroundColor(.red.opacity(0.85))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 25)
        .padding(.vertical, 14)
        .background(Color.black.opacity(0.2))
    }
}

// MARK: - Visual Effect View Nativo y Refinado con Capas QuartzCore Reales
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    let cornerRadius: CGFloat // Añadido para redondeado a nivel de sistema
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        
        // Activar QuartzCore Layers para recortar esquinas físicamente y evitar sangrado rectangular
        view.wantsLayer = true
        view.layer?.cornerRadius = cornerRadius
        view.layer?.masksToBounds = true
        
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.layer?.cornerRadius = cornerRadius
    }
}
