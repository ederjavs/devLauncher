import SwiftUI
import AppKit
import KeyboardShortcuts

// Notificación para comunicar cambios de tamaño desde SwiftUI al NSPopover
extension Notification.Name {
    static let popoverShouldResize = Notification.Name("popoverShouldResize")
}

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
    let viewModel = LauncherViewModel()
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        setupStatusItem()
        setupPopover()
        setupGlobalShortcut()
        setupResizeObserver()
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
        pop.contentSize = NSSize(width: 750, height: 200) // Arranca compacto
        pop.behavior = .transient
        pop.animates = true
        pop.appearance = NSAppearance(named: .vibrantDark)
        
        pop.contentViewController = PopoverHostingController(
            rootView: LauncherView(viewModel: viewModel)
        )
        
        self.popover = pop
    }
    
    /// Escucha notificaciones de LauncherView para redimensionar el popover dinámicamente
    private func setupResizeObserver() {
        NotificationCenter.default.addObserver(
            forName: .popoverShouldResize,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let height = notification.userInfo?["height"] as? CGFloat else { return }
            
            let newSize = NSSize(width: 750, height: height)
            // Solo redimensionar si el cambio es significativo (evita loops de layout)
            if abs(self.popover?.contentSize.height ?? 0 - height) > 2 {
                self.popover?.contentSize = newSize
            }
        }
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
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()
        NSApp.activate(ignoringOtherApps: true)
    }
}

// MARK: - Hosting Controller con Aspecto Liquid Glass

class PopoverHostingController<Content: View>: NSHostingController<Content> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.appearance = NSAppearance(named: .vibrantDark)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        if let popoverWindow = view.window {
            popoverWindow.appearance = NSAppearance(named: .vibrantDark)
        }
    }
}
