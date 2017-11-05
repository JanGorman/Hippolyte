//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import Hippolyte

class RegexMatcherTests: XCTestCase {

  func testRegexMatches() throws {
    let regex = try NSRegularExpression(pattern: "Fo+", options: [])
    let matcher = RegexMatcher(regex: regex)

    XCTAssertTrue(matcher.matches(string: "Foooo"))
    XCTAssertTrue(matcher.matches(string: "Fo"))
  }

  func testRegexWithWrongStringDoesNotMatch() throws {
    let regex = try NSRegularExpression(pattern: "Fo+", options: [])
    let matcher = RegexMatcher(regex: regex)

    XCTAssertFalse(matcher.matches(string: "F"))
    XCTAssertFalse(matcher.matches(string: "Wrong"))
  }

  func testInstancesWithSameRegexMatch() throws {
    let regex = try NSRegularExpression(pattern: "Fo+", options: [])
    let matcher1 = RegexMatcher(regex: regex)
    let matcher2 = RegexMatcher(regex: regex)

    XCTAssertEqual(matcher1, matcher2)
  }

  func testInstancesWithDifferentRegexesDoNotMatch() throws {
    let matcher1 = RegexMatcher(regex: try NSRegularExpression(pattern: "Fo+", options: []))
    let matcher2 = RegexMatcher(regex: try NSRegularExpression(pattern: "Other", options: []))

    XCTAssertNotEqual(matcher1, matcher2)
  }

}
