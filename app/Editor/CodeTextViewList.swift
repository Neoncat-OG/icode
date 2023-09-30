//
//  CodeTextViewList.swift
//  iCode
//
//  Created by morinoyu8 on 09/24/23.
//

import UIKit

class CodeTextViewList {
    private var filePath2CodeTextView: [String: CodeTextView]
    
    init() {
        self.filePath2CodeTextView = [:]
    }
    
    func append(filePath: String, codeTextView: CodeTextView) {
        filePath2CodeTextView[filePath] = codeTextView
    }
}
