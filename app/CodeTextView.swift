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
    var viewWidth: NSLayoutConstraint?
    var leading: NSLayoutConstraint?
    var lineNum: Int = 0
    var digit: Int = 1
    var codeLineView: CodeNumTextView?
    
    init(frame: CGRect, textContainer: NSTextContainer?, numView: CodeNumTextView, filePath: String, viewHeight: NSLayoutConstraint, viewWidth: NSLayoutConstraint, leading: NSLayoutConstraint) {
        super.init(frame: frame, textContainer: textContainer)
        self.font = UIFont(name: "Menlo-Regular", size: 13)
        self.autocorrectionType = .no
        self.isScrollEnabled = false
        self.filePath = filePath
        self.viewHeight = viewHeight
        self.viewWidth = viewWidth
        self.leading = leading
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
        
        let newSize = self.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        if let height = viewHeight {
            height.constant = newSize.height
        }
        if let width = viewWidth {
            width.constant = newSize.width
        }
        
        if let numView = self.codeLineView {
            numView.setLineNum(lineNum: getLineNumber())
        }
        return 0
    }
    
    func textViewDidChange() {
        if let text = self.text {
            let newSize = self.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
            if let height = viewHeight {
                height.constant = newSize.height
            }
            if let width = viewWidth {
                width.constant = newSize.width
            }
            
            let newLineNum = getLineNumber()
            if (self.lineNum != newLineNum) {
                self.lineNum = newLineNum
                if let numView = self.codeLineView {
                    let digit_s = String(self.lineNum)
                    if digit_s.count != self.digit {
                        self.digit = digit_s.count
                        numView.setWidth(digit: self.digit)
                        setLeading(digit: self.digit)
                    }
                    numView.setLineNum(lineNum: newLineNum)
                }
            }

            do {
                try text.write(toFile: self.filePath, atomically: true, encoding: .utf8)
            } catch {
                print("Fail write file")
            }
        }
    }
    
    func getLineNumber() -> Int {
        let results = regex.matches(in: text, options: [], range: NSRange(0..<text.count))
        return results.count
    }
    
    func setConstraint(parent: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        let leading = self.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 0)
        let trailing = self.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: 0)
        let top = self.topAnchor.constraint(equalTo:  parent.topAnchor, constant: 0)
        let bottom = self.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([leading, trailing, top, bottom])
    }
    
    func setLeading(digit :Int) {
        if let leading = self.leading {
            switch (digit) {
            case 1, 2:
                leading.constant = 30
                break
            case 3:
                leading.constant = 37
                break
            case 4:
                leading.constant = 44
                break
            default:
                leading.constant = 51
                break
            }
        }
    }
}
