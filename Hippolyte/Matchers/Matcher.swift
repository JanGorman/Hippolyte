//
//  Copyright © 2017 Jan Gorman. All rights reserved.
//

import Foundation

public class Matcher: Hashable {

  public func matches(string: String?) -> Bool {
    false
  }

  public func matches(data: Data?) -> Bool {
    false
  }

  public func isEqual(to other: Matcher) -> Bool {
    false
  }

  public func hash(into hasher: inout Hasher) {
  }

  public static func ==(lhs: Matcher, rhs: Matcher) -> Bool {
    lhs.isEqual(to: rhs)
  }

}
