import SwiftUI
import AppKit
import KeyboardShortcuts

@main
struct DevLauncherApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

// MARK: - AppDelegate

public final class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var eventMonitor: Any?
    let viewModel = LauncherViewModel()
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        setupStatusItem()
        setupPopover()
        setupGlobalShortcut()
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "square.grid.2x2.fill", accessibilityDescription: "DevLauncher")
            button.image?.isTemplate = true
            button.target = self
            button.action = #selector(statusItemClicked)
        }
    }
    
    private func setupPopover() {
        let pop = NSPopover()
        pop.contentSize = NSSize(width: 750, height: 520)
        // .semitransparent da el efecto liquid glass nativo de macOS con la flechita
        pop.behavior = .transient     // Se cierra solo al hacer clic fuera
        pop.animates = true           // Animación de apertura nativa de Apple
        
        // Material que da el efecto glass/vitral con la flecha incluida
        pop.contentViewController = PopoverHostingController(
            rootView: LauncherView(viewModel: viewModel)
        )
        
        self.popover = pop
    }
    
    private func setupGlobalShortcut() {
        KeyboardShortcuts.onKeyUp(for: .toggleLauncher) { [weak self] in
            self?.togglePopover()
        }
    }
    
    @objc private func statusItemClicked() {
        togglePopover()
    }
    
    public func togglePopover() {
        guard let popover = popover else { return }
        
        if popover.isShown {
            popover.performClose(nil)
        } else {
            showPopover()
        }
    }
    
    private func showPopover() {
        guard let popover = popover, let button = statusItem?.button else { return }
        
        // Muestra el popover anclado al botón de la barra de menú con la flecha apuntando hacia arriba
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()
        NSApp.activate(ignoringOtherApps: true)
    }
}

// MARK: - Hosting Controller con Aspecto Liquid Glass

/// Controlador personalizado que configura la apariencia oscura premium
/// y permite que el popover de macOS aplique su fondo de cristal nativo con flecha
class PopoverHostingController<Content: View>: NSHostingController<Content> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Fuerza el modo oscuro dentro del popover para el look Noir premium
        view.appearance = NSAppearance(named: .vibrantDark)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        // Aplica el efecto de cristal oscuro a la ventana subyacente del popover
        if let popoverWindow = view.window {
            popoverWindow.appearance = NSAppearance(named: .vibrantDark)
        }
    }
}
