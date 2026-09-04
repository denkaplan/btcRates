import Foundation
@testable import n26challenge

func requiredAPIDate(_ string: String, file: StaticString = #file, line: UInt = #line) -> Date {
    let components = string.split(separator: "-")
    guard
        components.count == 3,
        let day = Int(components[0]),
        let month = Int(components[1]),
        let year = Int(components[2]),
        let date = Calendar.utc.date(from: DateComponents(year: year, month: month, day: day))
    else {
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
