//
//  MainTabBarController.swift
//  iCode
//
//  Created by morinoyu8 on 05/06/23.
//

import UIKit

@objc
public class MainTabBarController: UITabBarController {

    @objc public func getTabBarHeight() -> CGFloat {
        return self.tabBar.frame.size.height;
    }

}
