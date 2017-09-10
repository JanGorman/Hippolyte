//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import Foundation

public protocol HTTPStubResponse {
  var statusCode: Int { get }
  var headers: [String: String] { get }
  var body: Data? { get }
}

public struct StubResponse: HTTPStubResponse, Equatable {

  public var statusCode: Int
  public var headers: [String : String]
  public var body: Data?
  public let shouldFail: Bool
  public let error: NSError?

  /// Initialize a default response with statusCode 200 and empty body
  public init() {
    self.init(statusCode: 200)
  }

  /// Initialize a response with error to return
  ///
  /// - Parameter error: `NSError` to return when stubbing
  public init(error: NSError) {
    statusCode = -1
    headers = [:]
    body = nil
    shouldFail = true
    self.error = error
  }

  /// Initialize a response with a different statusCode
  ///
  /// - Parameter statusCode: The statusCode to use when stubbing
  public init(statusCode: Int) {
    self.statusCode = statusCode
    body = "".data(using: .utf8)!
    headers = [:]
    shouldFail = false
    error = nil
  }

  public static func ==(lhs: StubResponse, rhs: StubResponse) -> Bool {
    return lhs.statusCode == rhs.statusCode && lhs.headers == rhs.headers && lhs.body == rhs.body
      && lhs.shouldFail == rhs.shouldFail && lhs.error == rhs.error
  }

}
