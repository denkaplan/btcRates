import Foundation

extension Calendar {
    static var utc: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        guard let timeZone = TimeZone(secondsFromGMT: 0) else {
            preconditionFailure("Unable to create UTC time zone.")
        }
        calendar.timeZone = timeZone
        return calendar
    }

    func requiredDate(byAdding component: Component, value: Int, to date: Date) -> Date {
        guard let result = self.date(byAdding: component, value: value, to: date) else {
            preconditionFailure("Unable to calculate date by adding \(value) \(component) to \(date).")
        }
        return result
    }
}
