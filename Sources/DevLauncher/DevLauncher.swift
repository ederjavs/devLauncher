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

// MARK: - Subclase Personalizada de NSPanel para permitir el Foco del Teclado
class FloatingPanel: NSPanel {
    // Clave absoluta para que la barra de búsqueda y sheets puedan recibir escritura de teclado
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

// MARK: - AppDelegate

public final class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var panel: FloatingPanel? // Actualizado a nuestra subclase
    let viewModel = LauncherViewModel()
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Oculta ícono de Dock
        NSApp.setActivationPolicy(.accessory)
        
        setupStatusItem()
        setupPanel()
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
    
    private func setupPanel() {
        // Usamos nuestra subclase FloatingPanel en lugar de NSPanel genérico
        let windowPanel = FloatingPanel(
            contentRect: NSRect(x: 0, y: 0, width: 750, height: 520),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        windowPanel.isFloatingPanel = true
        windowPanel.level = .floating
        windowPanel.backgroundColor = .clear // Fondo base transparente
        windowPanel.isOpaque = false         // Permite que los pixeles transparentes pasen
        windowPanel.isMovable = false
        windowPanel.hasShadow = false         // SwiftUI maneja su propia sombra premium
        windowPanel.isReleasedWhenClosed = false
        windowPanel.hidesOnDeactivate = true
        
        let rootView = LauncherView(viewModel: viewModel)
        windowPanel.contentView = NSHostingView(rootView: rootView)
        
        self.panel = windowPanel
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(panelDidResignKey),
            name: NSWindow.didResignKeyNotification,
            object: windowPanel
        )
    }
    
    private func setupGlobalShortcut() {
        KeyboardShortcuts.onKeyUp(for: .toggleLauncher) { [weak self] in
            self?.togglePanel()
        }
    }
    
    @objc private func statusItemClicked() {
        togglePanel()
    }
    
    @objc private func panelDidResignKey() {
        hidePanel()
    }
    
    public func togglePanel() {
        guard let panel = panel else { return }
        
        if panel.isVisible {
            hidePanel()
        } else {
            showPanel()
        }
    }
    
    private func showPanel() {
        guard let panel = panel, let button = statusItem?.button else { return }
        
        if let window = button.window {
            let buttonFrame = window.frame
            let panelFrame = panel.frame
            
            let xPos = buttonFrame.origin.x + (buttonFrame.width / 2) - (panelFrame.width / 2)
            let yPos = buttonFrame.origin.y - panelFrame.height - 6 // Separación premium de 6px
            
            panel.setFrameOrigin(NSPoint(x: xPos, y: yPos))
        }
        
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func hidePanel() {
        panel?.orderOut(nil)
    }
}
