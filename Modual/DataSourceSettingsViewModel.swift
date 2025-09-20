import SwiftUI

/// 一个专门用于管理数据源设置表单状态的视图模型。
@MainActor
class DataSourceSettingsViewModel: ObservableObject {
    @Published var scheduleURL: String = ""                 // 教务系统的URL
    @Published var requiresAuthentication: Bool = false     // 是否需要使用账号与密码验证
    @Published var username: String = ""                    // 教务系统的登录账号
    @Published var password: String = ""                    // 教务系统的登录密码
    @Published var isLoading: Bool = false                  // 获取
}
