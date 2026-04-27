import SwiftUI

struct QRCodePanelView: View {
    let payload: String
    let sessionID: String
    @State private var didCopy = false

    var body: some View {
        VStack(spacing: 14) {
            QRCodeService.image(string: payload, size: 600)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .padding(14)
                .background(Theme.bone)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .frame(maxWidth: 240)

            VStack(spacing: 4) {
                Text("Code")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(Theme.mist)
                Text(sessionID)
                    .font(.system(size: 22, weight: .black, design: .monospaced))
                    .foregroundStyle(Theme.bone)
                    .textSelection(.enabled)
            }

            Button {
                UIPasteboard.general.string = payload
                Haptics.success()
                didCopy = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { didCopy = false }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: didCopy ? "checkmark" : "link")
                    Text(didCopy ? "Kopiert" : "Link kopieren")
                }
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.bone)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.08))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .liquidGlass()
    }
}
