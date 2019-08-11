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

public enum MessageError: String, Error {
  case message_not_found
  case cant_delete_message
  case compliance_exports_prevent_deletion
  case not_in_channel
  case restricted_action_read_only_channel
  case restricted_action_thread_only_channel
  case restricted_action_non_threadable_channel
  case rate_limited
  case as_user_not_supported
  case restricted_action
  case too_many_attachments
  case is_archived
  case channel_not_found
  case msg_too_long
  case no_text
  case user_not_in_channel
  case not_authed
  case invalid_auth
  case account_inactive
  case token_revoked
  case no_permission
  case org_login_required
  case ekm_access_denied
  case missing_scope
  case invalid_arguments
  case invalid_arg_name
  case invalid_charset
  case invalid_form_data
  case invalid_post_type
  case missing_post_type
  case team_added_to_org
  case request_timeout
  case fatal_error
  
  var description: String {
    switch self {
    case .message_not_found:
      return "No message exists with the requested timestamp."
    case .cant_delete_message:
      return "Authenticated user does not have permission to delete this message."
    case .compliance_exports_prevent_deletion:
      return "Compliance exports are on, messages can not be deleted."
    case .not_in_channel:
      return "Cannot post user messages to a channel they are not in."
    case .restricted_action_read_only_channel:
      return "Cannot post any message into a read-only channel."
    case .restricted_action_thread_only_channel:
      return "Cannot post top-level messages into a thread-only channel."
    case .restricted_action_non_threadable_channel:
      return "Cannot post thread replies into a non_threadable channel."
    case .rate_limited:
      return "Application has posted too many messages, read the Rate Limit documentation for more information"
    case .as_user_not_supported:
      return "The as_user parameter does not function with workspace apps."
    case .restricted_action:
      return "A workspace preference prevents the authenticated user from posting"
    case .too_many_attachments:
      return "Too many attachments were provided with this message. A maximum of 100 attachments are allowed on a message."
    case .is_archived:
      return "Channel has been archived."
    case .channel_not_found:
      return "Value passed for channel was invalid."
    case .msg_too_long:
      return "Message text is too long."
    case .no_text:
      return "No message text provided."
    case .user_not_in_channel:
      return "Intended recipient is not in the specified channel."
    case .not_authed:
      return "No authentication token provided."
    case .invalid_auth:
      return "Some aspect of authentication cannot be validated. Either the provided token is invalid or the request originates from an IP address disallowed from making the request."
    case .account_inactive:
      return "Authentication token is for a deleted user or workspace."
    case .token_revoked:
      return "Authentication token is for a deleted user or workspace or the app has been removed."
    case .no_permission:
      return "The workspace token used in this request does not have the permissions necessary to complete the request. Make sure your app is a member of the conversation it's attempting to post a message to."
    case .org_login_required:
      return "The workspace is undergoing an enterprise migration and will not be available until migration is complete."
    case .ekm_access_denied:
      return "Administrators have suspended the ability to post a message."
    case .missing_scope:
      return "The token used is not granted the specific scope permissions required to complete this request."
    case .invalid_arguments:
      return "The method was called with invalid arguments."
    case .invalid_arg_name:
      return "The method was passed an argument whose name falls outside the bounds of accepted or expected values. This includes very long names and names with non-alphanumeric characters other than _. If you get this error, it is typically an indication that you have made a very malformed API call."
    case .invalid_charset:
      return "The method was called via a POST request, but the charset specified in the Content-Type header was invalid. Valid charset names are: utf-8 iso-8859-1."
    case .invalid_form_data:
      return "The method was called via a POST request with Content-Type application/x-www-form-urlencoded or multipart/form-data, but the form data was either missing or syntactically invalid."
    case .invalid_post_type:
      return "The method was called via a POST request, but the specified Content-Type was invalid. Valid types are: application/json application/x-www-form-urlencoded multipart/form-data text/plain."
    case .missing_post_type:
      return "The method was called via a POST request and included a data payload, but the request did not include a Content-Type header."
    case .team_added_to_org:
      return "The workspace associated with your request is currently undergoing migration to an Enterprise Organization. Web API and other platform operations will be intermittently unavailable until the transition is complete."
    case .request_timeout:
      return "The method was called via a POST request, but the POST data was either missing or truncated."
    case .fatal_error:
      return "The server could not complete your operation(s) without encountering a catastrophic error. It's possible some aspect of the operation succeeded before the error was raised."
    }
  }
}

public struct WebAPI {
  public var token: String
  
  private let jsonEncoder = JSONEncoder()
  
  public init(token: String) {
    self.token = token
    jsonEncoder.outputFormatting = .prettyPrinted
  }
  
  public func send(message: Message) -> Promise<Message> {
    return send(message: message, to: "https://slack.com/api/chat.postMessage")
  }
  
  public func send(ephemeral message: Message, to user: String) -> Promise<Message> {
    message.user = user
    return send(message: message, to: "https://slack.com/api/chat.postEphemeral")
  }
  
  public func delete(message: Message) -> Promise<Message> {
    guard message.thread_ts != nil else {
      return Promise<Message> { _, reject in
        reject(SwiftySlackError.internalError("Cannot delete the message: no parent provided."))
      }
    }
    guard message.channel != .Empty() else {
      return Promise<Message> { _, reject in
        reject(SwiftySlackError.internalError("Cannot delete the message: no channel provided."))
      }
    }
    message.tsOrNot = true
    return send(message: message, to: "https://slack.com/api/chat.delete")
  }
  
  private func send(message: Message, to url: String) -> Promise<Message> {
    let request = RestRequest(method: .post, url: url)
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
            let decoder = JSONDecoder()
              let receivedMessage = try decoder.decode(ReceivedMessage.self, from: retval)
            if receivedMessage.ok != true {
              let error: Error = MessageError(rawValue: receivedMessage.error ?? "") ?? SwiftySlackError.slackError("Unrecognized error")
              reject(error)
            } else {
              fulfill(receivedMessage.update(with: message))
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
