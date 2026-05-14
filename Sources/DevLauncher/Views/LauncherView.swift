import SwiftUI

// PreferenceKey para medir la altura real del contenido dentro del ScrollView
private struct ContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

public struct LauncherView: View {
    @ObservedObject var viewModel: LauncherViewModel
    
    // Estado para la animación Aladino
    @State private var isAppeared = false
    
    // Control de sheets
    @State private var activeSheet: ActiveSheet?
    @State private var categoryForNewApp: AppCategory?
    @State private var meetingToEdit: MeetingLink?
    
    // ── FOCO AUTOMÁTICO EN BÚSQUEDA ──
    @FocusState private var isSearchFocused: Bool
    
    // ── ALTURA DINÁMICA ──
    @State private var measuredContentHeight: CGFloat = 200
    
    // Constantes de layout
    private let fixedWidth: CGFloat = 750
    private let searchBarAreaHeight: CGFloat = 52   // searchBar + paddings
    private let footerHeight: CGFloat = 42          // footer bar
    private let minHeight: CGFloat = 180
    
    /// Máxima altura permitida: 80% de la pantalla disponible debajo del menú
    private var maxHeight: CGFloat {
        let screenHeight = NSScreen.main?.visibleFrame.height ?? 800
        return min(screenHeight * 0.80, 720)
    }
    
    /// Altura final: crece con contenido, pero nunca excede maxHeight
    private var dynamicHeight: CGFloat {
        let idealHeight = searchBarAreaHeight + measuredContentHeight + footerHeight
        return min(max(idealHeight, minHeight), maxHeight)
    }
    
    
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
                    // 1. Buscador Flotante
                    HStack {
                        Spacer()
                        searchBar
                        Spacer()
                    }
                    .padding(.top, 14)
                    .padding(.bottom, 6)
                    
                    // 2. Contenido Principal: ScrollView SIEMPRE presente
                    // (No hace scroll si el contenido cabe — eso lo gestiona macOS nativamente)
                    ScrollView(.vertical, showsIndicators: false) {
                        mainContent
                    }
                    
                    // 3. Footer
                    footerBar
                }
                .transition(.genie)
            }
        }
        .frame(width: fixedWidth, height: dynamicHeight)
        .background(
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow, cornerRadius: 0)
                .overlay(Color.black.opacity(0.80))
        )
        .overlay(
            LinearGradient(
                colors: [.white.opacity(0.05), .clear, .black.opacity(0.1)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .allowsHitTesting(false)
        )
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.genieAnimation()) {
                isAppeared = true
            }
            // Foco automático en la barra de búsqueda tras la animación
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isSearchFocused = true
            }
        }
        .onDisappear {
            isAppeared = false
            viewModel.searchText = ""
        }
        // Notificar al NSPopover cada vez que cambie la altura
        .onChange(of: dynamicHeight) { newHeight in
            NotificationCenter.default.post(
                name: .popoverShouldResize,
                object: nil,
                userInfo: ["height": newHeight]
            )
        }
        // Modal overlay
        .overlay(
            ZStack {
                if let sheet = activeSheet {
                    Color.black.opacity(0.65)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture { activeSheet = nil }
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
            .allowsHitTesting(activeSheet != nil)
            .animation(.spring(response: 0.32, dampingFraction: 0.76), value: activeSheet != nil)
            .onExitCommand {
                if activeSheet != nil { activeSheet = nil }
            }
        )
    }
    
    // MARK: - Main Content (medible)
    
    /// El contenido central que se mide para calcular la altura dinámica
    private var mainContent: some View {
        VStack(spacing: 18) {
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
            
            // Separador
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
        .padding(.vertical, 12)
        .padding(.horizontal, 6)
        .contentShape(Rectangle())
        // ── MEDICIÓN DE CONTENIDO ──
        // Un GeometryReader invisible lee la altura real del contenido
        .background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: ContentHeightKey.self, value: geo.size.height)
            }
        )
        .onPreferenceChange(ContentHeightKey.self) { height in
            if abs(measuredContentHeight - height) > 1 {
                measuredContentHeight = height
            }
        }
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
                .focused($isSearchFocused)
            
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

// MARK: - Visual Effect View
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    let cornerRadius: CGFloat
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
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
