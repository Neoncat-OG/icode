//
//  KeyboardBar.swift
//  iCode
//
//  Created by morinoyu8 on 06/09/23.
//

import Foundation
import UIKit


class KeyboardBar: UIInputView {
    
    private var currentViewController: UIViewController? = nil
    
    @IBOutlet weak var tabKey: UIButton!
    @IBOutlet weak var hideButton: UIButton!
    
    @objc public func initBar() {
        print("Hello, KeyboardBar")
        self.tabKey.setTitle(nil, for: UIControl.State.normal)
        self.tabKey.setImage(UIImage(systemName: "arrow.right.to.line.alt"), for: UIControl.State.normal)
        self.hideButton.setImage(UIImage(systemName: "keyboard.chevron.compact.down"), for: UIControl.State.normal)
        resize()
    }
    
    func resize() {
        let bar = self.bounds.size
        
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            // phone
            setButtonWidthSize(width: 32)
        } else if (bar.width >= 450) {
            // wide ipad
            setButtonWidthSize(width: 43)
        } else {
            // narrow ipad (slide over)
            setButtonWidthSize(width: 36)
        }
    }
    
    func setButtonWidthSize (width: CGFloat) {
        self.tabKey.widthAnchor.constraint(equalToConstant: width).isActive = true
        self.hideButton.widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func topViewController(controller: UIViewController?) -> UIViewController? {
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
    @IBAction func pressHideButton(_ sender: Any) {
        if let parent = self.parentViewController() {
            if let top = topViewController(controller: parent) {
                top.view.endEditing(true)
            }
        }
    }
    
    @IBAction func pushTabButton(_ sender: Any) {
        guard let parent = self.parentViewController() else { return }
        guard let top = topViewController(controller: parent) else { return }
        guard let codeVC = top as? CodeViewController else { return }
        codeVC.insertTab()
    }
}
