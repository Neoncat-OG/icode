//
//  FileViewController.swift
//  iCode
//
//  Created by morinoyu8 on 05/09/23.
//

import UIKit

struct FileContent {
    var name: String;
    var kind: Int;
}

class FileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var currentPath = "/root"
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
        let label = cell.contentView.viewWithTag(1) as! UILabel
        if let con = contents {
            label.text = con[indexPath.row].name
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
                self.contents! += [FileContent(name: name, kind: 0)]
            }
        }
        self.contentsSize = Int(size)
        print(size)
    }
}
