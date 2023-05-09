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

        let button = UIButton()
        button.frame = CGRect(x: 0, y:0, width: 100 , height: 100)
        button.backgroundColor = .orange
        button.center = self.view.center
        button.addTarget(self, action: #selector(createFile), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    @objc  func createFile() {
        var x = create_file("/root/hello")
        print("create :", x)
    }
}
