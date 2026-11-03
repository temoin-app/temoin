/// The black screen over the capture screen. It waits a few seconds for a recording to start,
/// then covers it until it stops. It never stays in front of a recording that stopped or could
/// not start, and an error that does not stop the recording (a segment that failed to seal)
/// does not reveal the interface. Same rule as DarkScreen.kt on Android.
public enum DarkScreen: Hashable {
    case off, waiting, covering

    public func next(_ event: DarkScreenEvent) -> DarkScreen {
        switch event {
        case .requested(let recording): return recording ? .covering : .waiting
        case .recordingStarted: return self == .waiting ? .covering : self
        case .recordingStopped: return self == .covering ? .off : self
        case .failed, .timedOut: return self == .waiting ? .off : self
        case .dismissed: return .off
        }
    }
}

public enum DarkScreenEvent: Hashable {
    /// The widget, the shortcut or the button asked for the black screen.
    case requested(recording: Bool)
    case recordingStarted
    case recordingStopped
    /// The engine reported an error.
    case failed
    /// No recording a few seconds after the request.
    case timedOut
    /// Triple tap, or the app went to the background.
    case dismissed
}
