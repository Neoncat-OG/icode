//
//  Initialized.swift
//  iCode
//
//  Created by morinoyu8 on 09/25/23.
//
// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#initialized
//

import Foundation


struct InitializedParams: Codable {}


extension LSClient {
    
    // Create params and send initialized notification.
    func initialized() {
        let params = InitializedParams()
        sendNotification(method: .initialized, params: params)
    }
}
