import Foundation

public struct LauncherData: Codable {
    public var categories: [AppCategory]
    public var apps: [AppItem]
    public var meetings: [MeetingLink]
    
    public init(categories: [AppCategory] = AppCategory.defaultCategories,
                apps: [AppItem] = [],
                meetings: [MeetingLink] = []) {
        self.categories = categories
        self.apps = apps
        self.meetings = meetings
    }
}
