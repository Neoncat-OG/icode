//
//  CodeViewController.swift
//  iCode
//
//  Created by morinoyu8 on 06/12/23.
//

import UIKit
import Highlightr

class CodeViewController: UIViewController, UITextViewDelegate {
    var filenames = [String](repeating: "", count: 100)
    var tabCount = 0
    var lsClients: [String:LSClient] = [:]
    
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var innerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var codeInnerView: UIView!
    @IBOutlet weak var codeInnerWidth: NSLayoutConstraint!
    
    @IBOutlet weak var innerScrollViewLeading: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let clangd = LSClient()
        lsClients["c"] = clangd
        lsClients["c"]?.initialize()
    }
    
    func addCodeEditView(filePath: String) {
        let language = getLanguage(filePath: filePath)
        let textContainer = setTextContainer(language: language, theme: "xcode")
        let numView = CodeNumTextView(frame: self.innerView.frame, lineHeight: 2.4)
        let codeView = CodeTextView(frame: self.innerView.frame, textContainer: textContainer, numView: numView, filePath: filePath, parent: self)
        
        if (codeView.setText() != 0) {
            showAlert()
            return;
        }
        
        filenames[tabCount] = filePath
        tabCount += 1
        
        codeView.delegate = self
        
        codeInnerView.addSubview(codeView)
        innerView.addSubview(numView)
        numView.setConstraint(parent: innerView)
        codeView.setConstraint(parent: codeInnerView)
        lsClients["c"]?.textDocument_didOpen(allPath: filePath, text: codeView.text)
    }
    
    func setTextContainer(language: String, theme: String) -> NSTextContainer? {
        let textStorage = CodeAttributedString(lineHeight: 2.4)
        textStorage.language = language
        textStorage.highlightr.setTheme(to: theme)
        textStorage.highlightr.theme.codeFont = UIFont(name: "Menlo-Regular", size: 13)
        
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(size: view.bounds.size)
        layoutManager.addTextContainer(textContainer)
        
        return textContainer
    }
    
    func showAlert() {
        let alert = UIAlertController(
                    title: "File cannot be opened",
                    message: "This file is a binary or uses unsupported text encoding.",
                    preferredStyle: UIAlertController.Style.alert)
        alert.addAction(
                    UIAlertAction(
                        title: "OK",
                        style: UIAlertAction.Style.default)
                )
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func getLanguage(filePath: String) -> String {
        if let ext = filePath.split(separator: ".").last {
            return String(ext)
        }
        return ""
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        if let codeTextView = textView as? CodeTextView {
            codeTextView.textViewDidChange()
            lsClients["c"]?.textDocument_didChange(allPath: filenames[tabCount - 1], text: codeTextView.text)
            guard let range = codeTextView.selectedTextRange else {return}
            let cursorPosition = codeTextView.offset(from: codeTextView.beginningOfDocument, to: range.start)
            let pre = String(codeTextView.text!.prefix(cursorPosition))
            if (pre.last == ".") {
                let arr: [String] = pre.components(separatedBy: "\n")
                lsClients["c"]?.textDocument_completion(allPath: filenames[tabCount - 1], line: arr.count - 1, character: arr.last!.count)
            }
        }
    }
    
    func sizeFit(newSize: CGSize, digit: Int) {
        codeInnerWidth.constant = newSize.width
        innerHeight.constant = newSize.height
        setLeading(digit: digit)
    }
    
    func setLeading(digit :Int) {
        switch (digit) {
        case 1, 2:
            self.innerScrollViewLeading?.constant = 30
            break
        case 3:
            self.innerScrollViewLeading?.constant = 37
            break
        case 4:
            self.innerScrollViewLeading?.constant = 44
            break
        default:
            self.innerScrollViewLeading?.constant = 51
            break
        }
    }
}


