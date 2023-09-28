//
//  BasicJSONStructures.swift
//  iCode
//
//  Created by morinoyu8 on 09/25/23.
//

import Foundation

typealias DocumentUri = String

// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#position
struct Position: Codable {
    var line: Int
    var character: Int
}

// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#range
struct Range: Codable {
    var start: Position
    var end: Position
}

// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocumentItem
struct TextDocumentItem: Codable {
    var uri: DocumentUri
    var languageId: String
    var version: Int
    var text: String
}

// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocumentIdentifier
struct TextDocumentIdentifier: Codable {
    var uri: String
}

// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#versionedTextDocumentIdentifier
struct VersionedTextDocumentIdentifier: Codable {
    var uri: String
    var version: Int
}
