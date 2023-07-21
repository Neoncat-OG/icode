//
//  CompletionBox.swift
//  iCode
//
//  Created by morinoyu8 on 07/21/23.
//

import Foundation
import UIKit

class CompletionBox: UIScrollView {
    
    init(frame: CGRect, buttons: [UIButton]) {
        super.init(frame: frame)
        self.contentSize = CGSize(width: frame.width, height: Double(buttons.count * 40))
        for button in buttons {
            self.addSubview(button)
        }
        self.layer.cornerRadius = 6
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor(red: 27.0 / 255, green: 179.0 / 255, blue: 82.0 / 255, alpha: 0.95).cgColor
        self.backgroundColor = UIColor(white: 0.92, alpha: 1)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
