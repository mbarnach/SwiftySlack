//
//  Block.swift
//  
//
//  Created by Mathieu on 12/07/2019.
//

import Foundation

public enum BlockType: String, Encodable {
  case section
  case divider
  case image
  case actions
  case context
  case file
}

public class Block: Encodable {
  public let type: BlockType
  
  @TextLimit(255)
  public var block_id: String
  
  fileprivate init(type: BlockType,
                   block_id: String?) {
    self.type = type
    self.block_id = block_id ?? .Empty()
  }
  
  // MARK: Encoding
  
  enum CodingKeys: String, CodingKey {
    case type
    case block_id
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(type, forKey: .type)
    if block_id != .Empty() {
      try container.encode(block_id, forKey: .block_id)
    }
  }
}

public class SectionBlock: Block {
  
  // Despite the documentation
  // the examples show that text is not required!
  @TextLimit(3000)
  public var text: Text
  
  @CountLimits(10, 2000)
  public var fields: [Text]
  
  public var accessory: Element?
  
  public init(text: Text,
              block_id: String? = nil,
              fields: [Text] = [],
              accessory: Element? = nil) {
    super.init(type: .section, block_id: block_id)
    
    self.text = text
    self.fields = fields
    self.accessory = accessory
  }
  
  public init(block_id: String? = nil,
              fields: [Text],
              accessory: Element? = nil) {
    super.init(type: .section, block_id: block_id)
    
    self.text = .Empty()
    self.fields = fields
    self.accessory = accessory
  }
  
  // MARK: Encoding
  
  enum SectionCodingKeys: String, CodingKey {
    case text
    case fields
    case accessory
  }
  
  public override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: SectionCodingKeys.self)
    if text.text != .Empty() {
      try container.encode(text, forKey: .text)
    }
    if fields.isEmpty == false {
      try container.encode(fields, forKey: .fields)
    }
    if let accessory = accessory {
      try container.encode(accessory, forKey: .accessory)
    }
    try super.encode(to: encoder)
  }
}

public class DividerBlock: Block {
  
  public init(block_id: String? = nil) {
    super.init(type: .divider, block_id: block_id)
  }
}

public class ImageBlock: Block {
  
  @TextLimit(3000)
  public var image_url: URL
  
  @TextLimit(2000)
  public var alt_text: String
  
  @TextLimit(2000)
  public var title: PlainText
  
  public init(image_url: URL,
              alt_text: String,
              title: PlainText? = nil,
              block_id: String? = nil) {
    super.init(type: .image, block_id: block_id)
    
    self.image_url = image_url
    self.alt_text = alt_text
    self.title = title ?? .Empty()
  }
  
  // MARK: Encoding
  
  enum ImageCodingKeys: String, CodingKey {
    case image_url
    case alt_text
    case title
  }
  
  public override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: ImageCodingKeys.self)
    try container.encode(image_url, forKey: .image_url)
    try container.encode(alt_text, forKey: .alt_text)
    if title.text != .Empty() {
      try container.encode(title, forKey: .title)
    }
    try super.encode(to: encoder)
  }
}

public class ActionsBlock: Block {
  
  @CountLimit(5)
  public var elements: [Element]
  
  public init(elements: [Element],
              block_id: String? = nil) {
    super.init(type: .actions, block_id: block_id)
    
    self.elements = elements
  }
  
  // MARK: Encoding
  enum ActionsCodingKeys: String, CodingKey {
    case elements
  }
  
  public override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: ActionsCodingKeys.self)
    try container.encode(elements, forKey: .elements)
    try super.encode(to: encoder)
  }
}

fileprivate extension Text.TextType {
  var toContext: ContextBlock.ContextElementType {
    switch self {
    case .plain_text:
      return .plain_text
    case .mrkdwn:
      return .mrkdwn
    }
  }
}

public class ContextBlock: Block {
  
  enum ContextElementType: String, Encodable {
    case image
    case plain_text
    case mrkdwn
    
    var toText: Text.TextType? {
      switch self {
      case .plain_text:
        return .plain_text
      case .mrkdwn:
        return .mrkdwn
      case .image:
        return nil
      }
    }
  }
  
  public class ContextElement: Encodable {
    // Common part
    let type: ContextElementType
    let alt_text: String
    
    // Image part
    let image_url: URL?
    
    // Text part
    let emoji: Bool?
    let verbatim: Bool?
    
    public init(text: Text) {
      self.type = text.type.toContext
      self.alt_text = text.text
      self.emoji = text.emoji
      self.verbatim = text.verbatim
      
      // Image part
      self.image_url = nil
    }
    
    public init(image: ImageElement) {
      self.type = .image
      self.image_url = image.image_url
      self.alt_text = image.alt_text
      
      // Text part
      self.emoji = nil
      self.verbatim = nil
    }
    
    public var text: Text? {
      switch self.type {
      case .mrkdwn, .plain_text:
        guard let emoji = self.emoji,
          let verbatim = self.verbatim,
          let type = self.type.toText
          else { return nil }
        return Text(text: alt_text,
                    type: type,
                    emoji: emoji,
                    verbatim: verbatim)
      case .image:
        return nil
      }
    }
    
    public var image: ImageElement? {
      switch self.type {
      case .mrkdwn, .plain_text:
        return nil
      case .image:
        guard let image_url = self.image_url
          else { return nil }
        return ImageElement(image_url: image_url,
                            alt_text: alt_text)
      }
    }
    
    // MARK: Encoding
    
    enum ContextElementCodingKeys: String, CodingKey {
      case type
      case alt_text
      case image_url
      case text
      case emoji
      case verbatim
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: ContextElementCodingKeys.self)
      try container.encode(type, forKey: .type)
      switch type {
      case .image:
        try container.encode(alt_text, forKey: .alt_text)
      case .mrkdwn, .plain_text:
        try container.encode(alt_text, forKey: .text)
      }
      if let image_url = image_url {
        try container.encode(image_url, forKey: .image_url)
      }
      if let emoji = emoji {
        try container.encode(emoji, forKey: .emoji)
      }
      if let verbatim = verbatim {
        try container.encode(verbatim, forKey: .verbatim)
      }
    }
  }
  
  @CountLimit(10)
  public var elements: [ContextElement]
  
  public init(elements: [ContextElement],
              block_id: String? = nil) {
    super.init(type: .context, block_id: block_id)
    
    self.elements = elements
  }
  
  // MARK: Encoding
  
  enum ContextCodingKeys: String, CodingKey {
    case elements
  }
  
  public override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: ContextCodingKeys.self)
    try container.encode(elements, forKey: .elements)
    try super.encode(to: encoder)
  }
}

public class FileBlock: Block {
  public enum FileSource: String, Encodable {
    case remote
  }
  
  public var external_id: String
  
  public let source: FileSource = .remote
  
  public init(block_id: String? = nil,
              external_id: String) {
    self.external_id = external_id
    
    super.init(type: .file, block_id: block_id)
  }
  
  // MARK: Encoding
  
  enum FileCodingKeys: String, CodingKey {
    case external_id
    case source
  }
  
  public override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: FileCodingKeys.self)
    try container.encode(external_id, forKey: .external_id)
    try container.encode(source, forKey: .source)
    try super.encode(to: encoder)
  }
}
