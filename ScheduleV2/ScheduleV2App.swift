import SwiftUI
import SwiftData

@main
struct ScheduleV2App: App {
    // 【修复】 1. 创建一个静态的、共享的数据容器
    static let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ScheduleItem.self,
            ScheduleCategory.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // 【修复】 2. 声明 ViewModel 和 AppState
    @StateObject private var appState = AppState()
    @StateObject private var scheduleViewModel: ScheduleViewModel

    // 【修复】 3. 在初始化方法中，使用共享容器的上下文来创建 ViewModel
    init() {
        let modelContext = Self.sharedModelContainer.mainContext
        _scheduleViewModel = StateObject(wrappedValue: ScheduleViewModel(modelContext: modelContext))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // 【修复】 4. 将共享容器和 ViewModel 注入到环境中
        .modelContainer(Self.sharedModelContainer)
        .environmentObject(appState)
        .environmentObject(scheduleViewModel)
    }
}


