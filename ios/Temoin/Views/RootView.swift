import SwiftUI

let accent = Color(red: 0.898, green: 0.282, blue: 0.302)
let okGreen = Color(red: 0.188, green: 0.643, blue: 0.424)
let muted = Color(white: 0.62)

struct RootView: View {
    @EnvironmentObject var model: AppModel
    @EnvironmentObject var settings: Settings
    @State private var showSettings = false
    @Environment(\.scenePhase) private var phase
    /// Black until a URL had time to arrive, and in the snapshot iOS shows when coming back:
    /// the dark-screen widget must never reveal the interface, even for one frame.
    @State private var cover = true

    var body: some View {
        Group {
            if settings.server == nil || model.pendingLink != nil {
                OnboardingView()
            } else {
                CaptureView(showSettings: $showSettings)
                    .sheet(isPresented: $showSettings) { SettingsView() }
            }
        }
        .background(Color.black.ignoresSafeArea())
        .overlay { if cover { Color.black.ignoresSafeArea() } }
        .task(id: phase) {
            if phase == .background { cover = true }
            guard phase == .active, cover else { return }
            try? await Task.sleep(nanoseconds: 350_000_000)
            if !Task.isCancelled { cover = false }
        }
    }
}

func formatBytes(_ n: Int64) -> String {
    ByteCountFormatter.string(fromByteCount: n, countStyle: .file)
}
