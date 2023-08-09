//
//  LSStruct.swift
//  iCode
//
//  Created by morinoyu8 on 07/11/23.
//

struct InitializeParams: Codable {
    var processId: Int
    var rootUri: String
    var capabilities: [String]
}

struct Initialize: Codable {
    var jsonrpc: String = "2.0"
    var id: Int
    var method: String
    var params: InitializeParams
}

struct InitializedParams: Codable {}

struct Initialized: Codable {
    var jsonrpc: String = "2.0"
    var method: String
    var params: InitializedParams
}

struct TextDocumentItem: Codable {
    var uri: String
    var languageId: String
    var version: Int
    var text: String
}

struct DidOpenTextDocumentParams: Codable {
    var textDocument: TextDocumentItem
}

struct DidOpen: Codable {
    var jsonrpc: String = "2.0"
    var method: String
    var params: DidOpenTextDocumentParams
}

struct TextDocumentIdentifier: Codable {
    var uri: String
}

struct VersionedTextDocumentIdentifier: Codable {
    var uri: String
    var version: Int
}

struct TextDocumentContentChangeEvent: Codable {
    var text: String
}

struct DidChangeTextDocumentParams: Codable {
    var textDocument: VersionedTextDocumentIdentifier
    var contentChanges: [TextDocumentContentChangeEvent]
}

struct DidChange: Codable {
    var jsonrpc: String = "2.0"
    var method: String
    var params: DidChangeTextDocumentParams
}


struct DidCloseTextDocumentParams: Codable {
    var textDocument: TextDocumentIdentifier
}

struct DidClose: Codable {
    var jsonrpc: String = "2.0"
    var method: String
    var params: DidCloseTextDocumentParams
}


struct Position: Codable {
    var line: Int
    var character: Int
}

struct TextDocumentPositionParams: Codable {
    var textDocument: TextDocumentIdentifier
    var position: Position
}

struct CompletionParams: Codable {
    var textDocument: TextDocumentIdentifier
    var position: Position
}

struct Completion: Codable {
    var jsonrpc: String = "2.0"
    var id: Int
    var method: String
    var params: CompletionParams
}




//
// Recieve
//

struct Data_Recieve: Codable {
    var jsonrpc: String
    var id: Int?
}

struct Completion_Recieve: Codable {
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
