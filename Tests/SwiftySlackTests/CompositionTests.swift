//
//  CompositionTests.swift
//  
//
//  Created by Mathieu Barnachon on 14/07/2019.
//


import XCTest
import Nimble
import SwiftyJSON
@testable import SwiftySlack

final class CompositionTests: XCTestCase {
  
  func testSimpleText() {
    let text = Text("A message *with some bold text* and _some italicized text_.")
    let expectedJSON = JSON(parseJSON: """
        {
          "type" : "mrkdwn",
          "text" : "A message *with some bold text* and _some italicized text_."
        }
        """)
    expect{ jsonEncode(object: text) } == expectedJSON
  }
  
  func testCompleteText() {
    let text = Text(
      text: "A message *with some bold text* and _some italicized text_.",
      type: .mrkdwn,
      emoji: true,
      verbatim: false)
    let expectedJSON = JSON(parseJSON: """
        {
          "type" : "mrkdwn",
          "text" : "A message *with some bold text* and _some italicized text_.",
          "emoji" : true,
          "verbatim" : false
        }
        """)
    expect{ jsonEncode(object: text) } == expectedJSON
  }
  
  func testConfirmation() {
    let confirmation = Confirmation(
      title: PlainText("Are you sure?"),
      text: Text(text: "Wouldn't you prefer a good game of _chess_?", type: .mrkdwn),
      confirm: PlainText("Do it"),
      deny: PlainText("Stop, I've changed my mind!"))
    let expectedJSON = JSON(parseJSON: """
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
      """)
    expect{ jsonEncode(object: confirmation) } == expectedJSON
  }
  
  func testOption() {
    let option = Option(
      text: PlainText("Maru"),
      value: "maru")
    let expectedJSON = JSON(parseJSON: """
      {
        "text": {
            "type": "plain_text",
            "text": "Maru"
        },
        "value": "maru"
      }
      """)
    expect{ jsonEncode(object: option) } == expectedJSON
  }
  
  func testOptionGroup() {
    let optionGroup = OptionGroup(
      label: PlainText("Group 1"),
      options: [
        Option(text: PlainText("*this is plain_text text*"), value: "value-0"),
        Option(text: PlainText("*this is plain_text text*"), value: "value-1"),
        Option(text: PlainText("*this is plain_text text*"), value: "value-2")
    ])
    let expectedJSON = JSON(parseJSON: """
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
      """)
    expect{ jsonEncode(object: optionGroup) } == expectedJSON
  }
  
  static var allTests = [
    ("testSimpleText", testSimpleText),
    ("testCompleteText", testCompleteText),
    ("testConfirmation", testConfirmation),
    ("testOption", testOption),
    ("testOptionGroup", testOptionGroup),
  ]
}

