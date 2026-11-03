import XCTest
@testable import TemoinCore

final class DarkScreenTests: XCTestCase {
    private func after(_ start: DarkScreen, _ events: DarkScreenEvent...) -> DarkScreen {
        events.reduce(start) { $0.next($1) }
    }

    func testWidgetCoversTheRecordingOnceItStarts() {
        XCTAssertEqual(after(.off, .requested(recording: false)), .waiting)
        XCTAssertEqual(after(.off, .requested(recording: false), .recordingStarted), .covering)
    }

    func testAnErrorDuringTheRecordingKeepsTheScreenBlack() {
        XCTAssertEqual(after(.covering, .failed), .covering)
    }

    func testARecordingThatStopsUncoversTheScreen() {
        XCTAssertEqual(after(.covering, .recordingStopped), .off)
    }

    func testARecordingThatCannotStartUncoversTheScreen() {
        XCTAssertEqual(after(.waiting, .failed), .off)
        XCTAssertEqual(after(.waiting, .timedOut), .off)
    }

    func testTheWaitOnlyLimitsTheStart() {
        XCTAssertEqual(after(.covering, .timedOut), .covering)
        XCTAssertEqual(after(.waiting, .recordingStopped), .waiting)
    }

    func testTheButtonDuringARecordingCoversAtOnceAndTheTripleTapLeaves() {
        XCTAssertEqual(after(.off, .requested(recording: true)), .covering)
        XCTAssertEqual(after(.covering, .dismissed), .off)
        XCTAssertEqual(after(.waiting, .dismissed), .off)
    }

    func testNothingButARequestTurnsTheScreenBlack() {
        for e: DarkScreenEvent in [.recordingStarted, .recordingStopped, .failed, .timedOut, .dismissed] {
            XCTAssertEqual(DarkScreen.off.next(e), .off, "\(e)")
        }
    }
}
