import Foundation

/// srec://record, the link the home screen widgets open to start filming. It carries a random
/// token the app shares with its widgets through the app group: any other app, or a web page,
/// can open srec://record, but without the token it does not start a recording, hidden or not.
public struct QuickRecordLink: Equatable {
    public let discreet: Bool

    public init(discreet: Bool) { self.discreet = discreet }

    /// `token` nil: no app group (a re-signed sideloaded build), so no token on either side.
    public init?(_ url: URL, token: String?) {
        guard url.scheme == "srec", url.host == "record",
              let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? .some([])
        else { return nil }
        if let token, items.first(where: { $0.name == "t" })?.value != token { return nil }
        discreet = items.contains { $0.name == "discreet" && $0.value == "1" }
    }

    public func url(token: String?) -> URL {
        var c = URLComponents()
        c.scheme = "srec"
        c.host = "record"
        let items = (discreet ? [URLQueryItem(name: "discreet", value: "1")] : [])
            + (token.map { [URLQueryItem(name: "t", value: $0)] } ?? [])
        c.queryItems = items.isEmpty ? nil : items
        return c.url!
    }
}
