//
//  FileViewController.swift
//  iCode
//
//  Created by morinoyu8 on 05/09/23.
//

import UIKit
import Foundation

struct FileContent {
    var name: String;
    var kind: Kind;
}

enum Kind: Int {
    case file = 0
    case dir = 1
    case other = 2
}

class FileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var allPath = "/"
    var currentPath = "/"
    var contents: [FileContent] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.currentPath == "/") {
            self.allPath = String(cString: get_all_path(currentPath.cString(using: .utf8)))
            setContents()
        }

        let addItemButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        
        var addActions = [UIMenuElement]()
        addActions.append(UIAction(title: "New Folder", image: UIImage(systemName: "folder.badge.plus") ,handler: { _ in
            self.setCreateView(isFile: false)
        }))
        
        addActions.append(UIAction(title: "New File", image: UIImage(systemName: "doc.badge.plus"), handler: { _ in
            self.setCreateView(isFile: true)
        }))

        addItemButton.menu = UIMenu(title: "", options: .displayInline, children: addActions)
        self.navigationItem.rightBarButtonItem = addItemButton
        let pathElement:[String] = currentPath.components(separatedBy: "/")
        if pathElement.last == "" {
            self.navigationItem.title = "/"
        } else {
            self.navigationItem.title = pathElement.last
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let content = contents[indexPath.row]
        
        let button = cell.contentView.viewWithTag(1) as! UIButton
        button.setTitle(content.name, for: .normal)
        
        let label = cell.contentView.viewWithTag(2) as! UILabel
        label.text = content.name
        
        switch content.kind {
        case Kind.dir:
            cell.backgroundColor = .orange
            button.addTarget(self, action: #selector(changeDirectory(_ :)), for: .touchUpInside)
            break
        case Kind.file:
            cell.backgroundColor = .cyan
            button.addTarget(self, action: #selector(passCodeEditor(_ :)), for: .touchUpInside)
            break
        default:
            cell.backgroundColor = .gray
            break
        }
        return cell
    }
    
    
    func setCreateView (isFile: Bool) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextNavigationController = storyboard.instantiateViewController(withIdentifier: "create-file") as! UINavigationController
        let nextView = nextNavigationController.topViewController as! CreateFileViewController
        nextView.setValue(prevVC: self, isFile: isFile, path: self.currentPath)
        nextNavigationController.modalPresentationStyle = .formSheet
        self.present(nextNavigationController, animated: true, completion: nil)
    }
    
    func setValue(allPath: String, currentPath: String) {
        self.allPath = allPath
        self.currentPath = currentPath
        setContents()
    }
    
    func setContents() {
        let fileManager = FileManager.default
        var files: [String] = []
        do {
            files = try fileManager.contentsOfDirectory(atPath: self.allPath)
        } catch {
            print(files)
        }
        
        self.contents = []
        var isDir: ObjCBool = false
        for file in files {
            if (file.prefix(1) == ".") {
                continue
            }
            if fileManager.fileExists(atPath: self.allPath + "/" + file, isDirectory: &isDir) {
                if isDir.boolValue {
                    contents.append(FileContent(name: file, kind: Kind.dir))
                } else {
                    contents.append(FileContent(name: file, kind: Kind.file))
                }
            }
        }
        
    }
    
    
    @objc func changeDirectory(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "file-view") as! FileViewController
        nextViewController.setValue(allPath: allPath + "/" + (sender.titleLabel?.text ?? ""), currentPath: currentPath + "/" + (sender.titleLabel?.text ?? ""))
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @objc func passCodeEditor(_ sender: UIButton) {
        let root = UIApplication.shared.windows.first?.rootViewController as! UITabBarController
        let codeViewController = root.children[1] as! CodeViewController
        root.selectedIndex = 1
        root.selectedViewController = codeViewController;
        codeViewController.addCodeEditView(filePath: allPath + "/" + (sender.titleLabel?.text ?? ""))
    }
}
