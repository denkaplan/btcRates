import SwiftUI
import UIKit

enum ColorPalette {
    static let accentUIColor = UIColor(red: 0.05, green: 0.58, blue: 0.34, alpha: 1)
    static let accent = Color(accentUIColor)
    static let accentDark = Color(red: 0.02, green: 0.38, blue: 0.24)
    static let accentLight = Color(red: 0.38, green: 0.78, blue: 0.47)

    static let accentGradient = LinearGradient(
        colors: [accentDark, accent, accentLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
