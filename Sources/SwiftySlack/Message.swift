//
//  Message.swift
//  
//
//  Created by Mathieu on 12/07/2019.
//

import Foundation

public class Message: Codable {
  public var blocks: [Block]
  
  // Either the message of the fallback.
  public var text: String
  
  // MARK: Metadata
  public enum Parse: String, Codable {
    case full
    case nones
  }
  
  public var channel: String
  public var as_user: Bool?
  public var icon_emoji: String?
  public var icon_url: URL?
  public var link_names: Bool?
  public var mrkdwn: Bool?
  public var parse: Parse?
  public var reply_broadcast: Bool?
  public var thread_ts: String?
  public var unfurl_links: Bool?
  public var unfurl_media: Bool?
  public var username: String?
  
  
  // MARK: Constructors
  
  public init(blocks: [Block],
              to channel: String,
              alternateText text: String?) {
    self.blocks = blocks
    self.channel = channel
    self.text = text ?? .Empty()
  }
  
  public init(blocks: [Block],
              to channel: String,
              alternateText text: String?,
              as as_user: Bool? = nil,
              emoji icon_emoji: String? = nil,
              url icon_url: URL? = nil,
              link link_names: Bool? = nil,
              useMarkdown mrkdwn: Bool? = nil,
              parse: Parse? = nil,
              reply_broadcast: Bool? = nil,
              reply thread_ts: String? = nil,
              unfurl_links: Bool? = nil,
              unfurl_media: Bool? = nil,
              username: String? = nil) {
    self.blocks = blocks
    self.channel = channel
    self.text = text ?? .Empty()
    
    self.as_user = as_user
    if let as_user = as_user, as_user == true {
      // It will be ignored anyway.
    } else {
      self.icon_emoji = icon_emoji
    }
    if let as_user = as_user, as_user == true {
      // It will be ignored anyway.
    } else {
      if icon_emoji == nil {
        self.icon_url = icon_url
      }
    }
    self.link_names = link_names
    self.mrkdwn = mrkdwn
    self.parse = parse
    self.reply_broadcast = reply_broadcast
    self.thread_ts = thread_ts
    self.unfurl_links = unfurl_links
    self.unfurl_media = unfurl_media
    
    if let as_user = as_user, as_user == true {
      // It will be ignored anyway.
    } else {
      self.username = username
    }
  }
  
  // MARK: Decoding
  
  required public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    blocks = try values.decode([Block].self, forKey: .blocks)
//    channel = try values.decode(String.self, forKey: .channel)
    channel = ""
    text = try values.decode(String.self, forKey: .text)
    as_user = try? values.decode(Bool?.self, forKey: .as_user)
    icon_emoji = try? values.decode(String?.self, forKey: .icon_emoji)
    icon_url = try? values.decode(URL?.self, forKey: .icon_url)
    link_names = try? values.decode(Bool?.self, forKey: .link_names)
    mrkdwn = try? values.decode(Bool?.self, forKey: .mrkdwn)
    parse = try? values.decode(Parse?.self, forKey: .parse)
    reply_broadcast = try? values.decode(Bool?.self, forKey: .reply_broadcast)
    thread_ts = try? values.decode(String?.self, forKey: .thread_ts)
    unfurl_links = try? values.decode(Bool?.self, forKey: .unfurl_links)
    unfurl_media = try? values.decode(Bool?.self, forKey: .unfurl_media)
    username = try values.decode(String?.self, forKey: .username)
  }
  
  
  // MARK: Encoding
  
  enum CodingKeys: String, CodingKey {
    case blocks
    case channel
    case text
    case as_user
    case icon_emoji
    case icon_url
    case link_names
    case mrkdwn
    case parse
    case reply_broadcast
    case thread_ts
    case unfurl_links
    case unfurl_media
    case username
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(blocks, forKey: .blocks)
    try container.encode(channel, forKey: .channel)
    if text != .Empty() {
      try container.encode(text, forKey: .text)
    }
    if let as_user = as_user {
      try container.encode(as_user, forKey: .as_user)
    }
    if let icon_emoji = icon_emoji {
      try container.encode(icon_emoji, forKey: .icon_emoji)
    }
    if let icon_url = icon_url {
      try container.encode(icon_url, forKey: .icon_url)
    }
    if let link_names = link_names {
      try container.encode(link_names, forKey: .link_names)
    }
    if let mrkdwn = mrkdwn {
      try container.encode(mrkdwn, forKey: .mrkdwn)
    }
    if let parse = parse {
      try container.encode(parse, forKey: .parse)
    }
    if let reply_broadcast = reply_broadcast {
      try container.encode(reply_broadcast, forKey: .reply_broadcast)
    }
    if let thread_ts = thread_ts {
      try container.encode(thread_ts, forKey: .thread_ts)
    }
    if let unfurl_links = unfurl_links {
      try container.encode(unfurl_links, forKey: .unfurl_links)
    }
    if let unfurl_media = unfurl_media {
      try container.encode(unfurl_media, forKey: .unfurl_media)
    }
    if let username = username {
      try container.encode(username, forKey: .username)
    }
  }
}

internal class ReceivedMessage: Decodable {
  internal struct MetadataResponse: Codable {
      internal var warnings: [String]
  }
  internal var ok: Bool
  internal var warning: String
  internal var response_metadata: MetadataResponse
  internal var ts: String
  internal var channel: String
  
  internal var message: Message
  
  internal func update(with message: Message) -> Message {
    message.blocks = self.message.blocks
    message.text = self.message.text
    message.channel = channel
    message.as_user <- self.message.as_user
    message.icon_emoji <- self.message.icon_emoji
    message.icon_url <- self.message.icon_url
    message.link_names <- self.message.link_names
    message.mrkdwn <- self.message.mrkdwn
    message.parse <- self.message.parse
    message.reply_broadcast <- self.message.reply_broadcast
    message.thread_ts = ts
    message.unfurl_links <- self.message.unfurl_links
    message.unfurl_media <- self.message.unfurl_media
    message.username <- self.message.username
    return message
  }
}

// Assign the right value to a left value optional if right is not nil.
// Otherwise keep the right value.
infix operator <-
internal func <- <T>(lhs: inout T?, rhs: T?) {
  if rhs != nil {
    lhs = rhs
  }
}
