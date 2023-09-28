//
//  LSMethod.swift
//  iCode
//
//  Created by morinoyu8 on 07/11/23.
//

enum LSRequestMethod: String {
    case initialize = "initialize"
    case textDocumentCompletion = "textDocument/completion"
}

enum LSNotificationMethod: String {
    case initialized = "initialized"
    case textDocumentDidOpen = "textDocument/didOpen"
    case textDocumentDidChange = "textDocument/didChange"
}
