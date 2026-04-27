import SwiftUI

struct ViewerSessionView: View {
    @StateObject private var vm: ViewerSessionViewModel

    init(session: PhotoSession, displayName: String) {
        _vm = StateObject(wrappedValue: ViewerSessionViewModel(
            session: session, displayName: displayName
        ))
    }

    var body: some View {
        ZStack {
            Theme.oceanFog.ignoresSafeArea()

            // Live preview slot. Shows mock placeholder until step 2 streams real
            // frames from the host.
            previewLayer
                .ignoresSafeArea()

            LinearGradient(
                colors: [.black.opacity(0.5), .clear, .black.opacity(0.6)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                topBar.padding(.horizontal, 16).padding(.top, 8)
                Spacer()
                bottomBar.padding(.horizontal, 16).padding(.bottom, 24)
            }

            CountdownOverlayView(
                state: vm.countdown.state,
                remainingSeconds: vm.countdown.remainingSeconds
            )

            if let photo = vm.finalPhoto {
                finalOverlay(photo)
                    .transition(.opacity)
            }

            switch vm.status {
            case .connecting: connectingOverlay
            case .ended:      endedOverlay
            case .lost:       statusOverlay(symbol: "wifi.exclamationmark", title: "Verbindung verloren", subtitle: "Captain ist außer Reichweite. Versuch es noch einmal von der Nearby-Liste aus.")
            case .notFound:   statusOverlay(symbol: "questionmark.circle", title: "Session nicht gefunden", subtitle: "Stelle sicher, dass beide im selben WLAN sind und die App offen ist.")
            case .connected:  EmptyView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task { await vm.onAppear() }
        .onDisappear { vm.onDisappear() }
    }

    @ViewBuilder
    private var previewLayer: some View {
        if let img = vm.latestPreviewImage {
            Image(uiImage: img)
                .resizable()
                .scaledToFill()
        } else {
            // Mock placeholder until streaming is wired (Step 2).
            ZStack {
                Theme.abyss
                VStack(spacing: 16) {
                    Image(systemName: "camera.metering.matrix")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundStyle(Theme.gold)
                    Text("Warte auf Captain's Bildausschnitt…")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.mist)
                }
            }
        }
    }

    @Environment(\.dismiss) private var dismiss

    private var topBar: some View {
        HStack(spacing: 10) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(Theme.bone)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .buttonStyle(.plain)

            StatusPill(label: vm.status == .connected ? "VERBUNDEN" : "VERBINDE", systemImage: "antenna.radiowaves.left.and.right", tint: vm.status == .connected ? Theme.signal : Theme.amber)

            Spacer()

            Text(vm.session.id)
                .font(.system(size: 12, weight: .heavy, design: .monospaced))
                .foregroundStyle(Theme.bone)
                .padding(.horizontal, 10).padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
        }
    }

    @ViewBuilder
    private var bottomBar: some View {
        VStack(spacing: 10) {
            if vm.status == .connected && !vm.countdown.state.isActive {
                ReactionPickerView { r in
                    Task { await vm.sendReaction(r) }
                }
            }
            if vm.canTrigger && !vm.countdown.state.isActive {
                PrimaryButton(title: vm.triggerLabel, systemImage: "timer", style: .primary) {
                    Task { await vm.tapTrigger() }
                }
            } else if vm.countdown.state.isActive {
                Text("Stillhalten — gleich klickt's.")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.bone)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
    }

    private var connectingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: 12) {
                ProgressView().tint(Theme.gold)
                Text("Verbinde mit Session…")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.bone)
            }
        }
    }

    private func statusOverlay(symbol: String, title: String, subtitle: String) -> some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            VStack(spacing: 14) {
                Image(systemName: symbol)
                    .font(.system(size: 48))
                    .foregroundStyle(Theme.gold)
                Text(title)
                    .font(Theme.display(22))
                    .foregroundStyle(Theme.bone)
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.mist)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
                PrimaryButton(title: "Schließen", style: .secondary) { dismiss() }
                    .padding(.horizontal, 32)
            }
        }
    }

    private var endedOverlay: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            VStack(spacing: 14) {
                Image(systemName: "flag.checkered")
                    .font(.system(size: 48))
                    .foregroundStyle(Theme.gold)
                Text("Session beendet")
                    .font(Theme.display(24))
                    .foregroundStyle(Theme.bone)
                PrimaryButton(title: "Schließen", style: .secondary) { dismiss() }
                    .padding(.horizontal, 32)
            }
        }
    }

    @ViewBuilder
    private func finalOverlay(_ photo: CapturedPhoto) -> some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 14) {
                if let img = photo.uiImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .padding(.horizontal, 16)
                }
                if vm.session.allowFinalPhotoDownload, let img = photo.uiImage {
                    PrimaryButton(title: "Speichern", systemImage: "square.and.arrow.down", style: .primary) {
                        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
                        Haptics.success()
                    }
                    .padding(.horizontal, 16)
                }
                PrimaryButton(title: "Zurück", style: .ghost) { dismiss() }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
            }
        }
    }
}
