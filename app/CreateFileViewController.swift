//
//  CreateFileViewController.swift
//  iCode
//
//  Created by morinoyu8 on 05/10/23.
//

import UIKit

class CreateFileViewController: UIViewController {
    
    var path: String = "/";
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc func setIsFile(isFile: Bool) {
        let createButton: UIBarButtonItem
        if (isFile) {
            createButton = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(createFile(_:)))
            self.navigationItem.title = "New File"
        } else {
            createButton = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(createFolder(_:)))
            self.navigationItem.title = "New Folder"
        }
        let cancelButton: UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelCreateItem(_:)))
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = createButton
    }
    
    @objc func setPath(path: String) {
        self.path = path
    }

    @objc func cancelCreateItem(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func createFile(_ sender: UIBarButtonItem) {
        create_file("/root/hello")
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func createFolder(_ sender: UIBarButtonItem) {
        create_directory("/root/hellodir")
        self.dismiss(animated: true, completion: nil)
    }
}
