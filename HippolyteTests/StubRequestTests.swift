//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import Hippolyte

final class StubRequestTests: XCTestCase {

  func testStubRequestsMatch() {
    let stub = StubRequest(method: .GET, url: URL(string: "http://www.apple.com")!)
    let other = StubRequest(method: .GET, url: URL(string: "http://www.apple.com")!)

    XCTAssertEqual(stub, other)
  }

  func testStubRequestsWithDifferentMethodDoNotMatch() {
    let stub = StubRequest(method: .GET, url: URL(string: "http://www.apple.com")!)
    let other = StubRequest(method: .POST, url: URL(string: "http://www.apple.com")!)

    XCTAssertNotEqual(stub, other)
  }

  func testStubRequestsWithDifferentUrlDoNotMatch() {
    let stub = StubRequest(method: .GET, url: URL(string: "http://www.apple.com")!)
    let other = StubRequest(method: .GET, url: URL(string: "http://www.google.com")!)

    XCTAssertNotEqual(stub, other)
  }

  func testStubWithMatcherMatches() throws {
    let matcher = RegexMatcher(regex: try NSRegularExpression(pattern: "^http://www.apple.com", options: []))
    let stub = StubRequest(method: .GET, urlMatcher: matcher)

    let request1 = TestRequest(method: .GET, url: URL(string: "http://www.apple.com/iPhone")!)
    XCTAssertTrue(stub.matchesRequest(request1))

    let request2 = TestRequest(method: .GET, url: URL(string: "foohttp://www.apple.com/iPhone")!)
    XCTAssertFalse(stub.matchesRequest(request2))
  }

  func testHeaderSubsetMatches() {
    var stub = StubRequest(method: .GET, url: URL(string: "http://www.apple.com")!)
    stub.setHeader(key: "X-Foo", value: "Bar")

    var request = TestRequest(method: .GET, url: URL(string: "http://www.apple.com")!)
    request.setHeader(key: "X-Foo", value: "Bar")
    request.setHeader(key: "X-Bar", value: "Foo")

    XCTAssertTrue(stub.matchesRequest(request))
  }

  func testHeaderSupersetDoesNotMatch() {
    var stub = StubRequest(method: .GET, url: URL(string: "http://www.apple.com")!)
    stub.setHeader(key: "X-Foo", value: "Bar")
    stub.setHeader(key: "X-Bar", value: "Foo")

    var request = TestRequest(method: .GET, url: URL(string: "http://www.apple.com")!)
    request.setHeader(key: "X-Foo", value: "Bar")

    XCTAssertFalse(stub.matchesRequest(request))
  }

  func testMismatchedHeadersDoNotMatch() {
    var stub = StubRequest(method: .GET, url: URL(string: "http://www.apple.com")!)
    stub.setHeader(key: "X-Foo", value: "Bar")

    var request = TestRequest(method: .GET, url: URL(string: "http://www.apple.com")!)
    request.setHeader(key: "X-Foo", value: "Foo")

    XCTAssertFalse(stub.matchesRequest(request))
  }

  func testBodyMatches() {
    var stub = StubRequest(method: .GET, url: URL(string: "http://www.apple.com")!)
    stub.bodyMatcher = DataMatcher(data: Data("data".utf8))

    var request = TestRequest(method: .GET, url: URL(string: "http://www.apple.com")!)
    request.body = Data("data".utf8)

    XCTAssertTrue(stub.matchesRequest(request))
  }

  func testNilBodyMatches() {
    let stub = StubRequest(method: .GET, url: URL(string: "http://www.apple.com")!)

    var request = TestRequest(method: .GET, url: URL(string: "http://www.apple.com")!)
    request.body = Data("Foooo".utf8)

    XCTAssertTrue(stub.matchesRequest(request))
  }

  func testBuilderProducesStubs() throws {
    let builder = StubRequest.Builder()

    let stub1 = builder.stubRequest(withMethod: .GET, url: URL(string: "http://www.apple.com")!)
      .addHeader(withKey: "X-Foo", value: "Bar")
      .addResponse(StubResponse())
      .addMatcher(StringMatcher(string: "foo"))
      .build()

    XCTAssertNotNil(stub1)
    XCTAssertFalse(stub1.headers.isEmpty)
    XCTAssertNotNil(stub1.bodyMatcher)

    let matcher = RegexMatcher(regex: try NSRegularExpression(pattern: "^http://www.apple.com", options: []))

    let stub2 = builder.stubRequest(withMethod: .GET, urlMatcher: matcher)
      .addHeader(withKey: "X-Foo", value: "Bar")
      .build()

    XCTAssertNotNil(stub2)
  }

  func testIsHashable() {
    let builder = StubRequest.Builder()
    let stub1 = builder.stubRequest(withMethod: .GET, url: URL(string: "http://www.apple.com")!).build()
    let stub2 = builder.stubRequest(withMethod: .POST, url: URL(string: "http://www.apple.com")!).build()

    let set: Set<StubRequest> = [stub1, stub2]

    XCTAssertEqual(set.count, 2)
  }

}
