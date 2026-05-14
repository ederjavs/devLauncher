import SwiftUI
import AppKit

public final class AppIconLoader {
    /// Obtiene el icono del sistema para una ruta dada como una Image de SwiftUI
    public static func getIcon(forPath path: String) -> Image {
        let workspace = NSWorkspace.shared
        
        // Si el archivo existe en la ruta, obtiene su icono
        if FileManager.default.fileExists(atPath: path) {
            let icon = workspace.icon(forFile: path)
            return Image(nsImage: icon)
        }
        
        // Fallback: Icono genérico de aplicación
        let defaultIcon = workspace.icon(forFileType: "app")
        return Image(nsImage: defaultIcon)
    }
    
    /// Retorna una lista de tuplas (nombre, ruta) de apps instaladas en la máquina para el selector
    public static func scanInstalledApps() -> [(name: String, path: String, bundleId: String?)] {
        let fileManager = FileManager.default
        var apps: [(name: String, path: String, bundleId: String?)] = []
        
        // Escaneamos varios directorios estándar de aplicaciones
        let searchDirs = ["/Applications", "/System/Applications", "/System/Cryptexes/App/System/Applications"]
        
        for baseDir in searchDirs {
            guard let enumerator = fileManager.enumerator(at: URL(fileURLWithPath: baseDir),
                                                          includingPropertiesForKeys: [.isPackageKey],
                                                          options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles]) else {
                continue
            }
            
            for case let fileURL as URL in enumerator {
                if fileURL.pathExtension.lowercased() == "app" {
                    let displayName = fileURL.deletingPathExtension().lastPathComponent
                    let bundleId = Bundle(url: fileURL)?.bundleIdentifier
                    apps.append((name: displayName, path: fileURL.path, bundleId: bundleId))
                }
            }
        }
        
        // Ordenamos alfabéticamente
        return apps.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
