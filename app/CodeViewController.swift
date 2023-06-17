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
    
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var innerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var codeInnerView: UIView!
    @IBOutlet weak var codeInnerWidth: NSLayoutConstraint!
    
    func addCodeEditView(filePath: String) {
        let textStorage = CodeAttributedString(lineHeight: 2.4)
        textStorage.language = getLanguage(filePath: filePath)
        textStorage.highlightr.setTheme(to: "vs")
        textStorage.highlightr.theme.codeFont = UIFont(name: "Menlo-Regular", size: 13)
        
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(size: view.bounds.size)
        textContainer.lineFragmentPadding = 14
        layoutManager.addTextContainer(textContainer)
        
        let numView = CodeNumTextView(frame: self.innerView.frame, textContainer: nil, lineHeight: 2.4)
        let codeView = CodeTextView(frame: self.innerView.frame, textContainer: textContainer, numView: numView, filePath: filePath, viewHeight: innerHeight, viewWidth: codeInnerWidth)
        
        if (codeView.setText() != 0) {
            showAlert()
            return;
        }
        
        filenames[tabCount] = filePath
        tabCount += 1
        
        codeView.delegate = self
        
        codeInnerView.addSubview(codeView)
        innerView.addSubview(numView)
        codeView.setConstraint(parent: codeInnerView)
        numView.setConstraint(parent: innerView)
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
        }
    }
}
