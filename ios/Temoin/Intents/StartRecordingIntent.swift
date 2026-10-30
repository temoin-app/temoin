import AppIntents
import Foundation

/// Shared by the app and the widget extension: asks the app to start filming at once.
/// The app registers `handler`; the flag in UserDefaults covers a cold launch.
enum QuickRecord {
    static let defaultsKey = "quick_record_requested"
    static let discreetKey = "quick_record_discreet"
    @MainActor static var handler: (() -> Void)?

    @MainActor static func request(discreet: Bool = false) {
        UserDefaults.standard.set(true, forKey: defaultsKey)
        if discreet { UserDefaults.standard.set(true, forKey: discreetKey) }
        handler?()
    }

    /// True once if the last request asked for the dark screen.
    static func consumeDiscreet() -> Bool {
        let d = UserDefaults.standard
        guard d.bool(forKey: discreetKey) else { return false }
        d.removeObject(forKey: discreetKey)
        return true
    }

    /// True once per request.
    static func consume() -> Bool {
        let d = UserDefaults.standard
        guard d.bool(forKey: defaultsKey) else { return false }
        d.removeObject(forKey: defaultsKey)
        return true
    }
}

/// "Film with Témoin": opens the app and starts a Live recording right away.
/// Usable from Siri, the Shortcuts app, Back Tap, the Action button and the widgets.
struct StartRecordingIntent: AppIntent {
    static var title: LocalizedStringResource = "Filmer"
    static var description = IntentDescription("Ouvre Témoin et commence à filmer immédiatement.")
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        QuickRecord.request()
        return .result()
    }
}

/// Same, with the dark screen from the very first frame.
struct StartDiscreetRecordingIntent: AppIntent {
    static var title: LocalizedStringResource = "Filmer, écran noir"
    static var description = IntentDescription("Commence à filmer immédiatement, écran noir.")
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        QuickRecord.request(discreet: true)
        return .result()
    }
}
