//
//  MessageTests.swift
//  
//
//  Created by Mathieu Barnachon on 01/08/2019.
//
import XCTest
import Nimble
import SwiftyRequest
@testable import SwiftySlack

final class MessageTests: XCTestCase {
  var token: String = ""
  var channel = ""
  var user = ""
  var user2 = ""
  
  override func setUp() {
    self.token = ProcessInfo.processInfo.environment["TOKEN"] ?? ""
    self.channel = ProcessInfo.processInfo.environment["CHANNEL"] ?? ""
    self.user = ProcessInfo.processInfo.environment["SLACKUSER"] ?? ""
    self.user = ProcessInfo.processInfo.environment["SLACKUSER2"] ?? ""
  }
  
  func testMessageComplete() {
    let webAPI = WebAPI(token: self.token)

    waitUntil(timeout: 10) { done in
        webAPI.send(message: Message(
            blocks: [
                SectionBlock(text: MarkdownText("A *custom* message"))
            ],
            to: self.channel,
            alternateText: #function,
            as: false,
            emoji: ":chart_with_upwards_trend:",
            link: true,
            useMarkdown: true,
            parse: .full,
            unfurl_links: true,
            unfurl_media: true))
        .observe{ result in
                switch result {
                    case .success:
                        break
                    case .failure(let error):
                        XCTFail("Unable to send the message: \(error)")
                }
                done()
            }
    }
    
    waitUntil(timeout: 10) { done in
        webAPI.send(message: Message(
            blocks: [
                SectionBlock(text: MarkdownText("A *custom* message"))
            ],
            to: self.channel,
            alternateText: #function,
            as: false,
            url: URL(string: "https://api.slack.com/img/blocks/bkb_template_images/approvalsNewDevice.png")!,
            link: false,
            useMarkdown: false,
            parse: .none,
            unfurl_links: false,
            unfurl_media: false,
            username: "SwiftySlack bot"))
        .observe{ result in
            switch result {
                case .success:
                    break
                case .failure(let error):
                    XCTFail("Unable to send the message: \(error)")
            }
            done()
        }
    }
  }
  
  func testMessageReply() {
    let webAPI = WebAPI(token: self.token)
    
    waitUntil(timeout: 10) { done in
        webAPI.send(message: Message(
        blocks: [
            SectionBlock(text: MarkdownText("A *custom* message"))
        ],
        to: self.channel,
        alternateText: #function)).then { parent in
            Future<Message>.all([
                 webAPI.send(message: Message(
                    blocks: [
                    SectionBlock(text: MarkdownText("*Custom* reply 1"))
                    ],
                    to: self.channel,
                    alternateText: #function+" reply 1",
                    reply: parent.thread_ts)),
                 webAPI.send(message: Message(
                    blocks: [
                    SectionBlock(text: MarkdownText("*Custom* reply 2"))
                    ],
                    to: self.channel,
                    alternateText: #function+" reply 2",
                    reply: parent.thread_ts)),
                webAPI.send(message: Message(
                    blocks: [
                    SectionBlock(text: MarkdownText("*Custom* reply 3"))
                    ],
                    to: self.channel,
                    alternateText: #function+" reply 3",
                    reply_broadcast: true,
                    reply: parent.thread_ts))
            ])
        }.observe{ result in
            switch result {
                case .success:
                    break
                case .failure(let error):
                    XCTFail("Unable to send the message: \(error)")
            }
            done()
        }
    }
    
  }
  
  func testTemplateApprovalMessage() {
    let section1 = SectionBlock(text: MarkdownText("You have a new request:\n*<fakeLink.toEmployeeProfile.com|Fred Enriquez - New device request>*"))
    
    let expectedJSON1 = """
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "You have a new request:\\n*<fakeLink.toEmployeeProfile.com|Fred Enriquez - New device request>*"
        }
      }
      """
    expect{ jsonEncode(object: section1) == convert(json: expectedJSON1) } == true
    
    let section2 = SectionBlock(fields: [
      MarkdownText("*Type:*\nComputer (laptop)"),
      MarkdownText("*When:*\nSubmitted Aut 10"),
      MarkdownText("*Last Update:*\nMar 10, 2015 (3 years, 5 months)"),
      MarkdownText("*Reason:*\nAll vowel keys aren't working."),
      MarkdownText("*Specs:*\n\"Cheetah Pro 15\" - Fast, really fast\"")
      ]
    )
    let expectedJSON2 = """
      {
        "type": "section",
        "fields": [
          {
            "type": "mrkdwn",
            "text": "*Type:*\\nComputer (laptop)"
          },
          {
            "type": "mrkdwn",
            "text": "*When:*\\nSubmitted Aut 10"
          },
          {
            "type": "mrkdwn",
            "text": "*Last Update:*\\nMar 10, 2015 (3 years, 5 months)"
          },
          {
            "type": "mrkdwn",
            "text": "*Reason:*\\nAll vowel keys aren't working."
          },
          {
            "type": "mrkdwn",
            "text": "*Specs:*\\n\\"Cheetah Pro 15\\" - Fast, really fast\\""
          }
        ]
      }
      """
    expect{ jsonEncode(object: section2) == convert(json: expectedJSON2) } == true
    
    let action1 = ActionsBlock(elements: [
      ButtonElement(text: PlainText(text: "Approve", emoji: true),
                    value: "click_me_123",
                    style: .primary),
      ButtonElement(text: PlainText(text: "Deny", emoji: true),
                    value: "click_me_123",
                    style: .danger)
      ]
    )
    let expectedJSON3 = """
      {
        "type": "actions",
        "elements": [
          {
            "type": "button",
            "text": {
              "type": "plain_text",
              "emoji": true,
              "text": "Approve"
            },
            "style": "primary",
            "value": "click_me_123"
          },
          {
            "type": "button",
            "text": {
              "type": "plain_text",
              "emoji": true,
              "text": "Deny"
            },
            "style": "danger",
            "value": "click_me_123"
          }
        ]
      }
      """
    expect{ jsonEncode(object: action1)  == convert(json: expectedJSON3) } == true
    
    let message = Message(blocks: [section1, section2, action1],
                        to: self.channel,
                        alternateText: #function)
    
    let webAPI = WebAPI(token: self.token)
    waitUntil(timeout: 10) { done in
        webAPI.send(message: message)
        .observe{ result in
            switch result {
                case .success:
                    break
                case .failure(let error):
                    XCTFail("Unable to send the message: \(error)")
            }
            done()
        }
    }
  }
  
  func testTemplateApprovalAdvancedMessage() {
    let blocks = [
      SectionBlock(text: MarkdownText("You have a new request:\n*<google.com|Fred Enriquez - Time Off request>*")),
      SectionBlock(text: MarkdownText("*Type:*\nPaid time off\n*When:*\nAug 10-Aug 13\n*Hours:* 16.0 (2 days)\n*Remaining balance:* 32.0 hours (4 days)\n*Comments:* \"Family in town, going camping!\""),
                   accessory: ImageElement(image_url: URL(string: "https://api.slack.com/img/blocks/bkb_template_images/approvalsNewDevice.png")!,
                                           alt_text: "computer thumbnail")),
      ActionsBlock(elements: [
        ButtonElement(text: PlainText(text: "Approve", emoji: true),
                      value: "click_me_123",
                      style: .primary),
        ButtonElement(text: PlainText(text: "Deny", emoji: true),
                      value: "click_me_123",
                      style: .danger)
        ]
      )
    ]
    let expectedJSON = """
      [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "You have a new request:\\n*<google.com|Fred Enriquez - Time Off request>*"
          }
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "*Type:*\\nPaid time off\\n*When:*\\nAug 10-Aug 13\\n*Hours:* 16.0 (2 days)\\n*Remaining balance:* 32.0 hours (4 days)\\n*Comments:* \\"Family in town, going camping!\\""
          },
          "accessory": {
            "type": "image",
            "image_url": "https://api.slack.com/img/blocks/bkb_template_images/approvalsNewDevice.png",
            "alt_text": "computer thumbnail"
          }
        },
        {
          "type": "actions",
          "elements": [
            {
              "type": "button",
              "text": {
                "type": "plain_text",
                "emoji": true,
                "text": "Approve"
              },
              "style": "primary",
              "value": "click_me_123"
            },
            {
              "type": "button",
              "text": {
                "type": "plain_text",
                "emoji": true,
                "text": "Deny"
              },
              "style": "danger",
              "value": "click_me_123"
            }
          ]
        }
      ]
      """
    
    expect{ jsonEncode(object: blocks) == convert(json: expectedJSON) } == true
    
    let message = Message(blocks: blocks,
                          to: self.channel,
                          alternateText: #function)
    
    let webAPI = WebAPI(token: self.token)
    waitUntil(timeout: 10) { done in
        webAPI.send(message: message)
        .observe{ result in
                switch result {
                    case .success(let value):
                        break
                    case .failure(let error):
                        XCTFail("Unable to send the message: \(error)")
                }
                done()
            }
        }
    }
  
  func testTemplateNotificationMessage() {
    let blocks = [
      SectionBlock(text: PlainText(text: "Looks like you have a scheduling conflict with this event:",
                                   emoji: true)),
      DividerBlock(),
      SectionBlock(text: MarkdownText("*<fakeLink.toUserProfiles.com|Iris / Zelda 1-1>*\nTuesday, January 21 4:00-4:30pm\nBuilding 2 - Havarti Cheese (3)\n2 guests"),
                   accessory: ImageElement(image_url: URL(string: "https://api.slack.com/img/blocks/bkb_template_images/notifications.png")!,
                                           alt_text: "calendar thumbnail")),
      ContextBlock(elements: [
        ContextBlock.ContextElement(image: ImageElement(image_url: URL(string: "https://api.slack.com/img/blocks/bkb_template_images/notificationsWarningIcon.png")!,
                                                        alt_text: "notifications warning icon")),
        ContextBlock.ContextElement(text: MarkdownText("*Conflicts with Team Huddle: 4:15-4:30pm*"))
        ]
      ),
      DividerBlock(),
      SectionBlock(text: MarkdownText("*Propose a new time:*")),
      SectionBlock(text: MarkdownText("*Today - 4:30-5pm*\nEveryone is available: @iris, @zelda"),
                   accessory: ButtonElement(text: PlainText(text: "Choose",
                                                            emoji: true),
                                            value: "click_me_123")),
      SectionBlock(text: MarkdownText("*Tomorrow - 4-4:30pm*\nEveryone is available: @iris, @zelda"),
                   accessory: ButtonElement(text: PlainText(text: "Choose",
                                                            emoji: true),
                                            value: "click_me_123")),
      SectionBlock(text: MarkdownText("*Tomorrow - 6-6:30pm*\nSome people aren't available: @iris, ~@zelda~"),
                   accessory: ButtonElement(text: PlainText(text: "Choose",
                                                            emoji: true),
                                            value: "click_me_123")),
      SectionBlock(text: MarkdownText("*<fakelink.ToMoreTimes.com|Show more times>*"))
    ]
    let expectedJSON = """
      [
        {
          "type": "section",
          "text": {
            "type": "plain_text",
            "emoji": true,
            "text": "Looks like you have a scheduling conflict with this event:"
          }
        },
        {
          "type": "divider"
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "*<fakeLink.toUserProfiles.com|Iris / Zelda 1-1>*\\nTuesday, January 21 4:00-4:30pm\\nBuilding 2 - Havarti Cheese (3)\\n2 guests"
          },
          "accessory": {
            "type": "image",
            "image_url": "https://api.slack.com/img/blocks/bkb_template_images/notifications.png",
            "alt_text": "calendar thumbnail"
          }
        },
        {
          "type": "context",
          "elements": [
            {
              "type": "image",
              "image_url": "https://api.slack.com/img/blocks/bkb_template_images/notificationsWarningIcon.png",
              "alt_text": "notifications warning icon"
            },
            {
              "type": "mrkdwn",
              "text": "*Conflicts with Team Huddle: 4:15-4:30pm*"
            }
          ]
        },
        {
          "type": "divider"
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "*Propose a new time:*"
          }
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "*Today - 4:30-5pm*\\nEveryone is available: @iris, @zelda"
          },
          "accessory": {
            "type": "button",
            "text": {
              "type": "plain_text",
              "emoji": true,
              "text": "Choose"
            },
            "value": "click_me_123"
          }
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "*Tomorrow - 4-4:30pm*\\nEveryone is available: @iris, @zelda"
          },
          "accessory": {
            "type": "button",
            "text": {
              "type": "plain_text",
              "emoji": true,
              "text": "Choose"
            },
            "value": "click_me_123"
          }
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "*Tomorrow - 6-6:30pm*\\nSome people aren't available: @iris, ~@zelda~"
          },
          "accessory": {
            "type": "button",
            "text": {
              "type": "plain_text",
              "emoji": true,
              "text": "Choose"
            },
            "value": "click_me_123"
          }
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "*<fakelink.ToMoreTimes.com|Show more times>*"
          }
        }
      ]
      """
    
    expect{ jsonEncode(object: blocks)  == convert(json: expectedJSON) } == true
    
    let message = Message(blocks: blocks,
                          to: self.channel,
                          alternateText: #function)
    
    let webAPI = WebAPI(token: self.token)
    waitUntil(timeout: 10) { done in
        webAPI.send(message: message)
        .observe{ result in
                switch result {
                    case .success:
                        break
                    case .failure(let error):
                        XCTFail("Unable to send the message: \(error)")
                }
                done()
            }
    }
  }
  
  func testTemplateOnboardingMessage() {
    let blocks = [
      SectionBlock(text: MarkdownText("Hey there 👋 I'm TaskBot. I'm here to help you create and manage tasks in Slack.\nThere are two ways to quickly create tasks:")),
      SectionBlock(text: MarkdownText("*1️⃣ Use the `/task` command*. Type `/task` followed by a short description of your tasks and I'll ask for a due date (if applicable). Try it out by using the `/task` command in this channel.")),
      SectionBlock(text: MarkdownText("*2️⃣ Use the _Create a Task_ action.* If you want to create a task from a message, select `Create a Task` in a message's context menu. Try it out by selecting the _Create a Task_ action for this message (shown below).")),
      ImageBlock(image_url: URL(string: "https://api.slack.com/img/blocks/bkb_template_images/onboardingComplex.jpg")!,
                 alt_text: "image1",
                 title: PlainText(text: "image1",
                                  emoji: true)),
      SectionBlock(text: MarkdownText("➕ To start tracking your team's tasks, *add me to a channel* and I'll introduce myself. I'm usually added to a team or project channel. Type `/invite @TaskBot` from the channel or pick a channel on the right."),
                   accessory: ConversationSelect(placeholder: PlainText(text: "Select a channel...",
                                                                        emoji: true),
                                                 action_id: "123")),
      DividerBlock(),
      ContextBlock(elements: [
        ContextBlock.ContextElement(text: MarkdownText("👀 View all tasks with `/task list`\n❓Get help at any time with `/task help` or type *help* in a DM with me"))
        ]
      )
    ]
    let expectedJSON = """
      [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "Hey there 👋 I'm TaskBot. I'm here to help you create and manage tasks in Slack.\\nThere are two ways to quickly create tasks:"
          }
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "*1️⃣ Use the `/task` command*. Type `/task` followed by a short description of your tasks and I'll ask for a due date (if applicable). Try it out by using the `/task` command in this channel."
          }
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "*2️⃣ Use the _Create a Task_ action.* If you want to create a task from a message, select `Create a Task` in a message's context menu. Try it out by selecting the _Create a Task_ action for this message (shown below)."
          }
        },
        {
          "type": "image",
          "title": {
            "type": "plain_text",
            "text": "image1",
            "emoji": true
          },
          "image_url": "https://api.slack.com/img/blocks/bkb_template_images/onboardingComplex.jpg",
          "alt_text": "image1"
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "➕ To start tracking your team's tasks, *add me to a channel* and I'll introduce myself. I'm usually added to a team or project channel. Type `/invite @TaskBot` from the channel or pick a channel on the right."
          },
          "accessory": {
            "type": "conversations_select",
            "placeholder": {
              "type": "plain_text",
              "text": "Select a channel...",
              "emoji": true
            },
            "action_id": "123"
          }
        },
        {
          "type": "divider"
        },
        {
          "type": "context",
          "elements": [
            {
              "type": "mrkdwn",
              "text": "👀 View all tasks with `/task list`\\n❓Get help at any time with `/task help` or type *help* in a DM with me"
            }
          ]
        }
      ]
      """
    
    expect{ jsonEncode(object: blocks)  == convert(json: expectedJSON) } == true
    
    let message = Message(blocks: blocks,
                          to: self.channel,
                          alternateText: #function)
    
    let webAPI = WebAPI(token: self.token)
    waitUntil(timeout: 10) { done in
        webAPI.send(message: message)
        .observe{ result in
            switch result {
                case .success:
                    break
                case .failure(let error):
                    XCTFail("Unable to send the message: \(error)")
            }
            done()
        }
    }
  }
  
  func testTemplateOnboardingBotMessage() {
    let blocks = [
      SectionBlock(text: MarkdownText("Hi David :wave:")),
      SectionBlock(text: MarkdownText("Great to see you here! App helps you to stay up-to-date with your meetings and events right here within Slack. These are just a few things which you will be able to do:")),
      SectionBlock(text: MarkdownText("• Schedule meetings \n • Manage and update attendees \n • Get notified about changes of your meetings")),
      SectionBlock(text: MarkdownText("But before you can do all these amazing things, we need you to connect your calendar to App. Simply click the button below:")),
      ActionsBlock(elements: [
        ButtonElement(text: PlainText(text: "Connect account",
                                      emoji: true),
                      value: "click_me_123")
        ]
      )
    ]
    let expectedJSON = """
      [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "Hi David :wave:"
          }
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "Great to see you here! App helps you to stay up-to-date with your meetings and events right here within Slack. These are just a few things which you will be able to do:"
          }
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "• Schedule meetings \\n • Manage and update attendees \\n • Get notified about changes of your meetings"
          }
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "But before you can do all these amazing things, we need you to connect your calendar to App. Simply click the button below:"
          }
        },
        {
          "type": "actions",
          "elements": [
            {
              "type": "button",
              "text": {
                "type": "plain_text",
                "text": "Connect account",
                "emoji": true
              },
              "value": "click_me_123"
            }
          ]
        }
      ]
      """
    
    expect{ jsonEncode(object: blocks) == convert(json: expectedJSON) } == true
    
    let message = Message(blocks: blocks,
                          to: self.channel,
                          alternateText: #function)
    
    let webAPI = WebAPI(token: self.token)

    waitUntil(timeout: 10) { done in
        webAPI.send(message: message)
        .observe{ result in
            switch result {
                case .success:
                    break
                case .failure(let error):
                    XCTFail("Unable to send the message: \(error)")
            }
            done()
        }
    }
  }
  
  func testTemplatePoolMessage() {
    let blocks = [
      SectionBlock(text: MarkdownText("*Where should we order lunch from?* Poll by <fakeLink.toUser.com|Mark>")),
      DividerBlock(),
      SectionBlock(text: MarkdownText(":sushi: *Ace Wasabi Rock-n-Roll Sushi Bar*\nThe best landlocked sushi restaurant."),
                   accessory: ButtonElement(text: PlainText(text: "Vote",
                                                            emoji: true),
                                            value: "click_me_123")),
      ContextBlock(elements: [
        ContextBlock.ContextElement(image: ImageElement(image_url: URL(string: "https://api.slack.com/img/blocks/bkb_template_images/profile_1.png")!,
                                                        alt_text: "Michael Scott")),
        ContextBlock.ContextElement(image: ImageElement(image_url: URL(string: "https://api.slack.com/img/blocks/bkb_template_images/profile_2.png")!,
                                                        alt_text: "Dwight Schrute")),
        ContextBlock.ContextElement(image: ImageElement(image_url: URL(string: "https://api.slack.com/img/blocks/bkb_template_images/profile_3.png")!,
                                                        alt_text: "Pam Beasely")),
        ContextBlock.ContextElement(text: PlainText(text: "3 votes",
                                                    emoji: true))
        ]
      ),
      SectionBlock(text: MarkdownText(":hamburger: *Super Hungryman Hamburgers*\nOnly for the hungriest of the hungry."),
                   accessory: ButtonElement(text: PlainText(text: "Vote",
                                                            emoji: true),
                                            value: "click_me_123")),
      ContextBlock(elements: [
        ContextBlock.ContextElement(image: ImageElement(image_url: URL(string: "https://api.slack.com/img/blocks/bkb_template_images/profile_4.png")!,
                                                        alt_text: "Angela")),
        ContextBlock.ContextElement(image: ImageElement(image_url: URL(string: "https://api.slack.com/img/blocks/bkb_template_images/profile_2.png")!,
                                                        alt_text: "Dwight Schrute")),
        ContextBlock.ContextElement(text: PlainText(text: "2 votes",
                                                    emoji: true))
        ]
      ),
      SectionBlock(text: MarkdownText(":ramen: *Kagawa-Ya Udon Noodle Shop*\nDo you like to shop for noodles? We have noodles."),
                   accessory: ButtonElement(text: PlainText(text: "Vote",
                                                            emoji: true),
                                            value: "click_me_123")),
      ContextBlock(elements: [
        ContextBlock.ContextElement(text: MarkdownText(text: "No votes"))
        ]
      ),
      DividerBlock(),
      ActionsBlock(elements: [
        ButtonElement(text: PlainText(text: "Add a suggestion",
                                      emoji: true),
                      value: "click_me_123")
        ]
      )
    ]
    let expectedJSON = """
      [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "*Where should we order lunch from?* Poll by <fakeLink.toUser.com|Mark>"
          }
        },
        {
          "type": "divider"
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": ":sushi: *Ace Wasabi Rock-n-Roll Sushi Bar*\\nThe best landlocked sushi restaurant."
          },
          "accessory": {
            "type": "button",
            "text": {
              "type": "plain_text",
              "emoji": true,
              "text": "Vote"
            },
            "value": "click_me_123"
          }
        },
        {
          "type": "context",
          "elements": [
            {
              "type": "image",
              "image_url": "https://api.slack.com/img/blocks/bkb_template_images/profile_1.png",
              "alt_text": "Michael Scott"
            },
            {
              "type": "image",
              "image_url": "https://api.slack.com/img/blocks/bkb_template_images/profile_2.png",
              "alt_text": "Dwight Schrute"
            },
            {
              "type": "image",
              "image_url": "https://api.slack.com/img/blocks/bkb_template_images/profile_3.png",
              "alt_text": "Pam Beasely"
            },
            {
              "type": "plain_text",
              "emoji": true,
              "text": "3 votes"
            }
          ]
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": ":hamburger: *Super Hungryman Hamburgers*\\nOnly for the hungriest of the hungry."
          },
          "accessory": {
            "type": "button",
            "text": {
              "type": "plain_text",
              "emoji": true,
              "text": "Vote"
            },
            "value": "click_me_123"
          }
        },
        {
          "type": "context",
          "elements": [
            {
              "type": "image",
              "image_url": "https://api.slack.com/img/blocks/bkb_template_images/profile_4.png",
              "alt_text": "Angela"
            },
            {
              "type": "image",
              "image_url": "https://api.slack.com/img/blocks/bkb_template_images/profile_2.png",
              "alt_text": "Dwight Schrute"
            },
            {
              "type": "plain_text",
              "emoji": true,
              "text": "2 votes"
            }
          ]
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": ":ramen: *Kagawa-Ya Udon Noodle Shop*\\nDo you like to shop for noodles? We have noodles."
          },
          "accessory": {
            "type": "button",
            "text": {
              "type": "plain_text",
              "emoji": true,
              "text": "Vote"
            },
            "value": "click_me_123"
          }
        },
        {
          "type": "context",
          "elements": [
            {
              "type": "mrkdwn",
              "text": "No votes"
            }
          ]
        },
        {
          "type": "divider"
        },
        {
          "type": "actions",
          "elements": [
            {
              "type": "button",
              "text": {
                "type": "plain_text",
                "emoji": true,
                "text": "Add a suggestion"
              },
              "value": "click_me_123"
            }
          ]
        }
      ]
      """
    
    expect{ jsonEncode(object: blocks) == convert(json: expectedJSON) } == true
    
    let message = Message(blocks: blocks,
                          to: self.channel,
                          alternateText: #function)

    let webAPI = WebAPI(token: self.token)

    waitUntil(timeout: 10) { done in
        webAPI.send(message: message)
        .observe{ result in
            switch result {
                case .success:
                    break
                case .failure(let error):
                    XCTFail("Unable to send the message: \(error)")
            }
            done()
        }
    }
  }
  
  func testTemplateSearchMessage() {
    let blocks = [
      SectionBlock(text: MarkdownText("We found *205 Hotels* in New Orleans, LA from *12/14 to 12/17*"),
                   accessory: OverflowElement(action_id: "123",
                                              options: [
                                                Option(text: PlainText(text: "Option One",
                                                                       emoji: true),
                                                       value: "value-0"),
                                                Option(text: PlainText(text: "Option Two",
                                                                       emoji: true),
                                                       value: "value-1"),
                                                Option(text: PlainText(text: "Option Three",
                                                                       emoji: true),
                                                       value: "value-2"),
                                                Option(text: PlainText(text: "Option Four",
                                                                       emoji: true),
                                                       value: "value-3")
                   ])),
      DividerBlock(),
      SectionBlock(text: MarkdownText("*<fakeLink.toHotelPage.com|Windsor Court Hotel>*\n★★★★★\n$340 per night\nRated: 9.4 - Excellent"),
                   accessory: ImageElement(image_url: URL(string: "https://api.slack.com/img/blocks/bkb_template_images/tripAgent_1.png")!,
                                           alt_text: "Windsor Court Hotel thumbnail")),
      ContextBlock(elements: [
        ContextBlock.ContextElement(image: ImageElement(image_url: URL(string: "https://api.slack.com/img/blocks/bkb_template_images/tripAgentLocationMarker.png")!,
                                                        alt_text: "Location Pin Icon")),
        ContextBlock.ContextElement(text: PlainText(text: "Location: Central Business District",
                                                    emoji: true))
        ]
      ),
      DividerBlock(),
      SectionBlock(text: MarkdownText("*<fakeLink.toHotelPage.com|The Ritz-Carlton New Orleans>*\n★★★★★\n$340 per night\nRated: 9.1 - Excellent"),
                   accessory: ImageElement(image_url: URL(string: "https://api.slack.com/img/blocks/bkb_template_images/tripAgent_2.png")!,
                                           alt_text: "Ritz-Carlton New Orleans thumbnail")),
      ContextBlock(elements: [
        ContextBlock.ContextElement(image: ImageElement(image_url: URL(string: "https://api.slack.com/img/blocks/bkb_template_images/tripAgentLocationMarker.png")!,
                                                        alt_text: "Location Pin Icon")),
        ContextBlock.ContextElement(text: PlainText(text: "Location: French Quarter",
                                                    emoji: true))
        ]
      ),
      DividerBlock(),
      SectionBlock(text: MarkdownText("*<fakeLink.toHotelPage.com|Omni Royal Orleans Hotel>*\n★★★★★\n$419 per night\nRated: 8.8 - Excellent"),
                   accessory: ImageElement(image_url: URL(string: "https://api.slack.com/img/blocks/bkb_template_images/tripAgent_3.png")!,
                                           alt_text: "Omni Royal Orleans Hotel thumbnail")),
      ContextBlock(elements: [
        ContextBlock.ContextElement(image: ImageElement(image_url: URL(string: "https://api.slack.com/img/blocks/bkb_template_images/tripAgentLocationMarker.png")!,
                                                        alt_text: "Location Pin Icon")),
        ContextBlock.ContextElement(text: PlainText(text: "Location: French Quarter",
                                                    emoji: true))
        ]
      ),
      DividerBlock(),
      ActionsBlock(elements: [
        ButtonElement(text: PlainText(text: "Next 2 Results",
                                      emoji: true),
                      value: "click_me_123")
        ]
      )
    ]
    let expectedJSON = """
      [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "We found *205 Hotels* in New Orleans, LA from *12/14 to 12/17*"
          },
          "accessory": {
            "type": "overflow",
            "action_id": "123",
            "options": [
              {
                "text": {
                  "type": "plain_text",
                  "emoji": true,
                  "text": "Option One"
                },
                "value": "value-0"
              },
              {
                "text": {
                  "type": "plain_text",
                  "emoji": true,
                  "text": "Option Two"
                },
                "value": "value-1"
              },
              {
                "text": {
                  "type": "plain_text",
                  "emoji": true,
                  "text": "Option Three"
                },
                "value": "value-2"
              },
              {
                "text": {
                  "type": "plain_text",
                  "emoji": true,
                  "text": "Option Four"
                },
                "value": "value-3"
              }
            ]
          }
        },
        {
          "type": "divider"
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "*<fakeLink.toHotelPage.com|Windsor Court Hotel>*\\n★★★★★\\n$340 per night\\nRated: 9.4 - Excellent"
          },
          "accessory": {
            "type": "image",
            "image_url": "https://api.slack.com/img/blocks/bkb_template_images/tripAgent_1.png",
            "alt_text": "Windsor Court Hotel thumbnail"
          }
        },
        {
          "type": "context",
          "elements": [
            {
              "type": "image",
              "image_url": "https://api.slack.com/img/blocks/bkb_template_images/tripAgentLocationMarker.png",
              "alt_text": "Location Pin Icon"
            },
            {
              "type": "plain_text",
              "emoji": true,
              "text": "Location: Central Business District"
            }
          ]
        },
        {
          "type": "divider"
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "*<fakeLink.toHotelPage.com|The Ritz-Carlton New Orleans>*\\n★★★★★\\n$340 per night\\nRated: 9.1 - Excellent"
          },
          "accessory": {
            "type": "image",
            "image_url": "https://api.slack.com/img/blocks/bkb_template_images/tripAgent_2.png",
            "alt_text": "Ritz-Carlton New Orleans thumbnail"
          }
        },
        {
          "type": "context",
          "elements": [
            {
              "type": "image",
              "image_url": "https://api.slack.com/img/blocks/bkb_template_images/tripAgentLocationMarker.png",
              "alt_text": "Location Pin Icon"
            },
            {
              "type": "plain_text",
              "emoji": true,
              "text": "Location: French Quarter"
            }
          ]
        },
        {
          "type": "divider"
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "*<fakeLink.toHotelPage.com|Omni Royal Orleans Hotel>*\\n★★★★★\\n$419 per night\\nRated: 8.8 - Excellent"
          },
          "accessory": {
            "type": "image",
            "image_url": "https://api.slack.com/img/blocks/bkb_template_images/tripAgent_3.png",
            "alt_text": "Omni Royal Orleans Hotel thumbnail"
          }
        },
        {
          "type": "context",
          "elements": [
            {
              "type": "image",
              "image_url": "https://api.slack.com/img/blocks/bkb_template_images/tripAgentLocationMarker.png",
              "alt_text": "Location Pin Icon"
            },
            {
              "type": "plain_text",
              "emoji": true,
              "text": "Location: French Quarter"
            }
          ]
        },
        {
          "type": "divider"
        },
        {
          "type": "actions",
          "elements": [
            {
              "type": "button",
              "text": {
                "type": "plain_text",
                "emoji": true,
                "text": "Next 2 Results"
              },
              "value": "click_me_123"
            }
          ]
        }
      ]
      """
    
    expect{ jsonEncode(object: blocks) == convert(json: expectedJSON) } == true
    
    let message = Message(blocks: blocks,
                          to: self.channel,
                          alternateText: #function)
    
    let webAPI = WebAPI(token: self.token)
    waitUntil(timeout: 10) { done in
        webAPI.send(message: message)
        .observe{ result in
            switch result {
                case .success:
                    break
                case .failure(let error):
                    XCTFail("Unable to send the message: \(error)")
            }
            done()
        }
    }
  }
  
  func testTemplateSearchAdditionalMessage() {
    let blocks = [
      SectionBlock(text: MarkdownText(":mag: Search results for *Cata*")),
      DividerBlock(),
      SectionBlock(text: MarkdownText("*<fakeLink.toYourApp.com|Use Case Catalogue>*\nUse Case Catalogue for the following departments/roles..."),
                   accessory: StaticSelect(placeholder: PlainText(text: "Manage",
                                                                  emoji: true),
                                           action_id: "action-0",
                                           options: [
                                            Option(text: PlainText(text: "Edit it",
                                                                   emoji: true),
                                                   value: "value-0"),
                                            Option(text: PlainText(text: "Read it",
                                                                   emoji: true),
                                                   value: "value-1"),
                                            Option(text: PlainText(text: "Save it",
                                                                   emoji: true),
                                                   value: "value-2")
                    ]
        )
      ),
      SectionBlock(text: MarkdownText("*<fakeLink.toYourApp.com|Customer Support - Workflow Diagram Catalogue>*\nThis resource was put together by members of..."),
                   accessory: StaticSelect(placeholder: PlainText(text: "Manage",
                                                                  emoji: true),
                                           action_id: "action-1",
                                           options: [
                                            Option(text: PlainText(text: "Manage it",
                                                                   emoji: true),
                                                   value: "value-0"),
                                            Option(text: PlainText(text: "Read it",
                                                                   emoji: true),
                                                   value: "value-1"),
                                            Option(text: PlainText(text: "Save it",
                                                                   emoji: true),
                                                   value: "value-2")
                   ]
        )
      ),
      SectionBlock(text: MarkdownText("*<fakeLink.toYourApp.com|Self-Serve Learning Options Catalogue>*\nSee the learning and development options we..."),
                   accessory: StaticSelect(placeholder: PlainText(text: "Manage",
                                                                  emoji: true),
                                           action_id: "action-2",
                                           options: [
                                            Option(text: PlainText(text: "Manage it",
                                                                   emoji: true),
                                                   value: "value-0"),
                                            Option(text: PlainText(text: "Read it",
                                                                   emoji: true),
                                                   value: "value-1"),
                                            Option(text: PlainText(text: "Save it",
                                                                   emoji: true),
                                                   value: "value-2")
                    ]
        )
      ),
      SectionBlock(text: MarkdownText("*<fakeLink.toYourApp.com|Use Case Catalogue - CF Presentation - [June 12, 2018]>*\nThis is presentation will continue to be updated as..."),
                   accessory: StaticSelect(placeholder: PlainText(text: "Manage",
                                                                  emoji: true),
                                           action_id: "action-3",
                                           options: [
                                            Option(text: PlainText(text: "Manage it",
                                                                   emoji: true),
                                                   value: "value-0"),
                                            Option(text: PlainText(text: "Read it",
                                                                   emoji: true),
                                                   value: "value-1"),
                                            Option(text: PlainText(text: "Save it",
                                                                   emoji: true),
                                                   value: "value-2")
                    ]
        )
      ),
      SectionBlock(text: MarkdownText("*<fakeLink.toYourApp.com|Comprehensive Benefits Catalogue - 2019>*\nInformation about all the benfits we offer is..."),
                   accessory: StaticSelect(placeholder: PlainText(text: "Manage",
                                                                  emoji: true),
                                           action_id: "action-4",
                                           options: [
                                            Option(text: PlainText(text: "Manage it",
                                                                   emoji: true),
                                                   value: "value-0"),
                                            Option(text: PlainText(text: "Read it",
                                                                   emoji: true),
                                                   value: "value-1"),
                                            Option(text: PlainText(text: "Save it",
                                                                   emoji: true),
                                                   value: "value-2")
                    ]
        )
      ),
      DividerBlock(),
      ActionsBlock(elements: [
        ButtonElement(text: PlainText(text: "Next 5 Results",
                                      emoji: true),
                      value: "click_me_123")
        ]
      )
    ]
    let expectedJSON = """
      [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": ":mag: Search results for *Cata*"
          }
        },
        {
          "type": "divider"
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "*<fakeLink.toYourApp.com|Use Case Catalogue>*\\nUse Case Catalogue for the following departments/roles..."
          },
          "accessory": {
            "type": "static_select",
            "action_id": "action-0",
            "placeholder": {
              "type": "plain_text",
              "emoji": true,
              "text": "Manage"
            },
            "options": [
              {
                "text": {
                  "type": "plain_text",
                  "emoji": true,
                  "text": "Edit it"
                },
                "value": "value-0"
              },
              {
                "text": {
                  "type": "plain_text",
                  "emoji": true,
                  "text": "Read it"
                },
                "value": "value-1"
              },
              {
                "text": {
                  "type": "plain_text",
                  "emoji": true,
                  "text": "Save it"
                },
                "value": "value-2"
              }
            ]
          }
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "*<fakeLink.toYourApp.com|Customer Support - Workflow Diagram Catalogue>*\\nThis resource was put together by members of..."
          },
          "accessory": {
            "type": "static_select",
            "action_id": "action-1",
            "placeholder": {
              "type": "plain_text",
              "emoji": true,
              "text": "Manage"
            },
            "options": [
              {
                "text": {
                  "type": "plain_text",
                  "emoji": true,
                  "text": "Manage it"
                },
                "value": "value-0"
              },
              {
                "text": {
                  "type": "plain_text",
                  "emoji": true,
                  "text": "Read it"
                },
                "value": "value-1"
              },
              {
                "text": {
                  "type": "plain_text",
                  "emoji": true,
                  "text": "Save it"
                },
                "value": "value-2"
              }
            ]
          }
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "*<fakeLink.toYourApp.com|Self-Serve Learning Options Catalogue>*\\nSee the learning and development options we..."
          },
          "accessory": {
            "type": "static_select",
            "action_id": "action-2",
            "placeholder": {
              "type": "plain_text",
              "emoji": true,
              "text": "Manage"
            },
            "options": [
              {
                "text": {
                  "type": "plain_text",
                  "emoji": true,
                  "text": "Manage it"
                },
                "value": "value-0"
              },
              {
                "text": {
                  "type": "plain_text",
                  "emoji": true,
                  "text": "Read it"
                },
                "value": "value-1"
              },
              {
                "text": {
                  "type": "plain_text",
                  "emoji": true,
                  "text": "Save it"
                },
                "value": "value-2"
              }
            ]
          }
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "*<fakeLink.toYourApp.com|Use Case Catalogue - CF Presentation - [June 12, 2018]>*\\nThis is presentation will continue to be updated as..."
          },
          "accessory": {
            "type": "static_select",
            "action_id": "action-3",
            "placeholder": {
              "type": "plain_text",
              "emoji": true,
              "text": "Manage"
            },
            "options": [
              {
                "text": {
                  "type": "plain_text",
                  "emoji": true,
                  "text": "Manage it"
                },
                "value": "value-0"
              },
              {
                "text": {
                  "type": "plain_text",
                  "emoji": true,
                  "text": "Read it"
                },
                "value": "value-1"
              },
              {
                "text": {
                  "type": "plain_text",
                  "emoji": true,
                  "text": "Save it"
                },
                "value": "value-2"
              }
            ]
          }
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "*<fakeLink.toYourApp.com|Comprehensive Benefits Catalogue - 2019>*\\nInformation about all the benfits we offer is..."
          },
          "accessory": {
            "type": "static_select",
            "action_id": "action-4",
            "placeholder": {
              "type": "plain_text",
              "emoji": true,
              "text": "Manage"
            },
            "options": [
              {
                "text": {
                  "type": "plain_text",
                  "emoji": true,
                  "text": "Manage it"
                },
                "value": "value-0"
              },
              {
                "text": {
                  "type": "plain_text",
                  "emoji": true,
                  "text": "Read it"
                },
                "value": "value-1"
              },
              {
                "text": {
                  "type": "plain_text",
                  "emoji": true,
                  "text": "Save it"
                },
                "value": "value-2"
              }
            ]
          }
        },
        {
          "type": "divider"
        },
        {
          "type": "actions",
          "elements": [
            {
              "type": "button",
              "text": {
                "type": "plain_text",
                "emoji": true,
                "text": "Next 5 Results"
              },
              "value": "click_me_123"
            }
          ]
        }
      ]
      """
    
    expect{ jsonEncode(object: blocks) == convert(json: expectedJSON) } == true
    
    let message = Message(blocks: blocks,
                          to: self.channel,
                          alternateText: #function)
    
    let webAPI = WebAPI(token: self.token)
    
    waitUntil(timeout: 10) { done in
        webAPI.send(message: message)
        .observe{ result in
            switch result {
                case .success:
                    break
                case .failure(let error):
                    XCTFail("Unable to send the message: \(error)")
            }
            done()
        }
    }
  }
  
  func testMessageEphemeral() {
    let webAPI = WebAPI(token: self.token)
    waitUntil(timeout: 10) { done in
        webAPI.send(message: Message(
        blocks: [
            SectionBlock(text: MarkdownText("A *custom* message"))
        ],
        to: self.channel,
        alternateText: #function,
        as: false,
        emoji: ":chart_with_upwards_trend:",
        link: true,
        useMarkdown: true,
        parse: .full,
        unfurl_links: true,
        unfurl_media: true)).then { message in

            webAPI.send(ephemeral: Message(
                blocks: [
                SectionBlock(text: MarkdownText("Only seen to you!"))
                ],
                to: self.channel,
                alternateText: #function),
                        to: self.user)
            }.observe{ result in
                    switch result {
                        case .success:
                            break
                        case .failure(let error):
                            XCTFail("Unable to send the message: \(error)")
                    }
                    done()
                }
            }
  }
  
  func testFailureMessages() {
    let webAPI = WebAPI(token: self.token)
    
    waitUntil(timeout: 10) { done in
        webAPI.send(message: Message(blocks: [],
        to: "No Channel", alternateText: "Not a valid channel"))
        .observe{ result in
                switch result {
                    case .success:
                        XCTFail("This message shouldn't succeed!")
                    case .failure(let error):
                        expect{ error }.to(matchError(MessageError.channel_not_found))
                }
                done()
        }
    }
    
    waitUntil(timeout: 10) { done in
        webAPI.send(ephemeral: Message(blocks: [],
                                    to: self.channel,
                                    alternateText: "Not in this channel"),
                    to: self.user2)
            .observe{ result in
                switch result {
                    case .success:
                        XCTFail("This message shouldn't succeed!")
                    case .failure(let error):
                        expect{ error }.to(matchError(MessageError.user_not_in_channel))
                }
                done()
            }
    }
    
    waitUntil(timeout: 10) { done in
        WebAPI(token: "").send(message: Message(blocks: [],
                                    to: self.channel,
                                    alternateText: "Invalid (empty) token!"))
            .observe{ result in
                switch result {
                    case .success:
                        XCTFail("This message shouldn't succeed!")
                    case .failure(let error):
                        expect{ error }.to(matchError(MessageError.not_authed))
                }
                done()
            }
        }
  }
  
  func testDeleteMessage() {
    let webAPI = WebAPI(token: self.token)
    
    waitUntil(timeout: 10) { done in
        webAPI.send(message: Message(
        blocks: [
            SectionBlock(text: MarkdownText("A message to *delete*"))
        ],
        to: self.channel,
        alternateText: #function))
        .then { message in
            webAPI.delete(message: message)
        }
        .observe{ result in
            switch result {
                case .success:
                    break
                case .failure(let error):
                    XCTFail("\(error)")
            }
            done()
        }
    }
  }
  
  func testDeletionNotExistingMessage() {
    let webAPI = WebAPI(token: self.token)
    
    waitUntil(timeout: 10) { done in
        webAPI.delete(message: Message(blocks: [],
                                    to: "Wrong channel!!!", alternateText: ""))
        .observe{ result in
            switch result {
                case .success:
                    XCTFail("This message cannot succeed.")
                case .failure(let error):
                    expect{ error }.to(matchError(SwiftySlackError.internalError("Cannot delete the message: no parent provided.")))
            }
            done()
        }
    }
    
    waitUntil(timeout: 10) { done in
        webAPI.delete(message: Message(blocks: [],
                                    to: "",
                                    alternateText: ""))
        .observe{ result in
            switch result {
                case .success:
                    XCTFail("This message cannot succeed.")
                case .failure(let error):
                    expect{ error }.to(matchError(SwiftySlackError.internalError("Cannot delete the message: no channel provided.")))
            }
            done()
        }
    }
    
    waitUntil(timeout: 10) { done in
        webAPI.delete(message: Message(blocks: [],
                                    to: "Wrong channel!!!", alternateText: "",
                                    reply: "1234"))
         .observe{ result in
            switch result {
                case .success:
                    XCTFail("This message cannot succeed.")
                case .failure(let error):
                    expect{ error }.to(matchError(MessageError.channel_not_found))
            }
            done()
        }
    }
  }
  
  func testUpdateMessage() {
    let webAPI = WebAPI(token: self.token)
    
    waitUntil(timeout: 10) { done in
        webAPI.send(message: Message(
        blocks: [
            SectionBlock(text: MarkdownText("A *custom* message"))
        ],
        to: self.channel,
        alternateText: #function,
        as: false,
        emoji: ":chart_with_upwards_trend:",
        link: true,
        useMarkdown: true,
        parse: .full,
        unfurl_links: true,
        unfurl_media: true))
        .then { message in
            message.blocks[0] = SectionBlock(text: MarkdownText("A *custom* _updated_ message!"))
            return Promise(value: message)
        }.then { message in
            return webAPI.update(message: message)
        }
        .observe{ result in
            switch result {
                case .success:
                    break
                case .failure(let error):
                    XCTFail("Cannot update the message: \(error).")
            }
            done()
        }
    }
  }
  
  func testUpdateFailureMessage() {
    let webAPI = WebAPI(token: self.token)
    
    waitUntil(timeout: 10) { done in
        webAPI.send(message: Message(
        blocks: [
            SectionBlock(text: MarkdownText("A *custom* message"))
        ],
        to: self.channel,
        alternateText: #function))
        .then { message in
            message.channel = "wrong channel"
            return Promise(value: message)
        }.then { message in
            webAPI.update(message: message)
        }
        .observe { result in
            switch result {
                case .success:
                    XCTFail("This message cannot succeed.")
                case .failure(let error):
                    expect{ error }.to(matchError(MessageError.channel_not_found))
            }
            done()
        }
    }
    
    waitUntil(timeout: 10) { done in
        webAPI.send(message: Message(
        blocks: [
            SectionBlock(text: MarkdownText("A *custom* message"))
        ],
        to: self.channel,
        alternateText: #function))
        .then { message in
            message.thread_ts = nil
            return Promise(value: message)
        }.then { message in
            webAPI.update(message: message)
        }
        .observe{ result in
            switch result {
                case .success:
                    XCTFail("This message cannot succeed.")
                case .failure(let error):
                    expect{ error }.to(matchError(SwiftySlackError.internalError("Cannot update the message: no id provided.")))
            }
            done()
        }
    }
    
    waitUntil(timeout: 10) { done in
        webAPI.send(message: Message(
        blocks: [
            SectionBlock(text: MarkdownText("A *custom* message"))
        ],
        to: self.channel,
        alternateText: #function))
        .then { message in
            message.channel = ""
            return Promise(value: message)
        }.then { message in
            webAPI.update(message: message)
        }
        .observe{ result in
            switch result {
                case .success:
                    XCTFail("This message cannot succeed.")
                case .failure(let error):
                    expect{ error }.to(matchError(SwiftySlackError.internalError("Cannot update the message: no channel provided.")))
            }
            done()
        }
    }
  }
  
  func testScheduleMessage() {
    let webAPI = WebAPI(token: self.token)
    
    waitUntil(timeout: 10) { done in
        webAPI.send(message: Message(
            blocks: [
            SectionBlock(text: MarkdownText("A message from the past"))
            ],
            to: self.channel,
            alternateText: #function),
                    at: Calendar.current.date(byAdding: .second, value: 20, to: Date())!)
        .observe{ result in
                    switch result {
                        case .success(let message):
                            expect{ message.scheduled_message_id }.toNot(beNil())
                        case .failure(let error):
                            XCTFail("Cannot schedule the message: \(error).")
                    }
                    done()
                }
        }

    waitUntil(timeout: 10) { done in
        webAPI.send(message: Message(
        blocks: [
            SectionBlock(text: MarkdownText("A message from the past"))
        ],
        to: self.channel,
        alternateText: #function),
                    at: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        .observe{ result in
            switch result {
                case .success:
                    XCTFail("This message shouldn't succeed!")
                case .failure(let error):
                    expect{ error }.to(matchError(MessageError.time_in_past))
            }
            done()
        }
    }

    waitUntil(timeout: 10) { done in
        webAPI.send(message: Message(
        blocks: [
            SectionBlock(text: MarkdownText("A message from the past"))
        ],
        to: self.channel,
        alternateText: #function),
                    at: Calendar.current.date(byAdding: .day, value: 200, to: Date())!)
        .delay(1)
        .observe{ result in
            switch result {
                case .success:
                    XCTFail("This message shouldn't succeed!")
                case .failure(let error):
                    expect{ error }.to(matchError(MessageError.time_too_far))
            }
            done()
        }
    }
    
    waitUntil(timeout: 10) { done in
        webAPI.send(message: Message(
        blocks: [
            SectionBlock(text: MarkdownText("You shouldn't see that message."))
        ],
        to: self.channel,
        alternateText: #function),
                    at: Calendar.current.date(byAdding: .minute, value: 2, to: Date())!)
        .delay(1)
        .then { message in
            webAPI.delete(message: message)
        }
        .observe{ result in
            switch result {
                case .success:
                    break
                case .failure(let error):
                    XCTFail("\(error)")
            }
            done()
        }
    }
    
    waitUntil(timeout: 10) { done in
        webAPI.send(message: Message(
        blocks: [
            SectionBlock(text: MarkdownText("You will see that message."))
        ],
        to: self.channel,
        alternateText: #function),
                    at: Calendar.current.date(byAdding: .second, value: 30, to: Date())!)
        .then { message in
            message.scheduled_message_id = "000"
            return Promise(value: message)
        }.delay(1)
        .then { message in
            webAPI.delete(message: message)
        }
        .observe{ result in
            switch result {
                case .success:
                    break
                case .failure(let error):
                    expect{ error }.to(matchError(MessageError.invalid_scheduled_message_id))
            }
            done()
        }
    }
  }
  
  func testAddReaction() {
    let webAPI = WebAPI(token: self.token)
    
    waitUntil(timeout: 10) { done in
        webAPI.send(message: Message(
        blocks: [
            SectionBlock(text: MarkdownText("A *custom* message with a reaction"))
        ],
        to: self.channel,
        alternateText: #function))
        .then { message in
            webAPI.add(reaction: "thumbsup", to: message)
        }
        .observe{ result in
            switch result {
                case .success:
                    break
                case .failure(let error):
                    XCTFail("Cannot delete the reaction from the message: \(error).")
            }
            done()
        }
    }
  }
  
  func testRemoveReaction() {
    let webAPI = WebAPI(token: self.token)
    
    waitUntil(timeout: 10) { done in
        webAPI.send(message: Message(
        blocks: [
            SectionBlock(text: MarkdownText("A *custom* message with no reaction"))
        ],
        to: self.channel,
        alternateText: #function))
        .then { message in
            webAPI.add(reaction: "thumbsup", to: message)
        }
        .then { message in
            webAPI.remove(reaction: "thumbsup", to: message)
        }
        .observe{ result in
            switch result {
                case .success:
                    break
                case .failure(let error):
                    XCTFail("Cannot delete the reaction from the message: \(error).")
            }
            done()
        }
    }
  }
  
  static var allTests = [
    ("testMessageComplete", testMessageComplete),
    ("testMessageReply", testMessageReply),
    ("testTemplateApprovalMessage", testTemplateApprovalMessage),
    ("testTemplateApprovalAdvancedMessage", testTemplateApprovalAdvancedMessage),
    ("testTemplateNotificationMessage", testTemplateNotificationMessage),
    ("testTemplateOnboardingMessage", testTemplateOnboardingMessage),
    ("testTemplateOnboardingBotMessage", testTemplateOnboardingBotMessage),
    ("testTemplatePoolMessage", testTemplatePoolMessage),
    ("testTemplateSearchMessage", testTemplateSearchMessage),
    ("testTemplateSearchAdditionalMessage", testTemplateSearchAdditionalMessage),
    ("testMessageEphemeral", testMessageEphemeral),
    ("testFailureMessages", testFailureMessages),
    ("testDeleteMessage", testDeleteMessage),
    ("testDeletionNotExistingMessage", testDeletionNotExistingMessage),
    ("testUpdateMessage", testUpdateMessage),
    ("testUpdateFailureMessage", testUpdateFailureMessage),
    ("testScheduleMessage", testScheduleMessage),
    ("testAddReaction", testAddReaction),
    ("testRemoveReaction", testRemoveReaction),
  ]
}