//
//  LSClient.swift
//  iCode
//
//  Created by morinoyu8 on 06/23/23.
//

import Foundation
import UIKit
import Runestone

class LSClient {
    
    static var currentLanguage: CodeLanguage = .c
    static var id: Int = 1
    static var id2Method: [Int: LSMethod] = [:]
    static var codeVC: CodeViewController? = nil
    
    static func recieveData(data: String) {
        print(data)
        if data.first != "{" {
            return
        }
        
        do {
            let jsonData = try JSONDecoder().decode(Data_Recieve.self, from: data.data(using: .utf8)!)
            guard let id = jsonData.id else { return }
            guard let method = id2Method[id] else { return }
            id2Method.removeValue(forKey: id)
            switch (method) {
            case LSMethod.Initialize:
                recieveInitialize(json: data)
                break
            case LSMethod.TextDocument_Completion:
                recieveCompletion(json: data)
                break
            default:
                return
            }
            
        } catch {
            print("Recieve Data error: \(error).")
            return
        }
    }
    
    private static func recieveInitialize(json: String) {
        initialized()
    }
    
    private static func recieveCompletion(json: String) {
        do {
            let data = try JSONDecoder().decode(Completion_Recieve.self, from: json.data(using: .utf8)!)
            let complationItems: [CompletionItem] = data.result.items
            DispatchQueue.main.async {
                codeVC?.showCompletion(data: complationItems)
            }
        } catch {
            print("RecieveCompletion error: \(error).")
        }
    }
    
    
    private static func sendData(json: String) {
        id += 1
        let contentLength = json.utf8.count
        let sendData = "Content-Length: \(contentLength)\r\n\(json)\n"
        let length = sendData.utf8.count
        send_server(sendData, Int32(length))
    }
    
    //
    //  initialize
    //
    static func initialize() {
        let uri = URL(fileURLWithPath: "/").absoluteString
        let initializeParams = InitializeParams(processId: 1, rootUri: uri, capabilities: [])
        let initialize = Initialize(id: id, method: "initialize", params: initializeParams)
        let initializeData = try! JSONEncoder().encode(initialize)
        let initializeString = String(data: initializeData, encoding: .utf8)!
        id2Method.updateValue(LSMethod.Initialize, forKey: id)
        sendData(json: initializeString)
    }
    
    //
    //  initialized
    //
    static func initialized() {
        let initialized = Initialized(method: "initialized", params: InitializedParams())
        let initializedData = try! JSONEncoder().encode(initialized)
        let initializedString = String(data: initializedData, encoding: .utf8)!
        id2Method.updateValue(LSMethod.Initialized, forKey: id)
        sendData(json: initializedString)
    }
    
    //
    //  textDocument/didOpen
    //
    static func textDocument_didOpen(path: String, text: String) {
        let uri = URL(fileURLWithPath: path).absoluteString
        let textDocumentItem = TextDocumentItem(uri: uri, languageId: "cpp", version: 0, text: text)
        let didOpenTextDocumentParams = DidOpenTextDocumentParams(textDocument: textDocumentItem)
        let didOpen = DidOpen(method: "textDocument/didOpen", params: didOpenTextDocumentParams)
        let didOpenData = try! JSONEncoder().encode(didOpen)
        let didOpenString = String(data: didOpenData, encoding: .utf8)!
        id2Method.updateValue(LSMethod.TextDocument_DidOpen, forKey: id)
        sendData(json: didOpenString)
    }
    
    //
    //  textDocument/didChange
    //
    static func textDocument_didChange(path: String, text: String, startLocation start: TextLocation? = nil, endLocation end: TextLocation? = nil) {
        let uri = URL(fileURLWithPath: path).absoluteString
        let versionedTextDocumentIdentifier = VersionedTextDocumentIdentifier(uri: uri, version: 1)
        
        let createTextDocumentContentChangeEvent = {
            if start == nil || end == nil {
                return TextDocumentContentChangeEvent(text: text)
            }
            let startPosition = Position(line: start!.lineNumber, character: start!.column)
            let endPosition = Position(line: end!.lineNumber, character: end!.column)
            let range = Range(start: startPosition, end: endPosition)
            return TextDocumentContentChangeEvent(range: range, text: text)
        }
        
        let textDocumentContentChangeEvent = createTextDocumentContentChangeEvent()
        let didChangeTextDocumentParams = DidChangeTextDocumentParams(textDocument: versionedTextDocumentIdentifier, contentChanges: [textDocumentContentChangeEvent])
        let didChange = DidChange(method: "textDocument/didChange", params: didChangeTextDocumentParams)
        let didChangeData = try! JSONEncoder().encode(didChange)
        let didChangeString = String(data: didChangeData, encoding: .utf8)!
        id2Method.updateValue(LSMethod.TextDocument_DidChange, forKey: id)
        sendData(json: didChangeString)
    }
    
    //
    //  textDocument/completion
    //
    static func textDocument_completion(path: String, line: Int, character: Int) {
        let uri = URL(fileURLWithPath: path).absoluteString
        let textDocumentIdentifier = TextDocumentIdentifier(uri: uri)
        let position = Position(line: line, character: character)
        let completionParams = CompletionParams(textDocument: textDocumentIdentifier, position: position)
        let completion = Completion(id: self.id, method: "textDocument/completion", params: completionParams)
        let completionData = try! JSONEncoder().encode(completion)
        let completionString = String(data: completionData, encoding: .utf8)!
        id2Method.updateValue(LSMethod.TextDocument_Completion, forKey: id)
        sendData(json: completionString)
    }
}
