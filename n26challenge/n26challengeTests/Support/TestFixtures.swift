import Foundation
@testable import n26challenge

func requiredAPIDate(_ string: String, file: StaticString = #filePath, line: UInt = #line) -> Date {
    guard let date = DateFormatter.apiDay.date(from: string) else {
        preconditionFailure("Invalid API date fixture: \(string)", file: file, line: line)
    }
    return date
}

func requiredDecimal(_ string: String, file: StaticString = #filePath, line: UInt = #line) -> Decimal {
    guard let decimal = Decimal(string: string) else {
        preconditionFailure("Invalid decimal fixture: \(string)", file: file, line: line)
    }
    return decimal
}

func requiredURL(_ string: String, file: StaticString = #filePath, line: UInt = #line) -> URL {
    guard let url = URL(string: string) else {
        preconditionFailure("Invalid URL fixture: \(string)", file: file, line: line)
    }
    return url
}
