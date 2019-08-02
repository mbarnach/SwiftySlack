//
//  Conformance.swift
//  
//
//  Created by Mathieu on 13/07/2019.
//

import Foundation


extension String: Stringifiable {
  public func prefix(limit: Int) -> String {
    return String(self.prefix(limit))
  }
  
  public static func Empty() -> String {
    return ""
  }
}

extension Text: Stringifiable {
  public func prefix(limit: Int) -> Self {
    let clipped = Self(self.text.prefix(limit: limit))
    clipped.emoji = self.emoji
    clipped.verbatim = self.verbatim
    return clipped
  }
  
  public static func Empty() -> Self {
    return Self("")
  }
}

extension URL: Stringifiable {
  public func prefix(limit: Int) -> URL {
    return URL(string: self.absoluteString.prefix(limit: limit))!
  }
  
  public static func Empty() -> URL {
    return URL(fileURLWithPath: "", isDirectory: false)
  }
}

extension Optional: Stringifiable where Wrapped: Stringifiable {
  public func prefix(limit: Int) -> Self {
    switch self {
    case .none:
      return Optional.none
    case .some(let wrapped):
      return wrapped.prefix(limit: limit)
    }
  }
  
  public static func Empty() -> Self {
    return Optional.none
  }
}
