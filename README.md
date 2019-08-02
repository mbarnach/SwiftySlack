# SwiftySlack

[![Build Status](https://travis-ci.com/mbarnach/SwiftySlack.svg?token=nzWydUsryjTssscwRRAQ&branch=master)](https://travis-ci.com/mbarnach/SwiftySlack)

`SwiftySlack` is a Swift 5.1 package that allows you to create Slack message in Swift.
It creates the new Block type of messages for Slack, and use as much as possible
the property wrappers to prevent invalid messages.

## Example

```swift
let section = SectionBlock(text: Text("A message *with some bold text* and _some italicized text_."))
let message = 
```
