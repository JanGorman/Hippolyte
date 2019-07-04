//
//  Copyright © 2019 Clemens Schulz. All rights reserved.
//

import XCTest
import Hippolyte

class JSONMatcherTests: XCTestCase {

  private struct TestObject: Codable, Hashable {
    let id: Int
    let name: String?
    let foo: Bool
  }

  func testMatchingObjectMatches() throws {
    let object = TestObject(id: 1, name: "name", foo: false)
    let matcher = JsonMatcher<TestObject>(object: object)

    let encoder = JSONEncoder()
    let data = try encoder.encode(object)

    XCTAssertTrue(matcher.matches(data: data))
  }

  func testMismatchingObjectDoesNotMatch() throws {
    let object = TestObject(id: 1, name: "name", foo: false)
    let matcher = JsonMatcher<TestObject>(object: object)

    let otherObject = TestObject(id: 1, name: "other", foo: true)

    let encoder = JSONEncoder()
    let data = try encoder.encode(otherObject)

    XCTAssertFalse(matcher.matches(data: data))
  }

  func testInstancesWithSameObjectMatch() {
    let object = TestObject(id: 1, name: "name", foo: false)
    let matcher1 = JsonMatcher<TestObject>(object: object)
    let matcher2 = JsonMatcher<TestObject>(object: object)

    XCTAssertEqual(matcher1, matcher2)
  }

  func testInstancesWithDifferentObjectDoNotMatch() {
    let object1 = TestObject(id: 1, name: "name", foo: false)
    let matcher1 = JsonMatcher<TestObject>(object: object1)

    let object2 = TestObject(id: 2, name: "other", foo: true)
    let matcher2 = JsonMatcher<TestObject>(object: object2)

    XCTAssertNotEqual(matcher1, matcher2)
  }

}
