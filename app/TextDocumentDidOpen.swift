//
//  TextDocumentDidOpen.swift
//  iCode
//
//  Created by morinoyu8 on 09/25/23.
//

import Foundation


struct DidOpenTextDocumentParams: Codable {
    var textDocument: TextDocumentItem
}


extension LSClient {
    
    // Create params and send textDocument/didOpen notification.
    func textDocumentDidOpen(path: String, text: String) {
        let uri = URL(fileURLWithPath: path).absoluteString
        let textDocumentItem = TextDocumentItem(uri: uri, languageId: "cpp", version: 0, text: text)
        let params = DidOpenTextDocumentParams(textDocument: textDocumentItem)
        sendNotification(method: .textDocumentDidOpen, params: params)
    }
}
