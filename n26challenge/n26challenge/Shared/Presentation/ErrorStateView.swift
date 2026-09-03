import SwiftUI

struct ErrorStateView: View {
    let model: ErrorPresentationalModel
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: model.systemImage)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text(model.title)
                .font(.headline)
                .multilineTextAlignment(.center)
            Text(model.message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry", action: retry)
                .buttonStyle(.borderedProminent)
                .tint(ColorPalette.accent)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
