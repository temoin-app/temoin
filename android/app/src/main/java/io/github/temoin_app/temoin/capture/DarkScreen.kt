package io.github.temoin_app.temoin.capture

/**
 * The black screen over the capture screen. It waits a few seconds for a recording to start,
 * then covers it until it stops. It never stays in front of a recording that stopped or could
 * not start, and an error that does not stop the recording (a segment that failed to seal)
 * does not reveal the interface. Same rule as DarkScreen in the iOS TemoinCore.
 */
enum class DarkScreen {
    OFF, WAITING, COVERING;

    fun next(event: DarkEvent): DarkScreen = when (event) {
        is DarkEvent.Requested -> if (event.recording) COVERING else WAITING
        DarkEvent.RecordingStarted -> if (this == WAITING) COVERING else this
        DarkEvent.RecordingStopped -> if (this == COVERING) OFF else this
        DarkEvent.Failed, DarkEvent.TimedOut -> if (this == WAITING) OFF else this
        DarkEvent.Dismissed -> OFF
    }
}

sealed interface DarkEvent {
    /** The widget, the launcher shortcut or the button asked for the black screen. */
    data class Requested(val recording: Boolean) : DarkEvent
    data object RecordingStarted : DarkEvent
    data object RecordingStopped : DarkEvent
    /** The engine reported an error. */
    data object Failed : DarkEvent
    /** No recording a few seconds after the request. */
    data object TimedOut : DarkEvent
    /** Triple tap, or the app left the screen. */
    data object Dismissed : DarkEvent
}
