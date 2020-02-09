//
//  Helpers.swift
//  
//
//  Created by Mathieu Barnachon on 30/07/2019.
//

import XCTest

func jsonEncode<Value: Encodable>(object: Value) -> [String: Any] {
  let jsonEncoder = JSONEncoder()
  jsonEncoder.outputFormatting = .prettyPrinted
  do {
    let jsonData = try jsonEncoder.encode(object)
    let string = String(data: jsonData, encoding: .utf8) ?? "!INVALID!"
    return convert(json: string)
  } catch let error {
    XCTFail("Unable to encode the object: \(error).")
  }
  return [#function: #line]
}

func jsonEncode<Value: Encodable>(object: Value) -> Data? {
  let jsonEncoder = JSONEncoder()
  jsonEncoder.outputFormatting = .prettyPrinted
  do {
    return try jsonEncoder.encode(object)
  } catch let error {
    XCTFail("Unable to encode the object: \(error).")
  }
  return nil
}

func convert(json: String) -> [String: Any] {
  if let data = json.data(using: .utf8) {
    do {
      return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
    } catch {
      XCTFail("Unable to convert to a dictionary: \(error)")
    }
  }
  return [#function: #line]
}

public func ==(lhs: [String: Any], rhs: [String: Any] ) -> Bool {
    return NSDictionary(dictionary: lhs).isEqual(to: rhs)
}
