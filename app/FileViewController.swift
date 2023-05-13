//
//  FileViewController.swift
//  iCode
//
//  Created by morinoyu8 on 05/09/23.
//

import UIKit

class FileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let addItemButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        
        var addActions = [UIMenuElement]()
        addActions.append(UIAction(title: "New Folder", image: UIImage(systemName: "folder.badge.plus") ,handler: { _ in
            self.setNextView(isFile: false, path: "/root/")
        }))
        
        addActions.append(UIAction(title: "New File", image: UIImage(systemName: "doc.badge.plus"), handler: { _ in
            self.setNextView(isFile: true, path: "/root/")
        }))

        addItemButton.menu = UIMenu(title: "", options: .displayInline, children: addActions)
        self.navigationItem.rightBarButtonItem = addItemButton
    }
    
    func setNextView (isFile: Bool, path: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextNavigationController = storyboard.instantiateViewController(withIdentifier: "create-file") as! UINavigationController
        let nextView = nextNavigationController.topViewController as! CreateFileViewController
        nextView.setValue(isFile: isFile, path: path)
        nextNavigationController.modalPresentationStyle = .formSheet
        self.present(nextNavigationController, animated: true, completion: nil)
    }
}
