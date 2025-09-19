import SwiftUI
import SwiftData

/// 分类管理视图
struct CategorySettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ScheduleCategory.name) private var categories: [ScheduleCategory]
    
    @State private var showingAddSheet = false
    @State private var categoryToEdit: ScheduleCategory?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(categories) { category in
                    HStack {
                        Circle()
                            // 【修复】: 将 CodableColor 转换为 SwiftUI.Color
                            .fill(category.color.swiftUIColor)
                            .frame(width: 12, height: 12)
                        Text(category.name)
                        Spacer()
                        // 【修复】: 修正属性名称
                        Text("\(category.scheduleItems?.count ?? 0) 项")
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        categoryToEdit = category
                    }
                }
                .onDelete(perform: deleteCategory)
            }
            .navigationTitle("分类管理")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddSheet = true }) {
                        Label("添加分类", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                // 【修复】: 传入正确的默认颜色类型
                CategoryEditView(category: nil, defaultColor: CodableColor(color: .blue))
            }
            .sheet(item: $categoryToEdit) { category in
                CategoryEditView(category: category, defaultColor: category.color)
            }
        }
    }
    
    private func deleteCategory(at offsets: IndexSet) {
        for index in offsets {
            let category = categories[index]
            modelContext.delete(category)
        }
    }
}

/// 用于添加和编辑分类的 Sheet 视图
private struct CategoryEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var category: ScheduleCategory?
    
    @State private var name: String = ""
    // 【修复】: 这个 State 变量用于保存 CodableColor
    @State private var selectedCodableColor: CodableColor
    // 【修复】: 这个 State 变量专门用于 ColorPicker
    @State private var colorPickerColor: Color
    
    init(category: ScheduleCategory?, defaultColor: CodableColor) {
        self.category = category
        // 初始化两个 State 变量
        _name = State(initialValue: category?.name ?? "")
        _selectedCodableColor = State(initialValue: category?.color ?? defaultColor)
        _colorPickerColor = State(initialValue: category?.color.swiftUIColor ?? defaultColor.swiftUIColor)
    }
    
    var body: some View {
        VStack {
            Text(category == nil ? "新分类" : "编辑分类")
                .font(.largeTitle)
                .padding()
            
            Form {
                TextField("分类名称", text: $name)
                // 【修复】: ColorPicker 绑定到 colorPickerColor (SwiftUI.Color)
                ColorPicker("选择颜色", selection: $colorPickerColor)
            }
            // 【修复】: 监听 colorPickerColor 的变化
            .onChange(of: colorPickerColor) { newColor in
                // 当 SwiftUI Color 变化时，将其转换为 CodableColor 并保存
                self.selectedCodableColor = CodableColor(color: newColor)
            }
            
            HStack {
                Button("取消", role: .cancel) { dismiss() }
                Button("保存") { save(); dismiss() }
                    .buttonStyle(.borderedProminent)
                    .disabled(name.isEmpty)
            }
            .padding()
        }
        .frame(minWidth: 300, minHeight: 250)
    }
    
    private func save() {
        if let category {
            category.name = name
            // 【修复】: 保存正确的 CodableColor
            category.color = selectedCodableColor
        } else {
            // 【修复】: 使用正确的 CodableColor 创建新分类
            let newCategory = ScheduleCategory(name: name, color: selectedCodableColor)
            modelContext.insert(newCategory)
        }
    }
}

