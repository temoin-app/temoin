import Foundation
import WidgetKit

/// The secret the widgets put in their srec://record links (QuickRecordLink), shared with them
/// through the app group. nil without the app group (a re-signed sideloaded build): no token then.
enum WidgetToken {
    static let appGroup = "group.io.github.temoin-app.temoin"
    private static let key = "widget_token"

    private static var shared: UserDefaults? {
        guard FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) != nil else { return nil }
        return UserDefaults(suiteName: appGroup)
    }

    /// Widgets: the token the app created, once it has run.
    static var forWidgets: String? { shared?.string(forKey: key) }

    /// App: the token, created on first use; the widgets then reload to put it in their links.
    static func forApp() -> String? {
        guard let defaults = shared else { return nil }
        if let token = defaults.string(forKey: key) { return token }
        let token = (0..<32).map { _ in String(format: "%02x", UInt8.random(in: .min ... .max)) }.joined()
        defaults.set(token, forKey: key)
        WidgetCenter.shared.reloadAllTimelines()
        return token
    }
}
