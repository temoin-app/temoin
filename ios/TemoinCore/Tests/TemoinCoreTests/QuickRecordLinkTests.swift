import XCTest
@testable import TemoinCore

final class QuickRecordLinkTests: XCTestCase {
    func testTheWidgetLinksOpenWithTheirToken() {
        for discreet in [false, true] {
            let url = QuickRecordLink(discreet: discreet).url(token: "s3cret")
            XCTAssertEqual(QuickRecordLink(url, token: "s3cret"), QuickRecordLink(discreet: discreet))
        }
    }

    func testAnotherAppOrAWebPageCannotStartARecording() {
        XCTAssertNil(QuickRecordLink(URL(string: "srec://record?discreet=1")!, token: "s3cret"))
        XCTAssertNil(QuickRecordLink(URL(string: "srec://record?discreet=1&t=guess")!, token: "s3cret"))
        XCTAssertNil(QuickRecordLink(URL(string: "srec://record?t=")!, token: "s3cret"))
    }

    func testOnlyRecordLinks() {
        XCTAssertNil(QuickRecordLink(URL(string: "srec://enroll?t=s3cret")!, token: "s3cret"))
        XCTAssertNil(QuickRecordLink(URL(string: "https://record?t=s3cret")!, token: "s3cret"))
    }

    func testDiscreetIsItsOwnParameter() {
        XCTAssertEqual(QuickRecordLink(URL(string: "srec://record?notdiscreet=1&t=s3cret")!, token: "s3cret"), QuickRecordLink(discreet: false))
        XCTAssertEqual(QuickRecordLink(URL(string: "srec://record?t=s3cret&discreet=1")!, token: "s3cret"), QuickRecordLink(discreet: true))
    }

    /// No app group (a re-signed sideloaded build): links carry no token and are accepted as before.
    func testWithoutAnAppGroupTheBareLinkWorks() {
        let url = QuickRecordLink(discreet: true).url(token: nil)
        XCTAssertEqual(url.absoluteString, "srec://record?discreet=1")
        XCTAssertEqual(QuickRecordLink(url, token: nil), QuickRecordLink(discreet: true))
    }
}
