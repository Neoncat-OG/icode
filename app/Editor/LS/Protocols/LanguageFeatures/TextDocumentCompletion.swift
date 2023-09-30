//
//  TextDocumentCompletion.swift
//  iCode
//
//  Created by morinoyu8 on 09/25/23.
//
// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_completion
//

import Foundation


struct CompletionParams: Codable {
    var textDocument: TextDocumentIdentifier
    var position: Position
}

struct TextDocumentCompletionResponseMessage: Codable {
    var jsonrpc: String
    var id: Int
    var result: CompletionList
}

struct CompletionList: Codable {
    var isIncomplete: Bool;
    var items: [CompletionItem];
}

struct CompletionItem: Codable {
    var insertText: String
    var detail: String?
}


extension LSClient {
    
    // Create params and send textDocument/completion request.
    func textDocumentCompletion(path: String, line: Int, character: Int) {
        let uri = URL(fileURLWithPath: path).absoluteString
        let textDocument = TextDocumentIdentifier(uri: uri)
        let position = Position(line: line, character: character)
        let params = CompletionParams(textDocument: textDocument, position: position)
        sendRequest(method: .textDocumentCompletion, params: params)
    }
    
    // Recieve textDocument/completion response.
    static func recieveTextDocumentCompletion(responceMessage message: String) {
        do {
            guard let data = message.data(using: .utf8) else {
                print("Converting textDocument/completion response message to data error.")
                return
            }
            let completion = try JSONDecoder().decode(TextDocumentCompletionResponseMessage.self, from: data)
            let complationItems: [CompletionItem] = completion.result.items
            
            // Processing related to screen rendering should be in the main thread
            DispatchQueue.main.async {
                CodeViewController.getInstance()?.showCompletion(data: complationItems)
            }
        } catch {
            print("Decodeing textDocument/completion response data error: \(error).")
        }
    }
}
