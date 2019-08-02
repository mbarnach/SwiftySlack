//
//  ElementTests.swift
//  
//
//  Created by Mathieu Barnachon on 30/07/2019.
//


import XCTest
import Nimble
import SwiftyJSON
@testable import SwiftySlack

// Test values are coming from the Slack documentation:
// https://api.slack.com/reference/messaging/payload

final class ElementTests: XCTestCase {
  
  func testImage() {
    let button = ImageElement(
      image_url: URL(string: "http://placekitten.com/700/500")!,
      alt_text: "Multiple cute kittens")
    let expectedJSON = JSON(parseJSON: """
      {
        "type": "image",
        "image_url": "http://placekitten.com/700/500",
        "alt_text": "Multiple cute kittens"
      }
      """)
    expect{ jsonEncode(object: button) } == expectedJSON
  }
  
  func testButton() {
    let button = ButtonElement(
      text: PlainText("Click Me"),
      action_id: "button",
      value: "click_me_123")
    let expectedJSON = JSON(parseJSON: """
      {
        "type": "button",
        "text": {
          "type": "plain_text",
          "text": "Click Me"
        },
        "value": "click_me_123",
        "action_id": "button"
      }
      """)
    expect{ jsonEncode(object: button) } == expectedJSON
  }
  
  func testButtonStyle() {
    let button = ButtonElement(
      text: PlainText("Save"),
      action_id: "button",
      value: "click_me_123",
      style: .primary)
    let expectedJSON = JSON(parseJSON: """
      {
        "type": "button",
        "text": {
          "type": "plain_text",
          "text": "Save"
        },
        "style": "primary",
        "value": "click_me_123",
        "action_id": "button"
      }
      """)
    expect{ jsonEncode(object: button) } == expectedJSON
  }
  
  func testButtonLink() {
    let url = URL(string: "https://api.slack.com/block-kit")!
    let button = ButtonElement(
      text: PlainText("Link Button"),
      action_id: .Empty(),
      url: url)
    let expectedJSON = JSON(parseJSON: """
      {
        "type": "button",
        "text": {
          "type": "plain_text",
          "text": "Link Button"
        },
        "url": "https://api.slack.com/block-kit"
      }
      """)
    expect{ jsonEncode(object: button) } == expectedJSON
  }
  
  func testStaticSelect() {
    let select = StaticSelect(
      placeholder: PlainText("Select an item"),
      action_id: "text1234",
      options: [
        Option(text: PlainText("*this is plain_text text*"), value: "value-0"),
        Option(text: PlainText("*this is plain_text text*"), value: "value-1"),
        Option(text: PlainText("*this is plain_text text*"), value: "value-2")
      ]
    )
    let expectedJSON = JSON(parseJSON: """
      {
        "action_id": "text1234",
        "type": "static_select",
        "placeholder": {
          "type": "plain_text",
          "text": "Select an item"
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
    expect{ jsonEncode(object: select) } == expectedJSON
  }
  
  func testExternalSelect() {
    let select = ExternalSelect(
      placeholder: PlainText("Select an item"),
      action_id: "text1234",
      min_query_length: 3)
    let expectedJSON = JSON(parseJSON: """
      {
        "action_id": "text1234",
        "type": "external_select",
        "placeholder": {
          "type": "plain_text",
          "text": "Select an item"
        },
        "min_query_length": 3
      }
      """)
    expect{ jsonEncode(object: select) } == expectedJSON
  }
  
  func testUserSelect() {
    let select = UsersSelect(
      placeholder: PlainText("Select an item"),
      action_id: "text1234")
    let expectedJSON = JSON(parseJSON: """
      {
        "action_id": "text1234",
        "type": "users_select",
        "placeholder": {
          "type": "plain_text",
          "text": "Select an item"
        }
      }
      """)
    expect{ jsonEncode(object: select) } == expectedJSON
  }
  
  func testConversationSelect() {
    let select = ConversationSelect(
      placeholder: PlainText("Select an item"),
      action_id: "text1234")
    let expectedJSON = JSON(parseJSON: """
      {
        "action_id": "text1234",
        "type": "conversations_select",
        "placeholder": {
          "type": "plain_text",
          "text": "Select an item"
        }
      }
      """)
    expect{ jsonEncode(object: select) } == expectedJSON
  }
  
  func testChannelSelect() {
    let select = ChannelSelect(
      placeholder: PlainText("Select an item"),
      action_id: "text1234")
    let expectedJSON = JSON(parseJSON: """
      {
        "action_id": "text1234",
        "type": "channels_select",
        "placeholder": {
          "type": "plain_text",
          "text": "Select an item"
        }
      }
      """)
    expect{ jsonEncode(object: select) } == expectedJSON
  }
  
  func testOverflow() {
    let overflow = OverflowElement(
      action_id: "overflow",
      options: [
        Option(text: PlainText("*this is plain_text text*"), value: "value-0"),
        Option(text: PlainText("*this is plain_text text*"), value: "value-1"),
        Option(text: PlainText("*this is plain_text text*"), value: "value-2"),
        Option(text: PlainText("*this is plain_text text*"), value: "value-3"),
        Option(text: PlainText("*this is plain_text text*"), value: "value-4")
    ])
    let expectedJSON = JSON(parseJSON: """
      {
        "type": "overflow",
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
          },
          {
            "text": {
              "type": "plain_text",
              "text": "*this is plain_text text*"
            },
            "value": "value-3"
          },
          {
            "text": {
              "type": "plain_text",
              "text": "*this is plain_text text*"
            },
            "value": "value-4"
          }
        ],
        "action_id": "overflow"
      }
      """)
    expect{ jsonEncode(object: overflow) } == expectedJSON
  }
  
  func testDatepicker() {
    let date = DatePickerElement(
        placeholder: PlainText("Select a date"),
        action_id: "datepicker123",
        initial_date: DatePickerElement.date(from: "1990-04-28")!)
    let expectedJSON = JSON(parseJSON: """
      {
        "type": "datepicker",
        "action_id": "datepicker123",
        "initial_date": "1990-04-28",
        "placeholder": {
          "type": "plain_text",
          "text": "Select a date"
        }
      }
      """)
    expect{ jsonEncode(object: date) } == expectedJSON
  }
  
  static var allTests = [
    ("testImage", testImage),
    ("testButton", testButton),
    ("testButtonStyle", testButtonStyle),
    ("testButtonLink", testButtonLink),
    ("testStaticSelect", testStaticSelect),
    ("testExternalSelect", testExternalSelect),
    ("testUserSelect", testUserSelect),
    ("testConversationSelect", testConversationSelect),
    ("testChannelSelect", testChannelSelect),
    ("testOverflow", testOverflow),
    ("testDatepicker", testDatepicker),
  ]
}
