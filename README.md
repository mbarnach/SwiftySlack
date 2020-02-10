# SwiftySlack

[![Swift 5.1](https://img.shields.io/badge/Swift-5.1-orange)](https://swift.org)
[![Swift PM Compatible](https://img.shields.io/badge/SwiftPM-Tools:5.1-FC3324.svg?style=flat)](https://swift.org/package-manager/)
[![](https://img.shields.io/badge/license-Apache-red.svg)](https://choosealicense.com/licenses/apache/)
[![Build Status](https://travis-ci.com/mbarnach/SwiftySlack.svg?token=nzWydUsryjTssscwRRAQ&branch=master)](https://travis-ci.com/mbarnach/SwiftySlack)
[![codecov](https://codecov.io/gh/mbarnach/swiftyslack/branch/master/graph/badge.svg)](https://codecov.io/gh/mbarnach/swiftyslack)

`SwiftySlack` is a Swift 5.1 package that allows you to create Slack messages in Swift.
It uses the new Block type for Slack messages, and as many property wrappers to prevent invalid messages.

## Example

```swift
// Create a block:
let section = SectionBlock(text: Text("A message *with some bold text* and _some italicized text_."))

// Create the message:
let message = Message(blocks: blocks, to: "#general", alternateText: "A message.")

// Send the message:
let webAPI = WebAPI(token: "xoxb-123456789")
webAPI.send(message: message)
```

`SwiftySlack` is using a simple, yet effective [Promises](https://github.com/JohnSundell/SwiftBySundell/blob/master/Blog/Under-the-hood-of-Futures-and-Promises.swift) for the response, instead of using the traditional closure completion handlers.
These promises are coming from an article by John Sundell: [Under the hood of futures and promises in Swift](https://www.swiftbysundell.com/articles/under-the-hood-of-futures-and-promises-in-swift/)
The returned payload is resolved internally: the promise is fulfill if the payload is right, other it is rejected with the error message from Slack. The returned type is the initial Slack message, with metadata fields updated (channel, timestamp for parent manipulation, etc.).

The requests are sent with [SwiftyRequest](https://github.com/IBM-Swift/SwiftyRequest).

You can make complex requests easily, like the Slack Template "Notification":

```swift
let blocks = [
  SectionBlock(text: 
                PlainText(text: "Looks like you have a scheduling conflict with this event:",
                          emoji: true)),
  DividerBlock(),
  SectionBlock(text: 
                MarkdownText("*<fakeLink.toUserProfiles.com|Iris / Zelda 1-1>*\nTuesday, January 21 4:00-4:30pm\nBuilding 2 - Havarti Cheese (3)\n2 guests"),
              accessory: ImageElement(image_url: 
                                        URL(string: 
                                              "https://api.slack.com/img/blocks/bkb_template_images/notifications.png")!,
                                      alt_text: "calendar thumbnail")),
  ContextBlock(elements: [
                ContextBlock.ContextElement(image: 
                                              ImageElement(image_url: 
                                                            URL(string: 
                                                                  "https://api.slack.com/img/blocks/bkb_template_images/notificationsWarningIcon.png")!,
                                                           alt_text: "notifications warning icon")),
                ContextBlock.ContextElement(text: 
                                              MarkdownText("*Conflicts with Team Huddle: 4:15-4:30pm*"))
              ]
  ),
  DividerBlock(),
  SectionBlock(text: MarkdownText("*Propose a new time:*")),
  SectionBlock(text: MarkdownText("*Today - 4:30-5pm*\nEveryone is available: @iris, @zelda"),
               accessory: ButtonElement(text: 
                                          PlainText(text: "Choose",
                                                    emoji: true),
                                        value: "click_me_123")),
  SectionBlock(text: MarkdownText("*Tomorrow - 4-4:30pm*\nEveryone is available: @iris, @zelda"),
               accessory: ButtonElement(text: 
                                          PlainText(text: "Choose",
                                                    emoji: true),
                                        value: "click_me_123")),
  SectionBlock(text: MarkdownText("*Tomorrow - 6-6:30pm*\nSome people aren't available: @iris, ~@zelda~"),
               accessory: ButtonElement(text: 
                                          PlainText(text: "Choose",
                                                    emoji: true),
                                        value: "click_me_123")),
  SectionBlock(text: MarkdownText("*<fakelink.ToMoreTimes.com|Show more times>*"))
]

let message = Message(blocks: blocks,
                      to: channel,
                      alternateText: "Notification")

let webAPI = WebAPI(token: "xoxb-123456789")
webAPI.send(message: message).then { parent in 
  webAPI.send(message: Message(
    blocks: [
      SectionBlock(text: MarkdownText("*Custom* reply 1"))
      ],
      to: channel,
      alternateText: "reply to",
      reply: parent.thread_ts)
}.catch { error in
  print("Something went wrong: \(error).")
}
```

In case of error, you can retrieve a description like that:

```swift
webAPI.send(ephemeral: Message(blocks: [],
                               to: self.channel,
                               alternateText: "Not in this channel"),
            to: "unknown user to this channel")
  .catch { error in
  print("Cannot send the message: \(error.description).")
}
```

![Notification template](NotificationTemplate.png "Slack Notification Template using SwiftySlack")


`SwiftySlack` has been tested on all the Slack blocks templates (see the tests).

## Features:

Currently `SwiftySlack` supports:

* Encoding the whole [Block Kit](https://api.slack.com/block-kit) API.
* Sending messages.
* Sending ephemeral messages.
* Delete messages.
* Update messages.
* Schedule messages and delete them.
* Reaction to messages.

## Notes:

`SwiftySlack` only support the recommanded WebAPI and the Blocks, not the deprecated Attachments.
