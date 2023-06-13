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
    var filenames = [String](repeating: "", count: 100)
    var tabCount = 0
    
    func openFile(filePath: String) {
        var buf = [CChar](repeating: 0, count: 1000000000)
        read_file(filePath, &buf, 1000000000)
//        if (buf[0] == 127) {
//            let alert = UIAlertController(
//                        title: "File cannot be opened",
//                        message: "This file is a binary or uses unsupported text encoding.",
//                        preferredStyle: UIAlertController.Style.alert)
//            alert.addAction(
//                        UIAlertAction(
//                            title: "OK",
//                            style: UIAlertAction.Style.default)
//                    )
//            self.present(alert, animated: true, completion: nil)
//            return;
//        }
        if let text = String(cString: buf, encoding: .utf8) {
            addCodeEditView(filePath: filePath, text: text)
        }
    }
    
    func addCodeEditView(filePath: String, text: String) {
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
        textView.tag = tabCount
        filenames[tabCount] = filePath
        tabCount += 1
        textView.delegate = self
        self.view.addSubview(textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text {
            var index = textView.tag
            write_file(filenames[index], text, text.count)
        }
    }
}
