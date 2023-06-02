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
    var kind: Int;
}

class FileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    let DT_DIR = 4
    let DT_REG = 8
    var currentPath = "/"
    var contents: [FileContent]? = nil
    var contentsSize = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let addItemButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        
        var addActions = [UIMenuElement]()
        addActions.append(UIAction(title: "New Folder", image: UIImage(systemName: "folder.badge.plus") ,handler: { _ in
            self.setCreateView(isFile: false, path: self.currentPath)
        }))
        
        addActions.append(UIAction(title: "New File", image: UIImage(systemName: "doc.badge.plus"), handler: { _ in
            self.setCreateView(isFile: true, path: self.currentPath)
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
        if contents == nil  {
            setContents()
        }
        return contentsSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if contents == nil  {
            setContents()
        }
        
        let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let con = contents {
            let content = con[indexPath.row]
            let button = cell.contentView.viewWithTag(1) as! UIButton
            button.setTitle(content.name, for: .normal)
            
            let label = cell.contentView.viewWithTag(2) as! UILabel
            label.text = content.name
            switch content.kind {
            case DT_DIR:
                cell.backgroundColor = .orange
                button.addTarget(self, action: #selector(changeDirectory(_ :)), for: .touchUpInside)
                break
            case DT_REG:
                cell.backgroundColor = .blue
                break
            default:
                cell.backgroundColor = .gray
                break
            }
        }
        return cell
    }
    
    
    func setCreateView (isFile: Bool, path: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextNavigationController = storyboard.instantiateViewController(withIdentifier: "create-file") as! UINavigationController
        let nextView = nextNavigationController.topViewController as! CreateFileViewController
        nextView.setValue(isFile: isFile, path: path)
        nextNavigationController.modalPresentationStyle = .formSheet
        self.present(nextNavigationController, animated: true, completion: nil)
    }
    
    func setValue(currentPath: String) {
        self.currentPath = currentPath
        setContents()
    }
    
    func setContents() {
        var tmp = [filecontent](repeating: filecontent(name: nil, kind: 0), count: Int(MAX_CONTENTS))
        let size = get_file_list(currentPath.cString(using: .utf8), &tmp)
        self.contents = []
        for i in 0 ..< size {
            if let name = String(cString: tmp[Int(i)].name, encoding: .utf8) {
                self.contents! += [FileContent(name: name, kind: Int(tmp[Int(i)].kind))]
            }
        }
        self.contentsSize = Int(size)
        print(size)
    }
    
    
    @objc func changeDirectory(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "file-view") as! FileViewController
        nextViewController.setValue(currentPath: currentPath + "/" + (sender.titleLabel?.text ?? ""))
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
}
