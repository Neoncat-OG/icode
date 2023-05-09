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
            create_directory("/root/hellodir")
        }))
        addActions.append(UIAction(title: "New File", image: UIImage(systemName: "doc.badge.plus"), handler: { _ in
            create_file("/root/hello")
        }))

        addItemButton.menu = UIMenu(title: "", options: .displayInline, children: addActions)
        self.navigationItem.rightBarButtonItem = addItemButton
    }
    
    @objc func createFile(_ sender: UIBarButtonItem) {
        let x = create_file("/root/hello")
        let y = create_directory("/root/hellodir")
        print("create :", x, y)
    }
}
