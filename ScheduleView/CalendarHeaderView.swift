
import SwiftUI

// 【新增】: 全新的、可复用的日历页眉，仿系统风格
struct CalendarHeaderView: View {
    @Binding var currentDate: Date
    let viewMode: CalendarViewMode
    
    private var title: String {
        let formatter = DateFormatter()
        switch viewMode {
        case .week, .month:
            formatter.dateFormat = "MMMM yyyy"
        case .year:
            formatter.dateFormat = "yyyy"
        }
        return formatter.string(from: currentDate)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack {
                    Button(action: { changeDate(by: -1) }) {
                        Image(systemName: "chevron.left")
                    }
                    .buttonStyle(.plain)
                    
                    Button("Today") {
                        currentDate = Date()
                    }
                    .buttonStyle(.borderless)
                    
                    Button(action: { changeDate(by: 1) }) {
                        Image(systemName: "chevron.right")
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()

            // 只有周视图和月视图需要显示星期几
            if viewMode == .week || viewMode == .month {
                HStack(spacing: 0) {
                    if viewMode == .week {
                        Spacer().frame(width: 60)
                    }
                    ForEach(currentDate.getWeekDates(), id: \.self) { day in
                        VStack {
                            Text(day.getWeekdayShortString())
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            // 只有周视图显示日期数字
                            if viewMode == .week {
                                Text(day.getDayString())
                                    .font(.title3)
                                    .fontWeight(Calendar.current.isDateInToday(day) ? .bold : .regular)
                                    .foregroundStyle(Calendar.current.isDateInToday(day) ? Color.accentColor : .primary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.bottom, 10)
            }
        }
        .background(.bar)
    }
    
    private func changeDate(by value: Int) {
        let component: Calendar.Component
        switch viewMode {
        case .week:
            component = .weekOfYear
        case .month:
            component = .month
        case .year:
            component = .year
        }
        
        if let newDate = Calendar.current.date(byAdding: component, value: value, to: currentDate) {
            currentDate = newDate
        }
    }
}
