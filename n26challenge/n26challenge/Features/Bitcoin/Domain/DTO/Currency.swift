import Foundation

enum Currency: String, CaseIterable, Identifiable, Sendable {
    case eur
    case usd
    case gbp

    var id: String { code }

    var code: String {
        rawValue.uppercased()
    }

    var apiCode: String {
        rawValue
    }

    var description: String {
        switch self {
        case .eur:
            return "Euro"
        case .usd:
            return "US Dollar"
        case .gbp:
            return "British Pound"
        }
    }

}
