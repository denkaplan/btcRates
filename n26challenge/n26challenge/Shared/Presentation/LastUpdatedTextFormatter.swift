import Foundation

@MainActor
protocol LastUpdatedTextFormatter {
    func string(from date: Date) -> String
}

struct LastUpdatedTextFormatterImpl: LastUpdatedTextFormatter {
    func string(from date: Date) -> String {
        "Updated " + date.formatted(.lastUpdatedTime)
    }
}
