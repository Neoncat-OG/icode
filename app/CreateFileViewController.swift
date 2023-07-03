//
//  CreateFileViewController.swift
//  iCode
//
//  Created by morinoyu8 on 05/10/23.
//

import UIKit

class CreateFileViewController: UIViewController {
    
    @IBOutlet weak var inputField: UITextField!
    var isFile: Bool = true
    var path: String = ""
    var prevVC: FileViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let createButton: UIBarButtonItem
        if (self.isFile) {
            createButton = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(createFile(_:)))
            self.navigationItem.title = "New File"
        } else {
            createButton = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(createFolder(_:)))
            self.navigationItem.title = "New Folder"
        }
        let cancelButton: UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelCreateItem(_:)))
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = createButton
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        self.inputField.placeholder = "Name"
        self.inputField.borderStyle = .none
        self.inputField.layer.cornerRadius = 12
        self.inputField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        self.inputField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        self.inputField.leftViewMode = .always
        self.inputField.rightViewMode = .always
        self.inputField.becomeFirstResponder()
        self.inputField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func setValue(prevVC: FileViewController, isFile: Bool, path: String) {
        self.prevVC = prevVC
        self.isFile = isFile
        self.path = path
    }
    
    @objc func setIsFile(isFile: Bool) {
        self.isFile = isFile
    }
    
    @objc func setPath(path: String) {
        self.path = path
    }

    @objc func cancelCreateItem(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func createFile(_ sender: UIBarButtonItem) {
        if let newFileName = inputField.text {
            if (newFileName.isEmpty) {
                return;
            }
            let fileManager = FileManager.default
            let result = fileManager.createFile(atPath: self.path + "/" + newFileName, contents: nil, attributes: nil)
        }
        removeSheet()
    }
    
    @objc func createFolder(_ sender: UIBarButtonItem) {
        if let newFolderName = inputField.text {
            if (newFolderName.isEmpty) {
                return;
            }
            let fileManager = FileManager.default
            do {
                try fileManager.createDirectory(atPath: self.path + "/" + newFolderName, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Fail creating folder")
            }
        }
        removeSheet()
    }
    
    func removeSheet() {
        if let vc = prevVC {
            vc.setContents()
            vc.loadView()
            vc.viewDidLoad()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = self.inputField.text {
            if (text.isEmpty) {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            } else {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }
}
