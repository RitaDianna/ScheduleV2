import SwiftUI
import SwiftData

/// 用于添加和编辑日程的 Sheet 视图
struct AddScheduleItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let categories: [ScheduleCategory]
    let itemToEdit: ScheduleItem?
    
    // --- 视图状态 ---
    @State private var title: String = ""
    @State private var location: String = ""
    @State private var teacher: String = ""
    @State private var startDate: Date = .now
    @State private var endDate: Date = Date().addingTimeInterval(3600) // 默认1小时时长
    @State private var selectedCategory: ScheduleCategory?
    
    var body: some View {
        VStack {
            Text(itemToEdit == nil ? "添加新日程" : "编辑日程")
                .font(.largeTitle)
                .padding()
            
            Form {
                TextField("标题", text: $title)
                TextField("地点", text: $location)
                TextField("教师 (可选)", text: $teacher)
                
                HStack {
                    Text("分类")
                    Spacer()
                    Menu {
                        Button(action: { selectedCategory = nil }) { Text("无") }
                        
                        ForEach(categories) { category in
                            Button(action: { selectedCategory = category }) {
                                Label(category.name, systemImage: "circle.fill")
                                    .tint(category.color.swiftUIColor)
                            }
                        }
                    } label: {
                        HStack {
                            if let category = selectedCategory {
                                Circle()
                                    .fill(category.color.swiftUIColor)
                                    .frame(width: 12, height: 12)
                                Text(category.name)
                            } else {
                                Text("无")
                            }
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color(.controlBackgroundColor))
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
                
                DatePicker("开始时间", selection: $startDate)
                DatePicker("结束时间", selection: $endDate)
            }
            // 【修复】 当 startDate 改变时，自动调整 endDate，
            // 确保 endDate 始终在 startDate 之后，从根源上防止无效数据。
            .onChange(of: startDate) { oldDate, newDate in
                let duration = endDate.timeIntervalSince(oldDate)
                endDate = newDate.addingTimeInterval(duration)
            }
            
            HStack {
                Button("取消", role: .cancel) { dismiss() }
                if itemToEdit != nil {
                    Button("删除", role: .destructive) { deleteItem(); dismiss() }
                }
                Button("保存") {
                    // 添加最终的保存前验证
                    if endDate > startDate {
                        saveItem()
                        dismiss()
                    } else {
                        // 理论上不会发生，但作为最后的防线
                        print("保存失败：结束时间必须在开始时间之后。")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(title.isEmpty)
            }
            .padding()
        }
        .frame(minWidth: 400, minHeight: 400)
        .onAppear(perform: loadItemData)
    }
    
    private func loadItemData() {
        guard let item = itemToEdit else { return }
        title = item.title
        location = item.location
        teacher = item.teacher ?? ""
        startDate = item.startDate
        endDate = item.endDate
        selectedCategory = item.category
    }
    
    private func saveItem() {
        if let item = itemToEdit {
            item.title = title
            item.location = location
            item.teacher = teacher.isEmpty ? nil : teacher
            item.startDate = startDate
            item.endDate = endDate
            item.category = selectedCategory
        } else {
            let newItem = ScheduleItem(
                title: title,
                location: location,
                teacher: teacher.isEmpty ? nil : teacher,
                startDate: startDate,
                endDate: endDate,
                category: selectedCategory
            )
            modelContext.insert(newItem)
        }
        try? modelContext.save()
    }
    
    private func deleteItem() {
        if let item = itemToEdit {
            modelContext.delete(item)
            try? modelContext.save()
        }
    }
}

