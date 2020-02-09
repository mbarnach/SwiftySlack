//
//  CompositionTests.swift
//  
//
//  Created by Mathieu Barnachon on 14/07/2019.
//


import XCTest
import Nimble
@testable import SwiftySlack

final class CompositionTests: XCTestCase {
  
  func testSimpleText() {
    let text = Text("A message *with some bold text* and _some italicized text_.")
    let expectedJSON = """
        {
          "type" : "mrkdwn",
          "text" : "A message *with some bold text* and _some italicized text_."
        }
        """
    expect{ jsonEncode(object: text) == convert(json: expectedJSON) } == true
  }
  
  func testCompleteText() {
    let text = Text(
      text: "A message *with some bold text* and _some italicized text_.",
      type: .mrkdwn,
      emoji: true,
      verbatim: false)
    let expectedJSON = """
        {
          "type" : "mrkdwn",
          "text" : "A message *with some bold text* and _some italicized text_.",
          "emoji" : true,
          "verbatim" : false
        }
        """
    expect{ jsonEncode(object: text) == convert(json: expectedJSON) } == true
  }
  
  func testConfirmation() {
    let confirmation = Confirmation(
      title: PlainText("Are you sure?"),
      text: Text(text: "Wouldn't you prefer a good game of _chess_?", type: .mrkdwn),
      confirm: PlainText("Do it"),
      deny: PlainText("Stop, I've changed my mind!"))
    let expectedJSON = """
      {
        "title": {
            "type": "plain_text",
            "text": "Are you sure?"
        },
        "text": {
            "type": "mrkdwn",
            "text": "Wouldn't you prefer a good game of _chess_?"
        },
        "confirm": {
            "type": "plain_text",
            "text": "Do it"
        },
        "deny": {
            "type": "plain_text",
            "text": "Stop, I've changed my mind!"
        }
      }
      """
    expect{ jsonEncode(object: confirmation) == convert(json: expectedJSON) } == true
  }
  
  func testOption() {
    let option = Option(
      text: PlainText("Maru"),
      value: "maru")
    let expectedJSON = """
      {
        "text": {
            "type": "plain_text",
            "text": "Maru"
        },
        "value": "maru"
      }
      """
    expect{ jsonEncode(object: option) == convert(json: expectedJSON) } == true
  }
  
  func testOptionGroup() {
    let optionGroup = OptionGroup(
      label: PlainText("Group 1"),
      options: [
        Option(text: PlainText("*this is plain_text text*"), value: "value-0"),
        Option(text: PlainText("*this is plain_text text*"), value: "value-1"),
        Option(text: PlainText("*this is plain_text text*"), value: "value-2")
    ])
    let expectedJSON = """
      {
        "label": {
          "type": "plain_text",
          "text": "Group 1"
        },
        "options": [
          {
            "text": {
                "type": "plain_text",
                "text": "*this is plain_text text*"
            },
            "value": "value-0"
          },
          {
            "text": {
                "type": "plain_text",
                "text": "*this is plain_text text*"
            },
            "value": "value-1"
          },
          {
            "text": {
                "type": "plain_text",
                "text": "*this is plain_text text*"
            },
            "value": "value-2"
          }
        ]
      }
      """
    expect{ jsonEncode(object: optionGroup) == convert(json: expectedJSON) } == true
  }
  
  static var allTests = [
    ("testSimpleText", testSimpleText),
    ("testCompleteText", testCompleteText),
    ("testConfirmation", testConfirmation),
    ("testOption", testOption),
    ("testOptionGroup", testOptionGroup),
  ]
}

