//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import Foundation

public class Matcher: Hashable {

  func matches(string: String?) -> Bool {
    false
  }

  func matches(data: Data?) -> Bool {
    false
  }

  func isEqual(to other: Matcher) -> Bool {
    false
  }

  public func hash(into hasher: inout Hasher) {
  }

  public static func ==(lhs: Matcher, rhs: Matcher) -> Bool {
    lhs.isEqual(to: rhs)
  }

}
