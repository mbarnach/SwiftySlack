//
//  Wrappers.swift
//  
//
//  Created by Mathieu on 12/07/2019.
//

import Foundation

@propertyWrapper
class Clamping<Value: Comparable> {
  var value: Value
  let range: ClosedRange<Value>
  
  init(initialValue value: Value, _ range: ClosedRange<Value>) {
    precondition(range.contains(value))
    self.value = value
    self.range = range
  }
  
  var wrappedValue: Value {
    get { value }
    set { value = min(max(range.lowerBound, newValue), range.upperBound) }
  }
}

public protocol Stringifiable {
  func prefix(limit: Int) -> Self
  static func Empty() -> Self
}

@propertyWrapper
public class TextLimit<Value: Stringifiable> {
  public var value: Value
  let limit: Int
  
  public init(_ limit: Int) {
    self.limit = limit
    self.value = Value.Empty()
  }
  
  public init(initialValue value: Value, _ limit: Int) {
    self.value = value.prefix(limit: limit)
    self.limit = limit
  }
  
  public var wrappedValue: Value {
    get { value }
    set { value = newValue.prefix(limit: limit) }
  }
}

@propertyWrapper
public class TextsLimit<Value: Stringifiable> {
  public var value: [Value]
  let limit: Int
  
  public init(_ limit: Int) {
    self.value = []
    self.limit = limit
  }
  
  public init(initialValue value: [Value], _ limit: Int) {
    self.value = value.compactMap{ $0.prefix(limit: limit) }
    self.limit = limit
  }
  
  public var wrappedValue: [Value] {
    get { value }
    set { value = newValue.compactMap{ $0.prefix(limit: limit) } }
  }
}

@propertyWrapper
public class CountLimit<Element> {
  public var value: [Element]
  let limit: Int
  
  public init(_ limit: Int) {
    self.value = []
    self.limit = limit
  }
  
  public init(initialValue value: [Element], _ limit: Int) {
    self.value = Array(value.prefix(limit))
    self.limit = limit
  }
  
  public var wrappedValue: [Element] {
    get { value }
    set { value = Array(newValue.prefix(limit)) }
  }
}

@propertyWrapper
public class CountLimits<Element: Stringifiable> {
  public var value: [Element]
  let countLimit: Int
  let innerLimit: Int
  
  public init(_ countLimit: Int, _ innerLimit: Int) {
    self.value = []
    self.countLimit = countLimit
    self.innerLimit = innerLimit
  }
  
  public init(initialValue value: [Element], _ countLimit: Int, _ innerLimit: Int) {
    self.value = Array(value.compactMap{ $0.prefix(limit: innerLimit) }.prefix(countLimit))
    self.countLimit = countLimit
    self.innerLimit = innerLimit
  }
  
  public var wrappedValue: [Element] {
    get { value }
    set {
      value = Array(newValue.compactMap{
        $0.prefix(limit: innerLimit)
      }.prefix(countLimit))
    }
  }
}

@propertyWrapper
public class RangeLimit<Element> {
  public var value: [Element]
  let max: Int
  let min: Int
  
  /// Force and array to have values within a range.
  /// - Parameter value: The initial value.
  /// - Parameter min: The minimum number of element in the array.
  /// - Parameter max: The maximum number of elements in the array.
  /// - Note: On creation, the minimal size is not checked due to the need of having a value in creation. This is (in my opinion) a limitation of the approach.
  public init(initialValue value: [Element], _ min: Int, _ max: Int) {
    self.value = Array(value.prefix(max))
    self.max = max
    self.min = min
  }
  
  public var wrappedValue: [Element] {
    get { value }
    set {
      precondition(newValue.count >= min)
      value = Array(newValue.prefix(max))
    }
  }
}
