//
//  Copyright © 2019 Jan Gorman. All rights reserved.
//

import Foundation

public final class StringMatcher: Matcher {

  let string: String

  public init(string: String) {
    self.string = string
  }

  public override func matches(string: String?) -> Bool {
    return self.string == string
  }

  public override func matches(data: Data?) -> Bool {
    return self.string.data(using: .utf8) == data
  }

  public override func hash(into hasher: inout Hasher) {
    hasher.combine(string)
  }

  override func isEqual(to other: Matcher) -> Bool {
    if let theOther = other as? StringMatcher {
      return theOther.string == string
    }
    return false
  }

}
