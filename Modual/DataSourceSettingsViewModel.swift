import SwiftUI

/// 一个专门用于管理数据源设置表单状态的视图模型。
@MainActor
class DataSourceSettingsViewModel: ObservableObject {
    @Published var scheduleURL: String = ""
    @Published var requiresAuthentication: Bool = false
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
}
