//
//  UITextViewExt.swift
//  iCode
//
//  Created by morinoyu8 on 07/13/23.
//

import UIKit

extension UITextView {
    func isTextSelected() -> Bool {
        guard let range = selectedTextRange else { return false }
        return !range.isEmpty
    }
    
    func getSelectedOrLast() -> String? {
        guard let range = selectedTextRange else { return nil }
        if range.isEmpty {
            let offset = offset(from: beginningOfDocument, to: range.start)
            if offset <= 0 {
                return nil
            }
            let index = text.index(text.startIndex, offsetBy: offset - 1)
            return String(text[index])
        }
        return text(in: range)
    }
    
    func getLast() -> String? {
        guard let range = selectedTextRange else { return nil }
        if !range.isEmpty {
            return nil
        }
        var offset = offset(from: beginningOfDocument, to: range.start) - 1
        var res: String? = nil
        while offset >= 0 {
            let index = text.index(text.startIndex, offsetBy: offset)
            if text[index] != " " {
                res = String(text[index])
                break
            }
            offset -= 1
        }
        return res
    }
    
    func getLast(num: Int) -> String? {
        guard let range = selectedTextRange else { return nil }
        if !range.isEmpty {
            return nil
        }
        let offset = offset(from: beginningOfDocument, to: range.start)
        if offset < num {
            return nil
        }
        var res = ""
        for i in 1...num {
            let index = text.index(text.startIndex, offsetBy: offset - i)
            res += String(text[index])
        }
        return res
    }
    
    func getLineTabCount() -> Int {
        guard let range = selectedTextRange else { return 0 }
        var offset = offset(from: beginningOfDocument, to: range.start) - 1
        var space = 0
        var tab = 0
        while (offset >= 0) {
            let index = text.index(text.startIndex, offsetBy: offset)

            if (text[index] == "\n") {
                break;
            }
            
            if (text[index] == " ") {
                space += 1
                if (space == 4) {
                    tab += 1
                    space = 0
                }
            } else if (text[index] == "\t") {
                tab += 1
            } else {
                space = 0
                tab = 0
            }
            offset -= 1
        }
        
        return tab
    }
}
