//
//  MainTabBarController.swift
//  iCode
//
//  Created by morinoyu8 on 05/06/23.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    @IBOutlet var barView: KeyboardBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barView.initBar()
        
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return barView
        }
    }

    @objc public func getTabBarHeight() -> CGFloat {
        return self.tabBar.frame.size.height;
    }

}
