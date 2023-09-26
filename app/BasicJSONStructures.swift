//
//  BasicJSONStructures.swift
//  iCode
//
//  Created by morinoyu8 on 09/25/23.
//

import Foundation

typealias DocumentUri = String

struct Position: Codable {
    var line: Int
    var character: Int
}

struct Range: Codable {
    var start: Position
    var end: Position
}

struct TextDocumentItem: Codable {
    var uri: DocumentUri
    var languageId: String
    var version: Int
    var text: String
}

struct TextDocumentIdentifier: Codable {
    var uri: String
}

struct VersionedTextDocumentIdentifier: Codable {
    var uri: String
    var version: Int
}
