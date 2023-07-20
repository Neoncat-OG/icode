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
}
