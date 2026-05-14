import SwiftUI
import AppKit
import Combine

public final class LauncherViewModel: ObservableObject {
    @Published public var categories: [AppCategory] = []
    @Published public var apps: [AppItem] = []
    @Published public var meetings: [MeetingLink] = []
    
    // Estado de filtros y búsqueda
    @Published public var searchText: String = ""
    
    // Lista caché de apps del sistema escaneadas
    @Published public var scannedSystemApps: [(name: String, path: String, bundleId: String?)] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        loadAllData()
        setupAutoSave()
    }
    
    // MARK: - Data Loading & Autosave
    
    public func loadAllData() {
        let data = PersistenceManager.load()
        self.categories = data.categories.isEmpty ? AppCategory.defaultCategories : data.categories
        self.apps = data.apps
        self.meetings = data.meetings
    }
    
    private func setupAutoSave() {
        // Observa cualquier cambio en las propiedades publicadas y guarda a disco con debounce
        Publishers.CombineLatest3($categories, $apps, $meetings)
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] (newCategories, newApps, newMeetings) in
                let data = LauncherData(categories: newCategories, apps: newApps, meetings: newMeetings)
                PersistenceManager.save(data)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Scan Engine
    
    public func scanSystemIfNeeded() {
        if scannedSystemApps.isEmpty {
            // Hacerlo en background para no trabar la UI
            DispatchQueue.global(qos: .userInitiated).async {
                let detected = AppIconLoader.scanInstalledApps()
                DispatchQueue.main.async {
                    self.scannedSystemApps = detected
                }
            }
        }
    }
    
    // MARK: - CRUD Apps
    
    public func addApp(name: String, path: String, bundleId: String?, categoryId: UUID) {
        let newItem = AppItem(name: name, bundleIdentifier: bundleId, path: path, categoryId: categoryId)
        apps.append(newItem)
    }
    
    public func removeApp(_ app: AppItem) {
        apps.removeAll { $0.id == app.id }
    }
    
    public func launchApp(_ app: AppItem) {
        let fileURL = URL(fileURLWithPath: app.path)
        let configuration = NSWorkspace.OpenConfiguration()
        
        NSWorkspace.shared.openApplication(at: fileURL, configuration: configuration) { _, error in
            if let error = error {
                print("❌ Error al abrir la aplicación: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - CRUD Meetings
    
    public func addMeeting(name: String, urlString: String) {
        // Asegurarse que el esquema http/https existe
        var formattedUrl = urlString
        if !formattedUrl.lowercased().hasPrefix("http://") && !formattedUrl.lowercased().hasPrefix("https://") {
            formattedUrl = "https://" + formattedUrl
        }
        let newLink = MeetingLink(name: name, url: formattedUrl)
        meetings.append(newLink)
    }
    
    public func updateMeeting(_ meeting: MeetingLink) {
        if let index = meetings.firstIndex(where: { $0.id == meeting.id }) {
            meetings[index] = meeting
        }
    }
    
    public func removeMeeting(_ meeting: MeetingLink) {
        meetings.removeAll { $0.id == meeting.id }
    }
    
    public func openMeeting(_ meeting: MeetingLink) {
        guard let url = URL(string: meeting.url) else { return }
        NSWorkspace.shared.open(url)
    }
    
    // MARK: - CRUD Categories
    
    public func addCategory(name: String, iconName: String) {
        let category = AppCategory(name: name, iconName: iconName)
        categories.append(category)
    }
    
    public func removeCategory(_ category: AppCategory) {
        // Evitar borrar todas las categorías si es la única
        guard categories.count > 1 else { return }
        
        // Eliminar las apps pertenecientes a esta categoría
        apps.removeAll { $0.categoryId == category.id }
        
        // Eliminar la categoría
        categories.removeAll { $0.id == category.id }
    }
    
    public func updateCategory(_ category: AppCategory) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
        }
    }
    
    // MARK: - Getters y Filtros
    
    public func filteredApps(for categoryId: UUID) -> [AppItem] {
        let catApps = apps.filter { $0.categoryId == categoryId }
        
        if searchText.isEmpty {
            return catApps
        }
        
        return catApps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    public var filteredMeetings: [MeetingLink] {
        if searchText.isEmpty {
            return meetings
        }
        return meetings.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.url.localizedCaseInsensitiveContains(searchText) }
    }
}
