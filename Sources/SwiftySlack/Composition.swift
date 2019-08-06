//
//  Composition.swift
//  
//
//  Created by Mathieu on 13/07/2019.
//

import Foundation

/// An object containing some text, formatted either as plain_text or using Slack's "mrkdwn".
public class Text: Codable {
  public enum TextType: String, Codable {
    case plain_text
    case mrkdwn
  }
  public let type: TextType
  public var text: String
  public var emoji: Bool?
  public var verbatim: Bool?
  
  public init(text: String, type: TextType, emoji: Bool? = nil, verbatim: Bool? = nil) {
    self.text = text
    self.type = type
    self.emoji = emoji
    self.verbatim = verbatim
  }
  
  public required init(_ text: String) {
    self.text = text
    self.type = .mrkdwn
    self.emoji = nil
    self.verbatim = nil
  }
}

extension Text: Equatable {
  public static func ==(lhs: Text, rhs: Text) -> Bool {
    return lhs.type == rhs.type &&
      lhs.text == rhs.text &&
      lhs.emoji == rhs.emoji &&
      lhs.verbatim == rhs.verbatim
  }
}

public class PlainText: Text {
  public init(text: String, emoji: Bool? = nil, verbatim: Bool? = nil) {
    super.init(text: text, type: .plain_text, emoji: emoji, verbatim: verbatim)
  }
  
  public required init(_ text: String) {
    super.init(text: text, type: .plain_text, emoji: nil, verbatim: nil)
  }
  
  // MARK: Decoding
  
  required public init(from decoder: Decoder) throws {
    try super.init(from: decoder)
  }
}

public class MarkdownText: Text {
  public init(text: String, emoji: Bool? = nil, verbatim: Bool? = nil) {
    super.init(text: text, type: .mrkdwn, emoji: emoji, verbatim: verbatim)
  }
  
  public required init(_ text: String) {
    super.init(text: text, type: .mrkdwn, emoji: nil, verbatim: nil)
  }
  
  // MARK: Decoding
  
  required public init(from decoder: Decoder) throws {
    try super.init(from: decoder)
  }
}


public class Confirmation: Codable {
  @TextLimit(100)
  public var title: PlainText
  
  @TextLimit(300)
  public var text: Text
  
  @TextLimit(30)
  public var confirm: PlainText
  
  @TextLimit(30)
  public var deny: PlainText
  
  public required init(title: PlainText, text: Text, confirm: PlainText, deny: PlainText) {
    self.title = title
    self.text = text
    self.confirm = confirm
    self.deny = deny
  }
  
  // MARK: Decoding
  
  required public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    title = try values.decode(PlainText.self, forKey: .title)
    text = try values.decode(Text.self, forKey: .text)
    confirm = try values.decode(PlainText.self, forKey: .confirm)
    deny = try values.decode(PlainText.self, forKey: .deny)
  }
  
  // MARK: Encoding
  
  enum CodingKeys: String, CodingKey {
    case title
    case text
    case confirm
    case deny
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(title, forKey: .title)
    try container.encode(text, forKey: .text)
    try container.encode(confirm, forKey: .confirm)
    try container.encode(deny, forKey: .deny)
  }
}

public class Option: Codable {
  @TextLimit(75)
  public var text: PlainText
  
  @TextLimit(75)
  public var value: String
  
  @TextLimit(3000)
  public var url: URL?
  
  public required init(text: PlainText, value: String, url: URL? = nil) {
    self.text = text
    self.value = value
    self.url = url
  }
  
  // MARK: Decoding
  
  required public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    text = try values.decode(PlainText.self, forKey: .text)
    value = try values.decode(String.self, forKey: .value)
    url = try? values.decode(URL?.self, forKey: .url)
  }
  
  // MARK: Encoding
  enum CodingKeys: String, CodingKey {
    case text
    case value
    case url
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(text, forKey: .text)
    try container.encode(value, forKey: .value)
    if let url = url {
      try container.encode(url, forKey: .url)
    }
  }
}

extension Option: Equatable {
  public static func ==(lhs: Option, rhs: Option) -> Bool {
    return lhs.text == rhs.text &&
      lhs.value == rhs.value &&
      lhs.url == rhs.url
  }
}

public class OptionGroup: Codable {
  @TextLimit(75)
  public var label: PlainText
  
  @CountLimit(100)
  public var options: [Option]
  
  public required init(label: PlainText, options: [Option]) {
    self.label = label
    self.options = options
  }
  
  // MARK: Decoding
  
  required public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    label = try values.decode(PlainText.self, forKey: .label)
    options = try values.decode([Option].self, forKey: .options)
  }
  
  // MARK: Encoding
  
  enum CodingKeys: String, CodingKey {
    case label
    case options
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(label, forKey: .label)
    try container.encode(options, forKey: .options)
  }
}
