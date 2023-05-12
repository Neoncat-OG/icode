//
//  CreateFileViewController.swift
//  iCode
//
//  Created by morinoyu8 on 05/10/23.
//

import UIKit

class CreateFileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let createButton: UIBarButtonItem = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(createFile(_:)))
        
        let cancelButton: UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelCreateFile(_:)))
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = createButton
    }
    
//    init?(coder: NSCoder, value: String) {
//        //self.value =
//        super.init(coder: coder)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    @objc func cancelCreateFile(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func createFile(_ sender: UIBarButtonItem) {
        create_file("/root/hello")
        self.dismiss(animated: true, completion: nil)
    }
}
