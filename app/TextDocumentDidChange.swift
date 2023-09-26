//
//  TextDocumentDidChange.swift
//  iCode
//
//  Created by morinoyu8 on 09/25/23.
//

import Foundation
import Runestone


struct DidChangeTextDocumentParams: Codable {
    var textDocument: VersionedTextDocumentIdentifier
    var contentChanges: [TextDocumentContentChangeEvent]
}

struct TextDocumentContentChangeEvent: Codable {
    var range: Range?
    var text: String
}


extension LSClient {
    
    // Create params and send textDocument/didChange notification.
    // If only a text is provided, it is considered to be the full content of the document.
    func textDocumentDidChange(path: String, text: String) {
        let uri = URL(fileURLWithPath: path).absoluteString
        let textDocument = VersionedTextDocumentIdentifier(uri: uri, version: 1)
        let contentChanges = TextDocumentContentChangeEvent(text: text)
        let params = DidChangeTextDocumentParams(textDocument: textDocument, contentChanges: [contentChanges])
        sendNotification(method: .textDocumentDidChange, params: params)
    }
    
    // If TextLocation is also provided, this range considered changed to text.
    func textDocumentDidChange(path: String, text: String, startLocation start: TextLocation, endLocation end: TextLocation) {
        let uri = URL(fileURLWithPath: path).absoluteString
        let textDocument = VersionedTextDocumentIdentifier(uri: uri, version: 1)
        let startPosition = Position(line: start.lineNumber, character: start.column)
        let endPosition = Position(line: end.lineNumber, character: end.column)
        let range = Range(start: startPosition, end: endPosition)
        let contentChanges = TextDocumentContentChangeEvent(range: range, text: text)
        let params = DidChangeTextDocumentParams(textDocument: textDocument, contentChanges: [contentChanges])
        sendNotification(method: .textDocumentDidChange, params: params)
    }
}
