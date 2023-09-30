//
//  CompletionButton.swift
//  iCode
//
//  Created by morinoyu8 on 07/21/23.
//

import UIKit

class ComplationButton: UIButton {
    
    let label: String
    
    init(frame: CGRect, main: String, sub: String) {
        self.label = main
        super.init(frame: frame)
        let mainLabel = UILabel(frame: CGRect(x: 20, y: 0, width: frame.width - 70, height: frame.height))
        let mainAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor.black,
            .font : UIFont(name: "Menlo-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)
        ]
        mainLabel.attributedText = NSAttributedString(string: main, attributes: mainAttributes)
        self.addSubview(mainLabel)
        
        let subStyle = NSMutableParagraphStyle()
        subStyle.alignment = .right
        let subLabel = UILabel(frame: CGRect(x: frame.width - 60, y: 0, width: 45, height: frame.height))
        let subAttributes: [NSAttributedString.Key : Any] = [
            .paragraphStyle : subStyle,
            .foregroundColor : UIColor(white: 0.7, alpha: 1),
            .font : UIFont(name: "Menlo-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)
        ]
        subLabel.attributedText = NSAttributedString(string: sub, attributes: subAttributes)
        self.addSubview(subLabel)
    }
    
    required init?(coder: NSCoder) {
        self.label = ""
        super.init(coder: coder)
    }
}
