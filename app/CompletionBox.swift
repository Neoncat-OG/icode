//
//  CompletionBox.swift
//  iCode
//
//  Created by morinoyu8 on 07/21/23.
//

import Foundation
import UIKit

class CompletionBox: UIScrollView {
    
    private let buttons: [ComplationButton]
    
    static let complationMaxHeight: Double = 120
    static let completionCellHeight: Double = 40
    
    init(frame: CGRect, completionItem data: [CompletionItem]) {
        
        // Generate completion buttons.
        var buttons: [ComplationButton] = []
        for (i, completion) in data.enumerated() {
            let button = ComplationButton(frame: CGRect(x: 0, y: CompletionBox.completionCellHeight * Double(i), width: frame.width, height: CompletionBox.completionCellHeight), main: completion.insertText, sub: completion.detail ?? "")
            buttons.append(button)
        }
        self.buttons = buttons
        
        super.init(frame: frame)

        self.contentSize = CGSize(width: frame.width, height: Double(data.count) * CompletionBox.completionCellHeight)
        for button in self.buttons {
            self.addSubview(button)
        }
        
        // Completion box design settings.
        // TODO: No magic number.
        self.layer.cornerRadius = 6
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor(red: 27.0 / 255, green: 179.0 / 255, blue: 82.0 / 255, alpha: 0.95).cgColor
        self.backgroundColor = UIColor(white: 0.92, alpha: 1)
    }
    
    required init?(coder: NSCoder) {
        self.buttons = []
        super.init(coder: coder)
    }
    
    //
    func addButtonTarget(_ target: Any?, action: Selector, for event: UIControl.Event) {
        for button in buttons {
            button.addTarget(target, action: action, for: event)
        }
    }
}
