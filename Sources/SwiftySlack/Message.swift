//
//  Message.swift
//  
//
//  Created by Mathieu on 12/07/2019.
//

import Foundation

public class Message: Encodable {
  public var blocks: [Block]
  
  // Either the message of the fallback.
  public var text: String
  
  // MARK: Metadata
  public enum Parse: String, Encodable {
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
  public var user: String? // Only for ephemeral messages.
  
  
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
    if as_user == nil || as_user == false {
      self.username = username
      if icon_emoji == nil {
        self.icon_url = icon_url
      } else {
        self.icon_emoji = icon_emoji
      }
    }
    self.link_names = link_names
    self.mrkdwn = mrkdwn
    self.parse = parse
    self.reply_broadcast = reply_broadcast
    self.thread_ts = thread_ts
    self.unfurl_links = unfurl_links
    self.unfurl_media = unfurl_media
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
    case user
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
    if let user = user {
      try container.encode(user, forKey: .user)
    } else if let thread_ts = thread_ts {
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
  internal struct MetadataResponse: Decodable {
    internal var warnings: [String] = []
    internal var messages: [String] = []
  }
  internal var ok: Bool
  internal var warning: String?
  internal var response_metadata: MetadataResponse?
  internal var ts: String?
  internal var channel: String
  internal var error: String?
  
  internal var message: Message?
  
  internal func update(with message: Message) -> Message {
    message.channel = channel
    message.thread_ts = ts
    return message
  }
  
  // MARK: Decoding
  
  enum CodingKeys: String, CodingKey {
    case ok
    case warning
    case response_metadata
    case ts
    case channel
    case error
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    ok = try values.decode(Bool.self, forKey: .ok)
    warning = try? values.decode(String?.self, forKey: .warning)
    response_metadata = try? values.decode(MetadataResponse.self, forKey: .response_metadata)
    ts = try? values.decode(String.self, forKey: .ts)
    channel = (try? values.decode(String.self, forKey: .channel)) ?? ""
    error = try? values.decode(String.self, forKey: .error)
  }
}
