import SwiftUI

struct PipelineRetryButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label.init("Retry", systemImage: "exclamationmark.arrow.circlepath")
        }
        .buttonStyle(PipelineRetryButtonStyle())
    }
}

private struct PipelineRetryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
#if os(iOS)
            .font(.footnote)
            .padding(6)
#elseif os(macOS)
            .padding(8)
#endif
            .background {
                Capsule().fill(configuration.isPressed ? Color.black.opacity(0.1) : .clear)
                Capsule().stroke(.tint, lineWidth: 2)
            }
            .foregroundStyle(.tint)

    }
}

#Preview {
    PipelineRetryButton(action: {})
}
