//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import XCTest
import Hippolyte

final class HippolyteTests: XCTestCase {

  override func tearDown() {
    super.tearDown()
    Hippolyte.shared.stop()
  }

  func testUnmatchedRequestThrows() {
    let request = TestRequest(method: .GET, url: URL(string: "http://www.apple.com")!)

    XCTAssertThrowsError(try Hippolyte.shared.response(for: request))
  }

  func testMatchedRequest() {
    let url = URL(string: "http://www.apple.com")!
    var stub = StubRequest(method: .GET, url: url)
    let response = StubResponse(statusCode: 404)
    stub.response = response
    Hippolyte.shared.add(stubbedRequest: stub)

    let request = TestRequest(method: .GET, url: url)
    let result = try? Hippolyte.shared.response(for: request)

    XCTAssertEqual(result, response)

    Hippolyte.shared.clearStubs()
  }
    
  func testStopHippolyte() {
    let url = URL(string: "http://www.apple.com")!
    var stub = StubRequest(method: .GET, url: url)
    let response = StubResponse(statusCode: 404)
    stub.response = response
    Hippolyte.shared.add(stubbedRequest: stub)
    
    Hippolyte.shared.stop()
    XCTAssertTrue(Hippolyte.shared.stubbedRequests.isEmpty)
    
    Hippolyte.shared.add(stubbedRequest: stub)
    Hippolyte.shared.start()
    XCTAssertFalse(Hippolyte.shared.stubbedRequests.isEmpty)
    Hippolyte.shared.stop()
    XCTAssertTrue(Hippolyte.shared.stubbedRequests.isEmpty)
    
    Hippolyte.shared.clearStubs()
  }

  func testStubIsReplaceable() {
    let url = URL(string: "http://www.apple.com")!
    var stub1 = StubRequest(method: .GET, url: url)
    let response1 = StubResponse(statusCode: 404)
    stub1.response = response1
    Hippolyte.shared.add(stubbedRequest: stub1)

    var stub2 = StubRequest(method: .GET, url: url)
    let response2 = StubResponse(statusCode: 200)
    stub2.response = response2
    Hippolyte.shared.add(stubbedRequest: stub2)

    let request = TestRequest(method: .GET, url: url)
    let result = try? Hippolyte.shared.response(for: request)

    XCTAssertEqual(result, response2)

    Hippolyte.shared.clearStubs()
  }

  func testItStubsRegularNetworkCall() {
    let url = URL(string: "http://www.apple.com")!
    var stub = StubRequest(method: .GET, url: url)
    var response = StubResponse()
    let body = Data("Hippolyte".utf8)
    response.body = body
    stub.response = response
    Hippolyte.shared.add(stubbedRequest: stub)

    Hippolyte.shared.start()

    let expectation = self.expectation(description: "Stubs network call")
    let session = URLSession(configuration: .default)
    let task = session.dataTask(with: url) { data, _, _ in
      XCTAssertEqual(data, body)
      expectation.fulfill()
    }
    task.resume()

    wait(for: [expectation], timeout: 1)
  }
  
  func testItStubsRedirectNetworkCall() {
    let url = URL(string: "http://www.apple.com")!
    var stub = StubRequest(method: .GET, url: url)
    var response = StubResponse()
    response = StubResponse(statusCode: 301)
    response.headers = ["Location": "https://example.com/not/here"]
    let body = Data("Hippolyte Redirect".utf8)
    response.body = body
    stub.response = response
    Hippolyte.shared.add(stubbedRequest: stub)
    
    Hippolyte.shared.start()
    
    let expectation = self.expectation(description: "Stubs network redirect call")
    let delegate = BlockRedirectDelegate()
    let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
    let task = session.dataTask(with: url) { data, _, _ in
      XCTAssertEqual(data, body)
      expectation.fulfill()
    }
    task.resume()
    wait(for: [expectation], timeout: 1)
    
    XCTAssertEqual(delegate.redirectCallCount, 1)
  }

  func testItDoesNotStubsRedirectNoContent() {
    let url = URL(string: "http://www.apple.com")!
    var stub = StubRequest(method: .GET, url: url)
    var response = StubResponse()
    response = StubResponse(statusCode: 304)
    stub.response = response
    Hippolyte.shared.add(stubbedRequest: stub)

    Hippolyte.shared.start()

    let expectation = self.expectation(description: "Dies not stub network redirect call")
    let delegate = BlockRedirectDelegate()
    let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
    let task = session.dataTask(with: url) { _, _, _ in
      expectation.fulfill()
    }
    task.resume()
    wait(for: [expectation], timeout: 1)

    XCTAssertEqual(delegate.redirectCallCount, 0)
  }

  func testThatHippolyteCouldBePausedAndResumed() {
    let url = URL(string: "http://www.apple.com")!
    var stub = StubRequest(method: .GET, url: url)
    var response = StubResponse()
    let body = Data("Hippolyte".utf8)
    response.body = body
    stub.response = response
    Hippolyte.shared.add(stubbedRequest: stub)

    Hippolyte.shared.start()

    let firstExpectation = self.expectation(description: "Stubs network calls")
    URLSession(configuration: .default).dataTask(with: url) { data, _, _ in
      XCTAssertEqual(data, body)
      firstExpectation.fulfill()
    }.resume()
    wait(for: [firstExpectation], timeout: 1)

    Hippolyte.shared.pause()

    let secondExpectation = self.expectation(description: "Stubs network calls paused")
    URLSession(configuration: .default).dataTask(with: url) { data, _, _ in
      XCTAssertNotEqual(data, body)
      secondExpectation.fulfill()
    }.resume()
    wait(for: [secondExpectation], timeout: 1)

    Hippolyte.shared.resume()

    let thirdExpectation = self.expectation(description: "Stubs network calls resumed")
    URLSession(configuration: .default).dataTask(with: url) { data, _, _ in
      XCTAssertEqual(data, body)
      thirdExpectation.fulfill()
    }.resume()
    wait(for: [thirdExpectation], timeout: 1)
  }
    
  func testDelegateCalledWhenThereIsResponse() {
    let url = URL(string: "http://www.apple.com")!
    var stub = StubRequest(method: .GET, url: url)
    let expectation = self.expectation(description: "Notifies delegate")

    let response = StubResponse.Builder()
        .stubResponse(withStatusCode: 200)
        .addDelegate(TestResponseDelegate {
            expectation.fulfill()
        })
        .build()
    stub.response = response

    Hippolyte.shared.add(stubbedRequest: stub)

    let request = TestRequest(method: .GET, url: url)
    _ = try? Hippolyte.shared.response(for: request)
     
    wait(for: [expectation], timeout: 1)
    Hippolyte.shared.clearStubs()
  }
    
}

final class BlockRedirectDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate {

  var redirectCallCount: Int = 0
  
  func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse,
                  newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
    redirectCallCount += 1
    
    // disables redirect responses
    completionHandler(nil)
  }

}

final class TestResponseDelegate: ResponseDelegate {
    
    private let assertFunction: () -> Void
    
    init(_ assertFunction: @escaping () -> Void) {
        self.assertFunction = assertFunction
    }
    
    func onResponse() {
        assertFunction()
    }
}
