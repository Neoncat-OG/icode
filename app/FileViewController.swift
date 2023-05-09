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
    
        let addItemButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createFile(_:)))
        self.navigationItem.rightBarButtonItem = addItemButton
    }
    
    @objc func createFile(_ sender: UIBarButtonItem) {
        let x = create_file("/root/hello")
        let y = create_directory("/root/hellodir")
        print("create :", x, y)
    }
}
