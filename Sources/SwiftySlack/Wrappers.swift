//
//  Wrappers.swift
//  
//
//  Created by Mathieu on 12/07/2019.
//

import Foundation

public protocol Stringifiable {
  func prefix(limit: Int) -> Self
  static func Empty() -> Self
}

@propertyWrapper
public class TextLimit<Value: Stringifiable> {
  public var value: Value
  let limit: Int
  
  /// Ensure the field is limitted in size.
  /// - Parameter limit: Limit to the value size.
  /// - Note: The initial value is set to `.Empty()`.
  public init(_ limit: Int) {
    self.limit = limit
    self.value = Value.Empty()
  }
  
  /// Ensure the `value` is limitted in size.
  /// - Parameter value: The initial value. It will be clamped to the `limit` if needed.
  /// - Parameter limit: Limit to the value size.
  public init(_ value: Value, _ limit: Int) {
    self.value = value.prefix(limit: limit)
    self.limit = limit
  }
  
  /// Access to the underlying value
  public var wrappedValue: Value {
    get { value }
    set { value = newValue.prefix(limit: limit) }
  }
}

@propertyWrapper
public class TextsLimit<Value: Stringifiable> {
  public var value: [Value]
  let limit: Int
  
  /// Ensure the elements inside the field array are limitted in size.
  /// - Parameter limit: Limit to the elements size.
  /// - Note: The initial value is set to an empty array.
  public init(_ limit: Int) {
    self.value = []
    self.limit = limit
  }
  
  /// Ensure the elements inside the `value` array are limitted in size.
  /// - Parameter value: The initial value
  /// - Parameter limit: Limit to the elements size.
  public init(_ value: [Value], _ limit: Int) {
    self.value = value.compactMap{ $0.prefix(limit: limit) }
    self.limit = limit
  }
  
  /// Access to the underlying value
  public var wrappedValue: [Value] {
    get { value }
    set { value = newValue.compactMap{ $0.prefix(limit: limit) } }
  }
}

@propertyWrapper
public class CountLimit<Element> {
  public var value: [Element]
  let limit: Int
  
  /// Ensure the field array has a limitted size.
  /// - Parameter limit: Limit to the size of the array.
  /// - Note: The initial value is set to an empty array.
  public init(_ limit: Int) {
    self.value = []
    self.limit = limit
  }
  
  /// Ensure the `value` array has a limitted size.
  /// - Parameter value: The initial value.
  /// - Parameter limit: Limit to the size of the array.
  public init(_ value: [Element], _ limit: Int) {
    self.value = Array(value.prefix(limit))
    self.limit = limit
  }
  
  /// Access to the underlying value
  public var wrappedValue: [Element] {
    get { value }
    set { value = Array(newValue.prefix(limit)) }
  }
}

@propertyWrapper
public class CountsLimit<Element: Stringifiable> {
  public var value: [Element]
  let countLimit: Int
  let innerLimit: Int
  
  /// Ensure an array has a limited number of elements, each with a limitted size.
  /// - Parameter countLimit: Limit for the array size.
  /// - Parameter innerLimit: Limit for the inner elements size.
  /// - Note: The initial value is set to an empty array.
  public init(_ countLimit: Int, _ innerLimit: Int) {
    self.value = []
    self.countLimit = countLimit
    self.innerLimit = innerLimit
  }
  
  /// Ensure the `value` array has a limited number of elements, each with a limitted size.
  /// - Parameter value: The initial value
  /// - Parameter countLimit: Limit for the array size.
  /// - Parameter innerLimit: Limit for the inner elements size.
  public init(_ value: [Element], _ countLimit: Int, _ innerLimit: Int) {
    self.value = Array(value.compactMap{ $0.prefix(limit: innerLimit) }.prefix(countLimit))
    self.countLimit = countLimit
    self.innerLimit = innerLimit
  }
  
  /// Access to the underlying value
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
  /// - Parameter min: The minimum number of element in the array.
  /// - Parameter max: The maximum number of elements in the array.
  /// - Note: The initial value is set to an empty array, which may not match the requirement!
  public init(_ min: Int, _ max: Int) {
    self.value = []
    self.max = max
    self.min = min
  }
  
  /// Force and array to have values within a range.
  /// - Parameter value: The initial value.
  /// - Parameter min: The minimum number of element in the array.
  /// - Parameter max: The maximum number of elements in the array.
  /// - Note: On creation, the minimal size is checked and a precondition is thrown if it didn't match.
  public init(_ value: [Element], _ min: Int, _ max: Int) {
    precondition(value.count >= min)
    self.value = Array(value.prefix(max))
    self.max = max
    self.min = min
  }
  
  /// Access to the underlying value
  /// - Note: On set, the minimal size is checked and a precondition is thrown if it didn't match.
  public var wrappedValue: [Element] {
    get { value }
    set {
      precondition(newValue.count >= min)
      value = Array(newValue.prefix(max))
    }
  }
}
