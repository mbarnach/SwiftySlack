//
//  Helpers.swift
//  
//
//  Created by Mathieu Barnachon on 30/07/2019.
//

import XCTest

func jsonEncode<Value: Encodable>(object: Value) -> JSON {
  let jsonEncoder = JSONEncoder()
  jsonEncoder.outputFormatting = .prettyPrinted
  do {
    let jsonData = try jsonEncoder.encode(object)
    return try JSON(data: jsonData)
  } catch let error {
    XCTFail("Unable to encode the object: \(error).")
  }
  return JSON()
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
