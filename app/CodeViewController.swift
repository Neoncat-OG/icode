//
//  CodeViewController.swift
//  iCode
//
//  Created by morinoyu8 on 06/12/23.
//

import UIKit
import Highlightr

class CodeViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var emptyView: UIView!
    
    func openFile(filePath: String) {
        var buf = [CChar](repeating: 0, count: 1000000000)
        read_file(filePath, &buf, 1000000000)
        if let text = String(cString: buf, encoding: .utf8) {
            if text == "ELF" {
                return;
            }
            addCodeEditView(text: text)
        }
    }
    
    func addCodeEditView(text: String) {
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
        textView.text = text
        textView.delegate = self
        self.view.addSubview(textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text {
            print(text)
        }
    }
}
