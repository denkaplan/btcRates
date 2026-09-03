import Foundation

extension Decimal {
    var asNumber: NSDecimalNumber { NSDecimalNumber(decimal: self) }
}
