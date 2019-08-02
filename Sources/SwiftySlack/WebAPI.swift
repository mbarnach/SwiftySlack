//
//  File.swift
//  
//
//  Created by Mathieu Barnachon on 02/08/2019.
//

import Foundation
import SwiftyRequest
import SwiftyJSON
import Promises

public enum SwiftySlackError: Error {
  case internalError(String)
  case slackError(String)
}

public struct WebAPI {
  public var token: String
  
  private let jsonEncoder = JSONEncoder()
  
  public init(token: String) {
    self.token = token
    jsonEncoder.outputFormatting = .prettyPrinted
  }
  
  public func send(message: Message) -> Promise<SwiftyJSON.JSON> {
    let request = RestRequest(method: .post, url: "https://slack.com/api/chat.postMessage")
    request.credentials = .bearerAuthentication(token: token)
    request.acceptType = "application/json"
    
    return Promise { fulfill, reject in
      do {
      request.messageBody = try self.jsonEncoder.encode(message)
      } catch let error {
        reject(error)
      }
      request.responseData{ response in
        switch response.result {
        case .success(let retval):
          do {
            let json = try JSON(data: retval)
            if let ack = json["ok"].bool, ack == true {
              fulfill(json)
            } else {
              let error = json["error"].string ?? "Unknown error"
              reject(SwiftySlackError.slackError(error))
            }
          } catch let error {
            reject(error)
          }
        case .failure(let error):
          reject(error)
        }
      }
    }
  }
}