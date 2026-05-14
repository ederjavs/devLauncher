import Foundation

public final class PersistenceManager {
    private static let folderName = "DevLauncher"
    private static let fileName = "launcher_data.json"
    
    private static var fileURL: URL? {
        let fileManager = FileManager.default
        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let folderURL = appSupportURL.appendingPathComponent(folderName, isDirectory: true)
        
        // Crear el folder si no existe
        if !fileManager.fileExists(atPath: folderURL.path) {
            do {
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("⚠️ Error creando el directorio de Application Support: \(error)")
                return nil
            }
        }
        
        return folderURL.appendingPathComponent(fileName)
    }
    
    public static func save(_ data: LauncherData) {
        guard let url = fileURL else { return }
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(data)
            try jsonData.write(to: url, options: .atomic)
        } catch {
            print("❌ Fallo al guardar los datos locales: \(error)")
        }
    }
    
    public static func load() -> LauncherData {
        guard let url = fileURL, FileManager.default.fileExists(atPath: url.path) else {
            // Retornar inicial con categorías por defecto si el archivo no existe
            return LauncherData()
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(LauncherData.self, from: data)
        } catch {
            print("⚠️ Error al decodificar datos persistidos. Cargando valores vacíos: \(error)")
            return LauncherData()
        }
    }
}
