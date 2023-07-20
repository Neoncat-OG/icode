//
//  CodeNumTextView.swift
//  iCode
//
// Created by morinoyu8 on 06/15/23.
//

import UIKit

class CodeNumTextView: UITextView {

    var width: NSLayoutConstraint?
    let paragraphStyle = NSMutableParagraphStyle()
    let numFont = UIFont(name: "Menlo-Regular", size: 13)!
    let numColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
    
    var numText: String = ""
    var lineNum: Int = 0
    
    init(frame: CGRect, lineHeight: CGFloat) {
        super.init(frame: frame, textContainer: nil)
        self.isEditable = false
        self.isSelectable = false
        self.isScrollEnabled = false
        self.textAlignment = NSTextAlignment.right
        paragraphStyle.lineSpacing = lineHeight
        paragraphStyle.alignment = .right
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setConstraint(parent: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        let leading = self.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 0)
        let width = self.widthAnchor.constraint(equalToConstant: 28)
        let top = self.topAnchor.constraint(equalTo:  parent.topAnchor, constant: 0)
        let bottom = self.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: 0)
        self.width = width
        NSLayoutConstraint.activate([leading, width, top, bottom])
    }
    
    func setLineNum(lineNum: Int) {
        numText = ""
        for i in 1...lineNum + 1 {
            numText += String(i) + "\n"
        }
        self.lineNum = lineNum + 1
        setAttributeString()
    }
    
    func incrementLineNum() {
        lineNum += 1
        numText += String(lineNum) + "\n"
        setAttributeString()
    }
    
    func addLineNum(add: Int) {
        if add == 0 {
            return
        }
        for i in lineNum + 1...lineNum + add {
            numText += String(i) + "\n"
        }
        lineNum += add
        setAttributeString()
    }
    
    func decrementLineNum() {
        if lineNum == 1 {
            return
        }
        let count = String(lineNum).count + 1
        lineNum -= 1
        numText = String(self.numText.dropLast(count))
        setAttributeString()
    }
    
    private func setAttributeString() {
        let attrString = NSMutableAttributedString(string: self.numText, attributes: [NSAttributedString.Key.font: self.numFont,
             NSAttributedString.Key.foregroundColor: self.numColor,
             NSAttributedString.Key.paragraphStyle: self.paragraphStyle])
        self.attributedText = attrString
    }
    
    func setWidth(digit :Int) {
        if let width = self.width {
            switch (digit) {
            case 1, 2:
                width.constant = 28
                break
            case 3:
                width.constant = 35
                break
            case 4:
                width.constant = 42
            default:
                width.constant = 49
            }
        }
    }
}
