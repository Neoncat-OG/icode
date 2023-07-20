//
//  CodeTextView.swift
//  iCode
//
//  Created by morinoyu8 on 06/14/23.
//

import UIKit

class CodeTextView: UITextView {
    
    var filePath: String = ""
    let regex: NSRegularExpression = try! NSRegularExpression(pattern: "[\n]", options: [])
    var controller: CodeViewController?
    var codeLineView: CodeNumTextView?
    
    let cStyleAutoPairs = ["(": ")", "[": "]", "{": "}", "\"": "\"", "'": "'", "`": "`"]
    
    init(frame: CGRect, textContainer: NSTextContainer?, numView: CodeNumTextView, filePath: String, parent: CodeViewController) {
        super.init(frame: frame, textContainer: textContainer)
        self.font = UIFont(name: "Menlo-Regular", size: 13)
        self.autocorrectionType = .no
        self.isScrollEnabled = false
        self.filePath = filePath
        self.controller = parent
        self.codeLineView = numView
        self.layoutManager.usesFontLeading = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setText() -> Int {
        guard let text = try? String(contentsOfFile: self.filePath) else {
            return 1
        }
        self.text = text
        setLineNum()
        sizeFit()
        return 0
    }
    
    func textViewDidChange() {
        if let text = self.text {
            sizeFit()
            do {
                try text.write(toFile: self.filePath, atomically: true, encoding: .utf8)
            } catch {
                print("Fail write file")
            }
        }
    }
    
    private func getLineNumber(text: String) -> Int {
        let results = regex.matches(in: text, options: [], range: NSRange(0..<text.count))
        return results.count
    }
    
    func setLineNum() {
        codeLineView?.setLineNum(lineNum: getLineNumber(text: self.text))
    }
    
    func addLineNum(addText: String) {
        codeLineView?.addLineNum(add: getLineNumber(text: addText))
    }
    
    func setConstraint(parent: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        let leading = self.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 0)
        let trailing = self.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: 0)
        let top = self.topAnchor.constraint(equalTo:  parent.topAnchor, constant: 0)
        let bottom = self.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([leading, trailing, top, bottom])
        sizeFit()
    }
    
    func sizeFit() {
        let newSize = self.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        controller?.sizeFit(newSize: newSize, digit: getDigit())
        codeLineView?.setWidth(digit: getDigit())
    }
    
    func getDigit() -> Int {
        return String(codeLineView?.lineNum ?? 10000).count
    }
    
    override func insertText(_ text: String) {
        if text == "\n" {
            insertNewLine()
            return
        }
        
        if text == " " {
            super.insertText(text)
            insertSpace()
            return
        }
        
        super.insertText(text)
        
        guard let second = cStyleAutoPairs[text] else { return }
        let prev = self.selectedRange
        super.insertText(second)
        self.selectedRange = prev
    }
    
    func insertNewLine() {
        let tab = getLineTabCount()
        var prefix = ""
        for _ in 0..<tab {
            prefix += "\t"
        }
        
        if let last = getSelectedOrLast() {
            if last == "{" || last == "(" {
                super.insertText("\n\t" + prefix)
                let prev = self.selectedRange
                super.insertText("\n" + prefix)
                self.selectedRange = prev
                codeLineView?.addLineNum(add: 2)
                return
            }
        }
        super.insertText("\n" + prefix)
        codeLineView?.incrementLineNum()
    }
    
    func insertSpace() {
    }
    
    override func deleteBackward() {
        if let last = getSelectedOrLast() {
            if last == "\n" {
                codeLineView?.decrementLineNum()
            }
        }
        super.deleteBackward()
    }
}
