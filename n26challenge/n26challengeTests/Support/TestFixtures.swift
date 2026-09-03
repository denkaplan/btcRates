import Foundation
@testable import n26challenge

func requiredAPIDate(_ string: String, file: StaticString = #file, line: UInt = #line) -> Date {
    let formatter = DateFormatter()
    formatter.calendar = .utc
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "dd-MM-yyyy"

    guard let date = formatter.date(from: string) else {
        preconditionFailure("Invalid API date fixture: \(string)", file: file, line: line)
    }
    return date
}

func requiredDecimal(_ string: String, file: StaticString = #file, line: UInt = #line) -> Decimal {
    guard let decimal = Decimal(string: string) else {
        preconditionFailure("Invalid decimal fixture: \(string)", file: file, line: line)
    }
    return decimal
}

func requiredURL(_ string: String, file: StaticString = #file, line: UInt = #line) -> URL {
    guard let url = URL(string: string) else {
        preconditionFailure("Invalid URL fixture: \(string)", file: file, line: line)
    }
    return url
}
