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
    var viewHeight: NSLayoutConstraint?
    var leading: NSLayoutConstraint?
    var lineNum: Int = 0
    var codeLineView: CodeNumTextView?
    
    init(frame: CGRect, textContainer: NSTextContainer?, numView: CodeNumTextView, filePath: String, viewHeight: NSLayoutConstraint) {
        super.init(frame: frame, textContainer: textContainer)
        self.font = UIFont(name: "Menlo-Regular", size: 13)
        self.autocorrectionType = .no
        self.isScrollEnabled = false
        self.filePath = filePath
        self.viewHeight = viewHeight
        self.codeLineView = numView
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setText() -> Int {
        var buf = [CChar](repeating: 0, count: 1000000000)
        read_file(self.filePath, &buf, 1000000000)
        if (buf[0] == 127) {
            return 1
        }
        if let text = String(cString: buf, encoding: .utf8) {
            self.text = text
            self.sizeToFit()
            if let height = viewHeight {
                height.constant = self.frame.size.height
            }
            if let numView = self.codeLineView {
                numView.setLineNum(lineNum: getLineNumber())
            }
            return 0
        }
        return 1
    }
    
    func textViewDidChange() {
        if let text = self.text {
            self.sizeToFit()
            if let height = viewHeight {
                height.constant = self.frame.size.height
            }
            let newLineNum = getLineNumber()
            if (self.lineNum != newLineNum) {
                self.lineNum = newLineNum
                if let numView = self.codeLineView {
                    numView.setLineNum(lineNum: newLineNum)
                }
            }

            write_file(filePath, text, text.count)
        }
    }
    
    func getLineNumber() -> Int {
        let results = regex.matches(in: text, options: [], range: NSRange(0..<text.count))
        return results.count
    }
    
    func setConstraint(parent: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        let leading = self.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 30)
        let trailing = self.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: 0)
        let top = self.topAnchor.constraint(equalTo:  parent.topAnchor, constant: 0)
        let bottom = self.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: 0)
        self.leading = leading
        NSLayoutConstraint.activate([leading, trailing, top, bottom])
    }
}
