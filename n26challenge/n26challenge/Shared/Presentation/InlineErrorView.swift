import SwiftUI

struct InlineErrorView: View {
    let model: ErrorPresentationalModel
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: model.systemImage)
                    .foregroundStyle(ColorPalette.accent)
                VStack(alignment: .leading, spacing: 4) {
                    Text(model.title)
                        .font(.headline)
                    Text(model.message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Button("Retry", action: retry)
                .buttonStyle(.borderedProminent)
                .tint(ColorPalette.accent)
        }
        .padding(.vertical, 6)
    }
}
