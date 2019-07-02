//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import Hippolyte

class DataMatcherTests: XCTestCase {

  func testMatchingDataMatches() {
    let data = Data("data".utf8)
    let matcher = DataMatcher(data: data)

    XCTAssertTrue(matcher.matches(data: data))
  }

  func testMismatchingDataDoesNotMatch() {
    let data = Data("data".utf8)
    let matcher = DataMatcher(data: data)

    XCTAssertFalse(matcher.matches(data: Data("other".utf8)))
  }

  func testInstancesWithSameDataMatch() {
    let data = Data("data".utf8)
    let matcher1 = DataMatcher(data: data)
    let matcher2 = DataMatcher(data: data)

    XCTAssertEqual(matcher1, matcher2)
  }

  func testInstancesWithDifferentDataDoNotMatch() {
    let matcher1 = DataMatcher(data: Data("data".utf8))
    let matcher2 = DataMatcher(data: Data("other".utf8))

    XCTAssertNotEqual(matcher1, matcher2)
  }

}
