import SwiftUI
import SwiftData

// 用于添加和编辑日程的 Sheet 视图 (保持不变)
struct AddScheduleItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var item: ScheduleItem?
    
    @State private var title: String = ""
    @State private var location: String = ""
    @State private var teacher: String = ""
    @State private var startDate: Date = .now
    @State private var endDate: Date = Date().addingTimeInterval(3600)
    
    var body: some View {
        VStack {
            Text(item == nil ? "添加新日程" : "编辑日程")
                .font(.largeTitle)
                .padding()

            Form {
                TextField("标题", text: $title)
                TextField("地点", text: $location)
                TextField("教师 (可选)", text: $teacher)
                DatePicker("开始时间", selection: $startDate)
                DatePicker("结束时间", selection: $endDate)
            }
            
            HStack {
                Button("取消", role: .cancel) { dismiss() }
                if item != nil {
                    Button("删除", role: .destructive) { deleteItem(); dismiss() }
                }
                Button("保存") { saveItem(); dismiss() }.buttonStyle(.borderedProminent)
            }.padding()
        }
        .frame(minWidth: 400, minHeight: 400)
        .onAppear(perform: loadItemData)
    }
    
    private func loadItemData() {
        guard let item = item else { return }
        title = item.title; location = item.location; teacher = item.teacher ?? ""; startDate = item.startDate; endDate = item.endDate
    }
    
    private func saveItem() {
        if let item = item {
            item.title = title; item.location = location; item.teacher = teacher.isEmpty ? nil : teacher; item.startDate = startDate; item.endDate = endDate
        } else {
            let newItem = ScheduleItem(title: title, location: location, teacher: teacher.isEmpty ? nil : teacher, startDate: startDate, endDate: endDate)
            modelContext.insert(newItem)
        }
        try? modelContext.save()
    }
    
    private func deleteItem() {
        if let item = item { modelContext.delete(item); try? modelContext.save() }
    }
}


// Popover 视图
struct AddScheduleItemPopoverView: View {
    @Environment(\.modelContext) private var modelContext
    
    // 【修复】: 不再需要 viewModel，因为所有信息都通过 init 传入
    // @EnvironmentObject var viewModel: AppViewModel
    
    let onClose: () -> Void
    
    @State private var title: String = "新事件"
    @State private var location: String = ""
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var selectedTab = 0

    // 【修复】: 自定义初始化方法，接收所有需要的参数
    init(startDate: Date, endDate: Date, onClose: @escaping () -> Void) {
        // 使用传入的参数来初始化 @State 变量
        self._startDate = State(initialValue: startDate)
        self._endDate = State(initialValue: endDate)
        self.onClose = onClose
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("类型", selection: $selectedTab) {
                Text("事件").tag(0)
                Text("提醒").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            
            Divider()

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Rectangle().fill(Color.accentColor).frame(width: 4, height: 20)
                    TextField("新事件", text: $title)
                        .textFieldStyle(.plain)
                        .font(.system(size: 18, weight: .medium))
                }
                
                PopoverInputRow(imageName: "mappin.and.ellipse", placeholder: "添加地点", text: $location)
                Divider()
                VStack(alignment: .leading) {
                    DatePicker("开始", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("结束", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                }.labelsHidden()
                Divider()
                
                PopoverPlaceholderRow(imageName: "bell", text: "提醒、重复、出行时间")
                PopoverPlaceholderRow(imageName: "person.2", text: "添加受邀人")
                PopoverPlaceholderRow(imageName: "note.text", text: "添加备忘录、URL 或附件")
            }
            .padding()
            
            Spacer()
            
            HStack {
                Spacer()
                Button("添加") {
                    saveItem()
                    onClose() // 调用 onClose 回调来关闭窗口
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(width: 320)
        .background(.bar)
    }
    
    private func saveItem() {
        let newItem = ScheduleItem(title: title, location: location, startDate: startDate, endDate: endDate)
        modelContext.insert(newItem)
        try? modelContext.save()
    }
}

// 辅助视图：带输入框的行
struct PopoverInputRow: View {
    let imageName: String; let placeholder: String; @Binding var text: String
    var body: some View {
        HStack {
            Image(systemName: imageName).foregroundColor(.secondary).frame(width: 20)
            TextField(placeholder, text: $text).textFieldStyle(.plain)
        }
    }
}

// 辅助视图：纯占位符的行
struct PopoverPlaceholderRow: View {
    let imageName: String; let text: String
    var body: some View {
        HStack {
            Image(systemName: imageName).foregroundColor(.secondary).frame(width: 20)
            Text(text).foregroundColor(.secondary)
            Spacer()
        }
    }
}

