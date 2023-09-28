//
//  Initialize.swift
//  iCode
//
//  Created by morinoyu8 on 09/25/23.
//
// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#initialize
//

import Foundation


struct InitializeParams: Codable {
    var processId: Int
    var rootUri: String
    var capabilities: [String]
}


extension LSClient {
    
    // Create params and send initialize request.
    func initialize() {
        let uri = URL(fileURLWithPath: "/").absoluteString
        let params = InitializeParams(processId: 1, rootUri: uri, capabilities: [])
        sendRequest(method: .initialize, params: params)
    }
    
    // Recieve initialize response.
    static func recieveInitialize(responseMessage message: String) {
        CodeViewController.getInstance()?.currentLSClient?.initialized()
    }
}
