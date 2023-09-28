//
//  LSClient.swift
//  iCode
//
//  Created by morinoyu8 on 06/23/23.
//

import Foundation
import UIKit
import Runestone

// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#requestMessage
struct RequestMessage<T: Codable>: Codable {
    var jsonrpc: String = "2.0"
    var id: Int
    var method: String
    var params: T
}

// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#notificationMessage
struct NotificationMessage<T: Codable>: Codable {
    var jsonrpc: String = "2.0"
    var method: String
    var params: T
}

// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#responseMessage
struct ResponseMessage: Codable {
    var jsonrpc: String
    var id: Int?
}


class LSClient {
    
    // Name of LS communicating with this client.
    let name: String
    
    // id is included in a request to LS.
    // id does not duplicate another request.
    static var id: Int = 1
    
    // Link id to method when sending request.
    // Since the response contains only id, Identify method from id when recieving a response.
    static var id2Method: [Int: LSRequestMethod] = [:]
    
    enum LSClientError: Error {
        case FailConvertString
    }
    
    
    init(name: String) {
        self.name = name
    }
    
    
    // Send request to LS.
    // params is a structure corresponding to method.
    func sendRequest<T: Codable>(method: LSRequestMethod, params: T) {
        let requestMessage = RequestMessage(id: LSClient.id, method: method.rawValue, params: params)
        do {
            let jsonData = try JSONEncoder().encode(requestMessage)
            let sendMessage = try convertDataForLS(data: jsonData)
            sendMessageToServer(message: sendMessage)
            LSClient.id2Method.updateValue(method, forKey: LSClient.id)
            LSClient.id += 1
        } catch LSClientError.FailConvertString {
            print("\(method.rawValue): Converting String error")
        } catch {
            print("\(method.rawValue) request message encoding error: \(error).")
        }
    }
    
    // Send notification to LS.
    // params is a structure corresponding to method.
    func sendNotification<T: Codable>(method: LSNotificationMethod, params: T) {
        
        let notificationMessage = NotificationMessage(method: method.rawValue, params: params)
        do {
            let jsonData = try JSONEncoder().encode(notificationMessage)
            let sendMessage = try convertDataForLS(data: jsonData)
            sendMessageToServer(message: sendMessage)
        } catch LSClientError.FailConvertString {
            print("\(method.rawValue): Converting String error")
        } catch {
            print("Send notification message error: \(error).")
        }
    }
    
    // Convert to format to send to LS.
    // Throws an error if conversion to string fails.
    private func convertDataForLS(data: Data) throws -> String {
        guard let string = String(data: data, encoding: .utf8) else {
            throw LSClientError.FailConvertString
        }
        let contentLength = string.utf8.count
        return "Content-Length: \(contentLength)\r\n\(string)\n"
    }
    
    private func sendMessageToServer(message: String) {
        let length = message.utf8.count
        send_server(message, Int32(length))
    }
    
    
    // Called when the client recieves a response from LS.
    static func recieveResponse(message: String) {
        // If message is not in JSON format, this method does nothing.
        if message.first != "{" {
            return
        }
        
        do {
            // Decode response to temporary structure ResponseMessage
            // to get the corresponding method.
            guard let data = message.data(using: .utf8) else {
                print("Converting responce message to data error.")
                return
            }
            let response = try JSONDecoder().decode(ResponseMessage.self, from: data)
            
            // Get method corresponding to id from id2Method
            guard let id = response.id else { return }
            guard let method = id2Method[id] else {
                print("Cannot find corresponding method to id(\(id))")
                return
            }
            // id received from response is removed
            id2Method.removeValue(forKey: id)
            
            switch (method) {
            case .initialize:
                recieveInitialize(responseMessage: message)
            case .textDocumentCompletion:
                recieveTextDocumentCompletion(responceMessage: message)
            }
            
        } catch {
            // If the response message cannot be decoded to ResponseMessage structure,
            // it may be error response.
            // TODO: error response
            print("Recieve Data error: \(error).")
        }
    }
}
