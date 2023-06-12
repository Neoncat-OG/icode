//
//  CodeViewController.swift
//  iCode
//
//  Created by morinoyu8 on 06/12/23.
//

import UIKit
import Highlightr

class CodeViewController: UIViewController {
    
    @IBOutlet weak var emptyView: UIView!
    
    override func viewDidAppear(_ animated: Bool) {
        addCodeEditView()
    }
    
    
    func addCodeEditView() {
        let textStorage = CodeAttributedString()
        textStorage.language = "Cpp"
        textStorage.highlightr.setTheme(to: "vs")
        textStorage.highlightr.theme.codeFont = UIFont(name: "Menlo-Regular", size: 13)
        
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(size: view.bounds.size)
        layoutManager.addTextContainer(textContainer)

        let textView = UITextView(frame: emptyView.frame, textContainer: textContainer)
        textView.font = UIFont(name: "Menlo-Regular", size: 13)
        textView.autocorrectionType = .no
        self.view.addSubview(textView)
    }
}
