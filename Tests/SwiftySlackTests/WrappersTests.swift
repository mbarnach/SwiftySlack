//
//  WrappersTests.swift
//  
//
//  Created by Mathieu Barnachon on 08/08/2019.
//

import XCTest
import Nimble
@testable import SwiftySlack

#if os(macOS) || os(iOS)
import CwlPreconditionTesting
#else
import CwlPosixPreconditionTesting
#endif

// From StackOverflow answer of iAhmed
// https://stackoverflow.com/questions/26845307/generate-random-alphanumeric-string-in-swift
func randomString(length: Int) -> String {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
  return String((0..<length).map{ _ in letters.randomElement()! })
}

func randomArrayOfString(lengthArray: Int, lengthString: Int) -> [String] {
  let array = [String](repeating: "", count: lengthArray)
  return array.compactMap{_ in randomString(length: lengthString) }
}

func arrayLength(element: String) -> Bool {
  element.count <= 10
}

final class WrappersTests: XCTestCase {
  // Text limit
  @TextLimit(10)
  var textLimitWithoutInitial: String
  @TextLimit("", 10)
  var textLimitWithInitialEmpty: String
  @TextLimit(randomString(length: 100), 10)
  var textLimitWithInitialTooLong: String
  // Texts limit
  @TextsLimit(10)
  var textsLimitWithoutInitial: [String]
  @TextsLimit([], 10)
  var textsLimitWithInitialEmpty: [String]
  @TextsLimit(randomArrayOfString(lengthArray: 100, lengthString: 20), 10)
  var textsLimitWithInitialTooLong: [String]
  // Count limit
  @CountLimit(10)
  var countLimitWithoutInitial: [String]
  @CountLimit([], 10)
  var countLimitWithInitialEmpty: [String]
  @CountLimit(randomArrayOfString(lengthArray: 100, lengthString: 20), 10)
  var countLimitWithInitialTooLong: [String]
  // Counts limit
  @CountsLimit(10, 10)
  var countsLimitWithoutInitial: [String]
  @CountsLimit([], 10, 10)
  var countsLimitWithInitialEmpty: [String]
  @CountsLimit(randomArrayOfString(lengthArray: 100, lengthString: 100), 10, 10)
  var countsLimitWithInitialTooLong: [String]
  // Range limit
  @RangeLimit(2, 10)
  var rangeLimitWithoutInitial: [String]
  @RangeLimit(2, 10)
  var rangeLimitWithInitialEmpty: [String]
  @RangeLimit(randomArrayOfString(lengthArray: 100, lengthString: 20), 2, 10)
  var rangeLimitWithInitialTooLong: [String]
  // Cannot be tested since it cannot be caugth.
//  @RangeLimit(randomArrayOfString(lengthArray: 1, lengthString: 20), 2, 10)
//  var rangeLimitWithInitialTooShort: [String]
  
  func testTextLimit() {
    // Without initial
    expect{ self.textLimitWithoutInitial.count } == 0
    textLimitWithoutInitial = randomString(length: 8)
    expect{ self.textLimitWithoutInitial.count } == 8
    textLimitWithoutInitial = randomString(length: 100)
    expect{ self.textLimitWithoutInitial.count } == 10
    // Initial empty
    expect{ self.textLimitWithInitialEmpty.count } == 0
    textLimitWithInitialEmpty = randomString(length: 8)
    expect{ self.textLimitWithInitialEmpty.count } == 8
    textLimitWithInitialEmpty = randomString(length: 100)
    expect{ self.textLimitWithInitialEmpty.count } == 10
    // Initial too long
    expect{ self.textLimitWithInitialTooLong.count } == 10
    textLimitWithInitialTooLong = randomString(length: 8)
    expect{ self.textLimitWithInitialTooLong.count } == 8
    textLimitWithInitialTooLong = randomString(length: 100)
    expect{ self.textLimitWithInitialTooLong.count } == 10
  }
  
  func testTextsLimit() {
    // Without initial
    expect{ self.textsLimitWithoutInitial.count } == 0
    textsLimitWithoutInitial = randomArrayOfString(lengthArray: 8, lengthString: 20)
    expect{ self.textsLimitWithoutInitial.count } == 8
    textsLimitWithoutInitial = randomArrayOfString(lengthArray: 100, lengthString: 20)
    expect{ self.textsLimitWithoutInitial.allSatisfy(arrayLength) } == true
    // Initial empty
    expect{ self.textsLimitWithInitialEmpty.count } == 0
    textsLimitWithInitialEmpty = randomArrayOfString(lengthArray: 8, lengthString: 20)
    expect{ self.textsLimitWithInitialEmpty.allSatisfy(arrayLength) } == true
    textsLimitWithInitialEmpty = randomArrayOfString(lengthArray: 100, lengthString: 20)
    expect{ self.textsLimitWithInitialEmpty.allSatisfy(arrayLength) } == true
    // Initial too long
    expect{ self.textsLimitWithInitialTooLong.allSatisfy(arrayLength) } == true
    textsLimitWithInitialTooLong = randomArrayOfString(lengthArray: 8, lengthString: 20)
    expect{ self.textsLimitWithInitialTooLong.allSatisfy(arrayLength) } == true
    textsLimitWithInitialTooLong = randomArrayOfString(lengthArray: 100, lengthString: 20)
    expect{ self.textsLimitWithInitialTooLong.allSatisfy(arrayLength) } == true
  }
  
  func testCountLimit() {
    // Without initial
    expect{ self.countLimitWithoutInitial.count } == 0
    countLimitWithoutInitial = randomArrayOfString(lengthArray: 8, lengthString: 20)
    expect{ self.countLimitWithoutInitial.count } == 8
    countLimitWithoutInitial = randomArrayOfString(lengthArray: 100, lengthString: 20)
    expect{ self.countLimitWithoutInitial.count } == 10
    // Initial empty
    expect{ self.countLimitWithInitialEmpty.count } == 0
    countLimitWithInitialEmpty = randomArrayOfString(lengthArray: 8, lengthString: 20)
    expect{ self.countLimitWithInitialEmpty.count } == 8
    countLimitWithInitialEmpty = randomArrayOfString(lengthArray: 100, lengthString: 20)
    expect{ self.countLimitWithInitialEmpty.count } == 10
    // Initial too long
    expect{ self.countLimitWithInitialTooLong.count } == 10
    countLimitWithInitialTooLong = randomArrayOfString(lengthArray: 8, lengthString: 20)
    expect{ self.countLimitWithInitialTooLong.count } == 8
    countLimitWithInitialTooLong = randomArrayOfString(lengthArray: 100, lengthString: 20)
    expect{ self.countLimitWithInitialTooLong.count } == 10
  }
  
  func testCountsLimit() {
    // Without initial
    expect{ self.countsLimitWithoutInitial.count } == 0
    expect{ self.countsLimitWithInitialEmpty.allSatisfy(arrayLength) } == true
    countsLimitWithoutInitial = randomArrayOfString(lengthArray: 8, lengthString: 8)
    expect{ self.countsLimitWithoutInitial.count } == 8
    expect{ self.countsLimitWithoutInitial.allSatisfy(arrayLength) } == true
    countsLimitWithoutInitial = randomArrayOfString(lengthArray: 100, lengthString: 100)
    expect{ self.countsLimitWithoutInitial.count } == 10
    expect{ self.countsLimitWithoutInitial.allSatisfy(arrayLength) } == true
    // Initial empty
    expect{ self.countsLimitWithInitialEmpty.count } == 0
    expect{ self.countsLimitWithInitialEmpty.allSatisfy(arrayLength) } == true
    countsLimitWithInitialEmpty = randomArrayOfString(lengthArray: 8, lengthString: 8)
    expect{ self.countsLimitWithInitialEmpty.count } == 8
    expect{ self.countsLimitWithInitialEmpty.allSatisfy(arrayLength) } == true
    countsLimitWithInitialEmpty = randomArrayOfString(lengthArray: 100, lengthString: 100)
    expect{ self.countsLimitWithInitialEmpty.count } == 10
    expect{ self.countsLimitWithInitialEmpty.allSatisfy(arrayLength) } == true
    // Initial too long
    expect{ self.countsLimitWithInitialTooLong.count } == 10
    expect{ self.countsLimitWithInitialTooLong.allSatisfy(arrayLength) } == true
    countsLimitWithInitialTooLong = randomArrayOfString(lengthArray: 8, lengthString: 8)
    expect{ self.countsLimitWithInitialTooLong.allSatisfy(arrayLength) } == true
    expect{ self.countsLimitWithInitialTooLong.count } == 8
    countsLimitWithInitialTooLong = randomArrayOfString(lengthArray: 100, lengthString: 100)
    expect{ self.countsLimitWithInitialTooLong.count } == 10
    expect{ self.countsLimitWithInitialTooLong.allSatisfy(arrayLength) } == true
  }
  
  func testRange() {
    // Without initial
    expect{ self.rangeLimitWithoutInitial.count } == 0
    rangeLimitWithoutInitial = randomArrayOfString(lengthArray: 8, lengthString: 20)
    expect{ self.rangeLimitWithoutInitial.count } == 8
    rangeLimitWithoutInitial = randomArrayOfString(lengthArray: 100, lengthString: 20)
    expect{ self.rangeLimitWithoutInitial.count } == 10
    expect {
      catchBadInstruction {
        self.rangeLimitWithoutInitial = randomArrayOfString(lengthArray: 1, lengthString: 20)
      }
    }.toNot(beNil())
    // Initial empty
    expect{ self.rangeLimitWithInitialEmpty.count } == 0
    rangeLimitWithInitialEmpty = randomArrayOfString(lengthArray: 8, lengthString: 20)
    expect{ self.rangeLimitWithInitialEmpty.count } == 8
    rangeLimitWithInitialEmpty = randomArrayOfString(lengthArray: 100, lengthString: 20)
    expect{ self.rangeLimitWithInitialEmpty.count } == 10
    expect {
      catchBadInstruction {
        self.rangeLimitWithInitialEmpty = randomArrayOfString(lengthArray: 1, lengthString: 20)
      }
    }.toNot(beNil())
    // Initial too long
    expect{ self.rangeLimitWithInitialTooLong.count } == 10
    rangeLimitWithInitialTooLong = randomArrayOfString(lengthArray: 8, lengthString: 20)
    expect{ self.rangeLimitWithInitialTooLong.count } == 8
    rangeLimitWithInitialTooLong = randomArrayOfString(lengthArray: 100, lengthString: 20)
    expect{ self.rangeLimitWithInitialTooLong.count } == 10
    expect {
      catchBadInstruction {
        self.rangeLimitWithInitialTooLong = randomArrayOfString(lengthArray: 1, lengthString: 20)
      }
    }.toNot(beNil())
  }
  
  static var allTests = [
    ("testTextLimit", testTextLimit),
    ("testTextsLimit", testTextsLimit),
    ("testCountLimit", testCountLimit),
    ("testCountsLimit", testCountsLimit),
    ("testRange", testRange),
  ]
}
