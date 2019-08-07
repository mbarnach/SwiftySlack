//
//  BlockTests.swift
//  
//
//  Created by Mathieu Barnachon on 13/07/2019.
//

import XCTest
import Nimble
import SwiftyJSON
@testable import SwiftySlack

// Test values are coming from the Slack documentation:
// https://api.slack.com/reference/messaging/payload

final class SectionBlockTests: XCTestCase {
  
  func testSimple() {
    let section = SectionBlock(text: Text("A message *with some bold text* and _some italicized text_."))
    let expectedJSON = JSON(parseJSON: """
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "A message *with some bold text* and _some italicized text_."
          }
        }
        """)
    expect{ jsonEncode(object: section) } == expectedJSON
  }
  
  func testTextFields() {
    let section = SectionBlock(
      text: MarkdownText("A message *with some bold text* and _some italicized text_."),
      fields: [
        MarkdownText("High"),
        PlainText(text: "String", emoji: true)
    ])
    let expectedJSON = JSON(parseJSON: """
      {
        "type": "section",
        "text": {
          "text": "A message *with some bold text* and _some italicized text_.",
          "type": "mrkdwn"
        },
        "fields": [
          {
            "type": "mrkdwn",
            "text": "High"
          },
          {
            "type": "plain_text",
            "emoji": true,
            "text": "String"
          }
        ]
      }
      """)
    expect{ jsonEncode(object: section) } == expectedJSON
  }
  
  func testImage() {
    // Manual escape of URL due to JSONEncoder.
    let section = SectionBlock(
      text: MarkdownText("This is a section block with an accessory image."),
      block_id: "section567",
      accessory: ImageElement(
        image_url: URL(string: "https://pbs.twimg.com/profile_images/625633822235693056/lNGUneLX_400x400.jpg")!,
        alt_text: "cute cat")
    )
    let expectedJSON = JSON(parseJSON: """
      {
        "type": "section",
        "block_id": "section567",
        "text": {
          "type": "mrkdwn",
          "text": "This is a section block with an accessory image."
        },
        "accessory": {
          "type": "image",
          "image_url": "https://pbs.twimg.com/profile_images/625633822235693056/lNGUneLX_400x400.jpg",
          "alt_text": "cute cat"
        }
      }
      """)
    expect{ jsonEncode(object: section) } == expectedJSON
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
    let section = SectionBlock(
      text: MarkdownText("Pick an item from the dropdown list"),
      block_id: "section678",
      fields: [],
      accessory: select)
    let expectedJSON = JSON(parseJSON: """
      {
        "type": "section",
        "block_id": "section678",
        "text": {
            "type": "mrkdwn",
            "text": "Pick an item from the dropdown list"
        },
        "accessory": {
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
      }
      """)
    expect{ jsonEncode(object: section) } == expectedJSON
  }
  
  func testExternalSelect() {
    let select = ExternalSelect(
      placeholder: PlainText("Select an item"),
      action_id: "text1234",
      min_query_length: 3)
    let section = SectionBlock(
      text: MarkdownText("Pick an item from the dropdown list"),
      block_id: "section678",
      fields: [],
      accessory: select)
    let expectedJSON = JSON(parseJSON: """
      {
        "type": "section",
        "block_id": "section678",
        "text": {
          "type": "mrkdwn",
          "text": "Pick an item from the dropdown list"
        },
        "accessory": {
          "action_id": "text1234",
          "type": "external_select",
          "placeholder": {
            "type": "plain_text",
            "text": "Select an item"
          },
          "min_query_length": 3
        }
      }
      """)
    expect{ jsonEncode(object: section) } == expectedJSON
  }
  
  func testUserSelect() {
    let select = UsersSelect(
      placeholder: PlainText("Select an item"),
      action_id: "text1234")
    let section = SectionBlock(
      text: MarkdownText("Pick a user from the dropdown list"),
      block_id: "section678",
      fields: [],
      accessory: select)
    let expectedJSON = JSON(parseJSON: """
      {
        "type": "section",
        "block_id": "section678",
        "text": {
          "type": "mrkdwn",
          "text": "Pick a user from the dropdown list"
        },
        "accessory": {
          "action_id": "text1234",
          "type": "users_select",
          "placeholder": {
            "type": "plain_text",
            "text": "Select an item"
          }
        }
      }
      """)
    expect{ jsonEncode(object: section) } == expectedJSON
  }
  
  func testConversationSelect() {
    let select = ConversationSelect(
      placeholder: PlainText("Select an item"),
      action_id: "text1234")
    let section = SectionBlock(
      text: MarkdownText("Pick a conversation from the dropdown list"),
      block_id: "section678",
      fields: [],
      accessory: select)
    let expectedJSON = JSON(parseJSON: """
      {
        "type": "section",
        "block_id": "section678",
        "text": {
            "type": "mrkdwn",
            "text": "Pick a conversation from the dropdown list"
        },
        "accessory": {
          "action_id": "text1234",
          "type": "conversations_select",
          "placeholder": {
            "type": "plain_text",
            "text": "Select an item"
          }
        }
      }
      """)
    expect{ jsonEncode(object: section) } == expectedJSON
  }
  
  func testChannelSelect() {
    let select = ChannelSelect(
      placeholder: PlainText("Select an item"),
      action_id: "text1234")
    let section = SectionBlock(
      text: MarkdownText("Pick a channel from the dropdown list"),
      block_id: "section678",
      fields: [],
      accessory: select)
    let expectedJSON = JSON(parseJSON: """
      {
        "type": "section",
        "block_id": "section678",
        "text": {
          "type": "mrkdwn",
          "text": "Pick a channel from the dropdown list"
        },
        "accessory": {
          "action_id": "text1234",
          "type": "channels_select",
          "placeholder": {
            "type": "plain_text",
            "text": "Select an item"
          }
        }
      }
      """)
    expect{ jsonEncode(object: section) } == expectedJSON
  }
  
  func testOverflow() {
    let section = SectionBlock(
      text: MarkdownText("Dependencies of SwiftySlack:"),
      block_id: "section 890",
      accessory: OverflowElement(
        action_id: "overflow",
        options: [
          Option(text: PlainText("SwiftyRequest"),
                 value: "swiftyrequest",
                 url: URL(string: "https://github.com/IBM-Swift/SwiftyRequest")!),
          Option(text: PlainText("SwiftyJSON"),
                 value: "swiftyjson",
                 url: URL(string: "https://github.com/SwiftyJSON/SwiftyJSON")!),
          Option(text: PlainText("Promises"),
                 value: "promises",
                 url: URL(string: "https://github.com/google/promises")!),
          Option(text: PlainText("Nimble"),
                 value: "nimble",
                 url: URL(string: "https://github.com/Quick/Nimble")!)
        ]
      )
    )
    let expectedJSON = JSON(parseJSON: """
      {
        "type": "section",
        "block_id": "section 890",
        "text": {
          "type": "mrkdwn",
          "text": "Dependencies of SwiftySlack:"
        },
        "accessory": {
          "type": "overflow",
          "options": [
            {
              "text": {
                "type": "plain_text",
                "text": "SwiftyRequest"
              },
              "value": "swiftyrequest",
              "url": "https://github.com/IBM-Swift/SwiftyRequest"
            },
            {
              "text": {
                "type": "plain_text",
                "text": "SwiftyJSON"
              },
              "value": "swiftyjson",
              "url": "https://github.com/SwiftyJSON/SwiftyJSON"
            },
            {
              "text": {
                "type": "plain_text",
                "text": "Promises"
              },
              "value": "promises",
              "url": "https://github.com/google/promises"
            },
            {
              "text": {
                "type": "plain_text",
                "text": "Nimble"
              },
              "value": "nimble",
              "url": "https://github.com/Quick/Nimble"
            }
          ],
          "action_id": "overflow"
        }
      }
      """)
    expect{ jsonEncode(object: section) } == expectedJSON
  }
  
  func testDatepicker() {
    let section = SectionBlock(
      text: MarkdownText("*Sally* has requested you set the deadline for the Nano launch project"),
      accessory: DatePickerElement(
        placeholder: PlainText("Select a date"),
        action_id: "datepicker123",
        initial_date: DatePickerElement.date(from: "1990-04-28")!)
    )
    let expectedJSON = JSON(parseJSON: """
      {
        "type": "section",
        "text": {
          "text": "*Sally* has requested you set the deadline for the Nano launch project",
          "type": "mrkdwn"
        },
        "accessory": {
          "type": "datepicker",
          "action_id": "datepicker123",
          "initial_date": "1990-04-28",
          "placeholder": {
            "type": "plain_text",
            "text": "Select a date"
          }
        }
      }
      """)
    expect{ jsonEncode(object: section) } == expectedJSON
  }
  
  static var allTests = [
    ("testSimple", testSimple),
    ("testTextFields", testTextFields),
    ("testImage", testImage),
    ("testOverflow", testOverflow),
    ("testDatepicker", testDatepicker),
  ]
}

final class DividerBlockTests: XCTestCase {
  
  func testSimple() {
    let divider = DividerBlock()
    let expectedJSON = JSON(parseJSON: """
        {
          "type": "divider"
        }
        """)
    expect{ jsonEncode(object: divider) } == expectedJSON
  }
  static var allTests = [
    ("testSimple", testSimple),
  ]
}

final class ImageBlockTests: XCTestCase {
  
  func testSimple() {
    let image = ImageBlock(
      image_url: URL(string: "http://placekitten.com/500/500")!,
      alt_text: "An incredibly cute kitten.",
      title: PlainText("Please enjoy this photo of a kitten"),
      block_id: "image4")
    let expectedJSON = JSON(parseJSON: """
        {
          "type": "image",
          "title": {
            "type": "plain_text",
            "text": "Please enjoy this photo of a kitten"
          },
          "block_id": "image4",
          "image_url": "http://placekitten.com/500/500",
          "alt_text": "An incredibly cute kitten."
        }
        """)
    expect{ jsonEncode(object: image) } == expectedJSON
  }
  static var allTests = [
    ("testSimple", testSimple),
  ]
}

final class ActionBlockTests: XCTestCase {
  
  func testSelectAndButton() {
    let actions = ActionsBlock(
      elements: [
        StaticSelect(
          placeholder: PlainText("Which witch is the witchiest witch?"),
          action_id: "select_2",
          options: [
            Option(text: PlainText("Matilda"), value: "matilda"),
            Option(text: PlainText("Glinda"), value: "glinda"),
            Option(text: PlainText("Granny Weatherwax"), value: "grannyWeatherwax"),
            Option(text: PlainText("Hermione"), value: "hermione")
          ]
        ),
        ButtonElement(
          text: PlainText("Cancel"),
          action_id: "button_1",
          value: "cancel")
      ],
      block_id: "actions1")
    let expectedJSON = JSON(parseJSON: """
        {
          "type": "actions",
          "block_id": "actions1",
          "elements": [
            {
              "type": "static_select",
              "placeholder":{
                  "type": "plain_text",
                  "text": "Which witch is the witchiest witch?"
              },
              "action_id": "select_2",
              "options": [
                {
                  "text": {
                      "type": "plain_text",
                      "text": "Matilda"
                  },
                  "value": "matilda"
                },
                {
                  "text": {
                      "type": "plain_text",
                      "text": "Glinda"
                  },
                  "value": "glinda"
                },
                {
                  "text": {
                      "type": "plain_text",
                      "text": "Granny Weatherwax"
                  },
                  "value": "grannyWeatherwax"
                },
                {
                  "text": {
                      "type": "plain_text",
                      "text": "Hermione"
                  },
                  "value": "hermione"
                }
              ]
            },
            {
              "type": "button",
              "text": {
                  "type": "plain_text",
                  "text": "Cancel"
              },
              "value": "cancel",
              "action_id": "button_1"
            }
          ]
        }
        """)
    expect{ jsonEncode(object: actions) } == expectedJSON
  }
  
  func testDatePickerAndOverflow() {
    let actions = ActionsBlock(
      elements: [
        DatePickerElement(
          placeholder: PlainText("Select a date"),
          action_id: "datepicker123",
          initial_date: DatePickerElement.date(from: "1990-04-28")!
        ),
        OverflowElement(
          action_id: "overflow",
          options: [
            Option(text: PlainText("*this is plain_text text*"), value: "value-0"),
            Option(text: PlainText("*this is plain_text text*"), value: "value-1"),
            Option(text: PlainText("*this is plain_text text*"), value: "value-2"),
            Option(text: PlainText("*this is plain_text text*"), value: "value-3"),
            Option(text: PlainText("*this is plain_text text*"), value: "value-4"),
          ]
        ),
        ButtonElement(
          text: PlainText("Click Me"),
          action_id: "button",
          value: "click_me_123"
        )
      ],
      block_id: "actionblock789")
    let expectedJSON = JSON(parseJSON: """
        {
          "type": "actions",
          "block_id": "actionblock789",
          "elements": [
            {
              "type": "datepicker",
              "action_id": "datepicker123",
              "initial_date": "1990-04-28",
              "placeholder": {
                "type": "plain_text",
                "text": "Select a date"
              }
            },
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
            },
            {
              "type": "button",
              "text": {
                "type": "plain_text",
                "text": "Click Me"
              },
              "value": "click_me_123",
              "action_id": "button"
            }
          ]
        }
        """)
    expect{ jsonEncode(object: actions) } == expectedJSON
  }
  
  static var allTests = [
    ("testSelectAndButton", testSelectAndButton),
    ("testDatePickerAndOverflow", testDatePickerAndOverflow),
  ]
}

final class ContextBlockTests: XCTestCase {
  
  func testSimple() {
    let context = ContextBlock(elements: [
      ContextBlock.ContextElement(image: ImageElement(
        image_url: URL(string: "https://image.freepik.com/free-photo/red-drawing-pin_1156-445.jpg")!,
        alt_text: "images")),
      ContextBlock.ContextElement(text: MarkdownText("Location: **Dogpatch**"))
      ]
    )
    let expectedJSON = JSON(parseJSON: """
      {
        "type": "context",
        "elements": [
          {
            "type": "image",
            "image_url": "https://image.freepik.com/free-photo/red-drawing-pin_1156-445.jpg",
            "alt_text": "images"
          },
          {
            "type": "mrkdwn",
            "text": "Location: **Dogpatch**"
          },
        ]
      }
      """)
    expect{ jsonEncode(object: context) } == expectedJSON
  }
  
  func testComplete() {
    let context = ContextBlock(elements: [
      ContextBlock.ContextElement(text: MarkdownText(text: "*Author:* T. M. Schwartz", verbatim: true)),
      ContextBlock.ContextElement(text: PlainText(text: "*Author:* T. M. Schwartz", emoji: true)),
      ContextBlock.ContextElement(image: ImageElement(
      image_url: URL(string: "https://api.slack.com/img/blocks/bkb_template_images/goldengate.png")!,
      alt_text: "Example Image")),
      ]
    )
    let expectedJSON = JSON(parseJSON: """
      {
        "type": "context",
        "elements": [
          {
            "type": "mrkdwn",
            "text": "*Author:* T. M. Schwartz",
            "verbatim": true
          },
          {
            "type": "plain_text",
            "text": "*Author:* T. M. Schwartz",
                    "emoji": true
          },
          {
            "type": "image",
            "image_url": "https://api.slack.com/img/blocks/bkb_template_images/goldengate.png",
            "alt_text": "Example Image"
          }
        ]
      }
      """)
    expect{ jsonEncode(object: context) } == expectedJSON
  }
  
  static var allTests = [
    ("testSimple", testSimple),
    ("testComplete", testComplete),
  ]
}

final class FileBlockTests: XCTestCase {
  
  func testSimple() {
    let file = FileBlock(external_id: "ABCD1")
    let expectedJSON = JSON(parseJSON: """
      {
        "type": "file",
        "external_id": "ABCD1",
        "source": "remote",
      }
      """)
    expect{ jsonEncode(object: file) } == expectedJSON
  }
  
  static var allTests = [
    ("testSimple", testSimple),
  ]
}
