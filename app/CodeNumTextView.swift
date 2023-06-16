//
//  CodeNumTextView.swift
//  iCode
//
// Created by morinoyu8 on 06/15/23.
//

import UIKit

class CodeNumTextView: UITextView {

    var width: NSLayoutConstraint?
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.font = UIFont(name: "Menlo-Regular", size: 13)
        self.isEditable = false
        self.isSelectable = false
        self.isScrollEnabled = false
        self.textAlignment = NSTextAlignment.right
        self.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        // self.
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
        var text = ""
        for i in 1..<lineNum + 2 {
            text += String(i) + "\n"
        }
        self.text = text
    }
}
