import Foundation

extension FormatStyle where Self == Date.VerbatimFormatStyle {
    static var apiDay: Self {
        Date.VerbatimFormatStyle(
            format: "\(day: .twoDigits)-\(month: .twoDigits)-\(year: .defaultDigits)",
            locale: Locale(identifier: "en_US_POSIX"),
            timeZone: TimeZone(secondsFromGMT: 0)!,
            calendar: .utc
        )
    }
}

extension FormatStyle where Self == Date.FormatStyle {
    static var displayDay: Self {
        Date.FormatStyle(
            date: .abbreviated,
            time: .omitted,
            locale: .current,
            calendar: .current,
            timeZone: .current
        )
    }

    static var lastUpdatedTime: Self {
        Date.FormatStyle(
            date: .omitted,
            time: .shortened,
            locale: .current,
            calendar: .current,
            timeZone: .current
        )
    }
}
