import SwiftUI
import SwiftData

// 【重大更新】: 全功能的年视图
struct YearCalendarView: View {
    @Binding var currentDate: Date
    private let calendar = Calendar.current
    private let months: [Date]
    
    init(currentDate: Binding<Date>) {
        self._currentDate = currentDate
        self.months = currentDate.wrappedValue.getMonthsInYear()
    }

    var body: some View {
        VStack(spacing: 0) {
            CalendarHeaderView(currentDate: $currentDate, viewMode: .year)
            
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 20) {
                    ForEach(months, id: \.self) { month in
                        YearMonthView(month: month, currentDate: $currentDate)
                    }
                }
                .padding()
            }
        }
    }
}

// 年视图中的单月视图
struct YearMonthView: View {
    let month: Date
    @Binding var currentDate: Date
    private let days: [Date]
    private let calendar = Calendar.current
    
    init(month: Date, currentDate: Binding<Date>) {
        self.month = month
        self._currentDate = currentDate
        self.days = month.getDaysInMonth()
    }
    
    var body: some View {
        VStack {
            Text(month.getMonthString())
                .font(.headline)
                .padding(.bottom, 5)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(days, id: \.self) { day in
                    Text(day.getDayString())
                        .font(.caption)
                        .foregroundColor(foregroundColor(for: day))
                        .frame(width: 20, height: 20)
                        .background(backgroundColor(for: day).clipShape(Circle()))
                }
            }
        }
    }
    
    private func foregroundColor(for day: Date) -> Color {
        if calendar.isDateInToday(day) { return .white }
        if calendar.isDate(day, equalTo: month, toGranularity: .month) { return .primary }
        return .secondary
    }
    
    private func backgroundColor(for day: Date) -> Color {
        if calendar.isDateInToday(day) { return .red }
        return .clear
    }
}

