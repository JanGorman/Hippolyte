//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import Foundation

public class Matcher: Hashable {

  func matches(string: String?) -> Bool {
    return false
  }

  func matches(data: Data?) -> Bool {
    return false
  }

  func isEqual(to other: Matcher) -> Bool {
    return false
  }

  public func hash(into hasher: inout Hasher) {
  }

  public static func ==(lhs: Matcher, rhs: Matcher) -> Bool {
    return lhs.isEqual(to: rhs)
  }

}
