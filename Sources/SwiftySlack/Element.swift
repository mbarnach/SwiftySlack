//
//  Element.swift
//  
//
//  Created by Mathieu Barnachon on 13/07/2019.
//

import Foundation

public class Element: Encodable {
  let type: ElementType
  
  public init(type: ElementType) {
    self.type = type
  }
}

public enum ElementType: String, Encodable {
  case image
  case button
  case static_select
  case external_select
  case users_select
  case conversations_select
  case channels_select
  case overflow
  case datepicker
}

public class ImageElement: Element {
  public let image_url: URL
  public let alt_text: String
  
  public init(image_url: URL, alt_text: String) {
    self.image_url = image_url
    self.alt_text = alt_text
    super.init(type: .image)
  }
  
  // MARK: Encoding
  
  enum CodingKeys: String, CodingKey {
    case image_url
    case alt_text
  }
  
  public override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(image_url, forKey: .image_url)
    try container.encode(alt_text, forKey: .alt_text)
    try super.encode(to: encoder)
  }
}

public class ButtonElement: Element {
  public enum ButtonElementStyle: String, Encodable {
    case `default`
    case danger
    case primary
  }
  
  @TextLimit(75)
  public var text: PlainText = .Empty()
  
  // Templates are showing elements without action_id.
  @TextLimit(255)
  public var action_id: String = .Empty()
  
  @TextLimit(3000)
  public var url: URL? = nil
  
  @TextLimit(2000)
  public var value: String? = nil
  
  public var style: ButtonElementStyle? = .default
  
  public var confirm: Confirmation? = nil
  
  public init(text: PlainText,
              action_id: String? = nil,
              url: URL? = nil,
              value: String? = nil,
              style: ButtonElementStyle? = nil,
              confirm: Confirmation? = nil) {
    super.init(type: .button)
    self.text = text
    self.action_id = action_id ?? .Empty()
    self.url = url
    self.value = value
    self.style = style
    self.confirm = confirm
  }
  
  // MARK: Encoding
  
  enum CodingKeys: String, CodingKey {
    case text
    case action_id
    case url
    case value
    case style
    case confirm
  }
  
  public override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(text, forKey: .text)
    // Unclear in the Slack documentation:
    // It is requiered but example about URL doesn't use it.
    // https://api.slack.com/reference/messaging/block-elements#button
    if action_id != .Empty() {
      try container.encode(action_id, forKey: .action_id)
    }
    if let url = url {
      try container.encode(url, forKey: .url)
    }
    if let value = value {
      try container.encode(value, forKey: .value)
    }
    if let style = style {
      try container.encode(style, forKey: .style)
    }
    if let confirm = confirm {
      try container.encode(confirm, forKey: .confirm)
    }
    try super.encode(to: encoder)
  }
}

public protocol Select {
  
//  @TextLimit(150)
  var placeholder: PlainText { get }
  
//  @TextLimit(255)
  var action_id: String { get }
  
  var confirm: Confirmation? { get }
}

public class StaticSelect: Element, Select {
  
  @TextLimit(150)
  public var placeholder: PlainText
  
  @TextLimit(255)
  public var action_id: String
  
  public var confirm: Confirmation?
  
  @CountLimit(100)
  public var options: [Option]
  
  @CountLimit(100)
  public var option_groups: [OptionGroup]
  
  public init(placeholder: PlainText,
              action_id: String,
              options: [Option],
              confirm: Confirmation? = nil) {
    super.init(type: .static_select)
    self.placeholder = placeholder
    self.action_id = action_id
    self.confirm = confirm
    self.options = options
    self.option_groups = []
  }
  
  public init(placeholder: PlainText,
              action_id: String,
              option_groups: [OptionGroup],
              confirm: Confirmation? = nil) {
    super.init(type: .static_select)
    self.placeholder = placeholder
    self.action_id = action_id
    self.confirm = confirm
    self.option_groups = option_groups
    self.options = []
  }
  
  // MARK: Encoding
  
  enum CodingKeys: String, CodingKey {
    case placeholder
    case action_id
    case confirm
    case options
    case option_groups
  }
  
  public override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(placeholder, forKey: .placeholder)
    try container.encode(action_id, forKey: .action_id)
    if let confirm = confirm {
      try container.encode(confirm, forKey: .confirm)
    }
    if false == options.isEmpty {
      try container.encode(options, forKey: .options)
    }
    if false == option_groups.isEmpty {
      try container.encode(option_groups, forKey: .option_groups)
    }
    try super.encode(to: encoder)
  }
}

public class ExternalSelect: Element, Select {
  
  @TextLimit(150)
  public var placeholder: PlainText
  
  @TextLimit(255)
  public var action_id: String
  
  public var confirm: Confirmation?
  
  public var initial_option: Option?
  
  public var min_query_length: Int?
  
  public init(placeholder: PlainText,
              action_id: String,
              initial_option: Option? = nil,
              min_query_length: Int? = nil,
              confirm: Confirmation? = nil) {
    self.min_query_length = min_query_length
    super.init(type: .external_select)
    self.initial_option = initial_option
    self.placeholder = placeholder
    self.action_id = action_id
    self.confirm = confirm
  }
  
  // MARK: Encoding
  
  enum CodingKeys: String, CodingKey {
    case placeholder
    case action_id
    case confirm
    case initial_option
    case min_query_length
  }
  
  public override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(placeholder, forKey: .placeholder)
    try container.encode(action_id, forKey: .action_id)
    if let confirm = confirm {
      try container.encode(confirm, forKey: .confirm)
    }
    if let initial_option = initial_option {
      try container.encode(initial_option, forKey: .initial_option)
    }
    if let min_query_length = min_query_length {
      try container.encode(min_query_length, forKey: .min_query_length)
    }
    try super.encode(to: encoder)
  }
}

public class UsersSelect: Element&Select {
  
  @TextLimit(150)
  public var placeholder: PlainText
  
  @TextLimit(255)
  public var action_id: String
  
  public var confirm: Confirmation?
  
  public var initial_user: String?
  
  public init(placeholder: PlainText,
              action_id: String,
              initial_user: String? = nil,
              confirm: Confirmation? = nil) {
    self.initial_user = initial_user
    super.init(type: .users_select)
    self.placeholder = placeholder
    self.action_id = action_id
    self.confirm = confirm
  }
  
  // MARK: Encoding
  
  enum CodingKeys: String, CodingKey {
    case placeholder
    case action_id
    case confirm
    case initial_user
  }
  
  public override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(placeholder, forKey: .placeholder)
    if action_id != .Empty() {
      try container.encode(action_id, forKey: .action_id)
    }
    if let confirm = confirm {
      try container.encode(confirm, forKey: .confirm)
    }
    if let initial_user = initial_user {
      try container.encode(initial_user, forKey: .initial_user)
    }
    try super.encode(to: encoder)
  }
}

public class ConversationSelect: Element, Select {
  
  @TextLimit(150)
  public var placeholder: PlainText
  
  @TextLimit(255)
  public var action_id: String
  
  public var confirm: Confirmation?
  
  public var initial_conversation: String?
  
  public init(placeholder: PlainText,
              action_id: String,
              initial_conversation: String? = nil,
              confirm: Confirmation? = nil) {
    self.initial_conversation = initial_conversation
    super.init(type: .conversations_select)
    self.placeholder = placeholder
    self.action_id = action_id
    self.confirm = confirm
  }
  
  // MARK: Encoding
  
  enum CodingKeys: String, CodingKey {
    case placeholder
    case action_id
    case confirm
    case initial_conversation
  }
  
  public override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(placeholder, forKey: .placeholder)
    try container.encode(action_id, forKey: .action_id)
    if let confirm = confirm {
      try container.encode(confirm, forKey: .confirm)
    }
    if let initial_conversation = initial_conversation {
      try container.encode(initial_conversation, forKey: .initial_conversation)
    }
    try super.encode(to: encoder)
  }
}

public class ChannelSelect: Element, Select {
  
  @TextLimit(150)
  public var placeholder: PlainText
  
  @TextLimit(255)
  public var action_id: String
  
  public var confirm: Confirmation?
  
  public var initial_channel: String?
  
  public init(placeholder: PlainText,
              action_id: String,
              initial_channel: String? = nil,
              confirm: Confirmation? = nil) {
    self.initial_channel = initial_channel
    super.init(type: .channels_select)
    self.placeholder = placeholder
    self.action_id = action_id
    self.confirm = confirm
  }
  
  // MARK: Encoding
  
  enum CodingKeys: String, CodingKey {
    case placeholder
    case action_id
    case confirm
    case initial_channel
  }
  
  public override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(placeholder, forKey: .placeholder)
    try container.encode(action_id, forKey: .action_id)
    if let confirm = confirm {
      try container.encode(confirm, forKey: .confirm)
    }
    if let initial_channel = initial_channel {
      try container.encode(initial_channel, forKey: .initial_channel)
    }
    try super.encode(to: encoder)
  }
}

public class OverflowElement: Element {
  
  @TextLimit(255)
  public var action_id: String
  
  @RangeLimit(2, 10)
  public var options: [Option] = []
  
  public var confirm: Confirmation?
  
  public init(action_id: String,
              options: [Option],
              confirm: Confirmation? = nil) {
    super.init(type: .overflow)
    self.action_id = action_id
    self.options = options
    self.confirm = confirm
  }
  
  
  // MARK: Encoding
  
  enum CodingKeys: String, CodingKey {
    case action_id
    case options
    case confirm
  }
  
  public override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(action_id, forKey: .action_id)
    try container.encode(options, forKey: .options)
    if let confirm = confirm {
      try container.encode(confirm, forKey: .confirm)
    }
    try super.encode(to: encoder)
  }
}

public class DatePickerElement: Element {
  
  @TextLimit(150)
  public var placeholder: PlainText = .Empty()
  
  @TextLimit(255)
  public var action_id: String = .Empty()
  
  public var initial_date: Date = Date()
  
  public var confirm: Confirmation? = nil
  
  public init(placeholder: PlainText,
              action_id: String,
              initial_date: Date,
              confirm: Confirmation? = nil) {
    super.init(type: .datepicker)
    self.placeholder = placeholder
    self.action_id = action_id
    self.initial_date = initial_date
    self.confirm = confirm
  }
  
  // MARK: Encoding
  
  /// Create a string from a date in the format: `yyyy-MM-dd`
  /// - Parameter dateString: The string representing the date.
  public static func date(from dateString: String) -> Date? {
    let formatter = DateFormatter.yyyyMMdd
    return formatter.date(from: dateString)
  }
  
  public static func date(to date: Date) -> String {
    let formatter = DateFormatter.yyyyMMdd
    return formatter.string(from: date)
  }
  
  enum CodingKeys: String, CodingKey {
    case placeholder
    case action_id
    case initial_date
    case confirm
  }
  
  public override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(placeholder, forKey: .placeholder)
    try container.encode(action_id, forKey: .action_id)
    try container.encode(Self.date(to: initial_date), forKey: .initial_date)
    if let confirm = confirm {
      try container.encode(confirm, forKey: .confirm)
    }
    try super.encode(to: encoder)
  }
}

extension DateFormatter {
  static let yyyyMMdd: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
}
