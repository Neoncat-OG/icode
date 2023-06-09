//
//  KeyboardBar.swift
//  iCode
//
//  Created by morinoyu8 on 06/09/23.
//

import Foundation
import UIKit


class KeyboardBar: UIInputView {
    
    @IBOutlet weak var tabKey: UIButton!
    
    @objc public func initBar() {
        print("Hello, KeyboardBar")
        self.tabKey.setTitle(nil, for: UIControl.State.normal)
        self.tabKey.setImage(UIImage(systemName: "arrow.right.to.line.alt"), for: UIControl.State.normal)
        resize()
    }
    
    @objc public func resize() {
        let bar = self.bounds.size
        
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            // phone
            self.tabKey.widthAnchor.constraint(equalToConstant: 32).isActive = true
            
        } else if (bar.width >= 450) {
            // wide ipad
            self.tabKey.widthAnchor.constraint(equalToConstant: 43).isActive = true
        } else {
            // narrow ipad (slide over)
            self.tabKey.widthAnchor.constraint(equalToConstant: 36).isActive = true
        }
    }
}
