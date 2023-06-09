//
//  UIView+parentViewController.swift
//  iCode
//
//  Created by morinoyu8 on 06/09/23.
//

import UIKit

extension UIView {
    func parentViewController() -> UIViewController? {
        var parent: UIResponder? = self
        while let next = parent?.next {
            if let viewController = next as? UIViewController {
                return viewController
            }
            parent = next
        }
        return nil
    }
}
