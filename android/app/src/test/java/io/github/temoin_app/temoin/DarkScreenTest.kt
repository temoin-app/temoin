package io.github.temoin_app.temoin

import io.github.temoin_app.temoin.capture.DarkEvent
import io.github.temoin_app.temoin.capture.DarkScreen
import org.junit.Assert.assertEquals
import org.junit.Test

class DarkScreenTest {
    private fun DarkScreen.after(vararg events: DarkEvent) = events.fold(this) { s, e -> s.next(e) }

    @Test
    fun widgetCoversTheRecordingOnceItStarts() {
        assertEquals(DarkScreen.WAITING, DarkScreen.OFF.after(DarkEvent.Requested(recording = false)))
        assertEquals(DarkScreen.COVERING, DarkScreen.OFF.after(DarkEvent.Requested(recording = false), DarkEvent.RecordingStarted))
    }

    @Test
    fun anErrorDuringTheRecordingKeepsTheScreenBlack() {
        assertEquals(DarkScreen.COVERING, DarkScreen.COVERING.after(DarkEvent.Failed))
    }

    @Test
    fun aRecordingThatStopsUncoversTheScreen() {
        assertEquals(DarkScreen.OFF, DarkScreen.COVERING.after(DarkEvent.RecordingStopped))
    }

    @Test
    fun aRecordingThatCannotStartUncoversTheScreen() {
        assertEquals(DarkScreen.OFF, DarkScreen.WAITING.after(DarkEvent.Failed))
        assertEquals(DarkScreen.OFF, DarkScreen.WAITING.after(DarkEvent.TimedOut))
    }

    @Test
    fun theWaitOnlyLimitsTheStart() {
        assertEquals(DarkScreen.COVERING, DarkScreen.COVERING.after(DarkEvent.TimedOut))
        assertEquals(DarkScreen.WAITING, DarkScreen.WAITING.after(DarkEvent.RecordingStopped))
    }

    @Test
    fun theButtonDuringARecordingCoversAtOnceAndTheTripleTapLeaves() {
        assertEquals(DarkScreen.COVERING, DarkScreen.OFF.after(DarkEvent.Requested(recording = true)))
        assertEquals(DarkScreen.OFF, DarkScreen.COVERING.after(DarkEvent.Dismissed))
        assertEquals(DarkScreen.OFF, DarkScreen.WAITING.after(DarkEvent.Dismissed))
    }

    @Test
    fun nothingButARequestTurnsTheScreenBlack() {
        for (e in listOf(DarkEvent.RecordingStarted, DarkEvent.RecordingStopped, DarkEvent.Failed, DarkEvent.TimedOut, DarkEvent.Dismissed)) {
            assertEquals(e.toString(), DarkScreen.OFF, DarkScreen.OFF.next(e))
        }
    }
}
