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
    var currentCodeView: CodeTextView? = nil
    
    @IBOutlet weak var scrollbarBottom: NSLayoutConstraint!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var innerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var codeInnerView: UIView!
    @IBOutlet weak var codeInnerWidth: NSLayoutConstraint!
    
    @IBOutlet weak var innerScrollViewLeading: NSLayoutConstraint!
    
    var currentCompletionBox: CompletionBox? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let clangd = LSClient(codeViewController: self)
        lsClients["c"] = clangd
        lsClients["c"]?.initialize()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func addCodeEditView(filePath: String) {
        let language = getLanguage(filePath: filePath)
        let textContainer = setTextContainer(language: language, theme: "xcode")
        let numView = CodeNumTextView(frame: self.innerView.frame, lineHeight: 2.4)
        let codeView = CodeTextView(frame: self.innerView.frame, textContainer: textContainer, numView: numView, filePath: filePath, parent: self)
        
        currentCodeView = codeView
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
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        removeCompletionBox()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let codeTextView = textView as? CodeTextView {
            if range.length > 1 {
                codeTextView.setLineNum()
                return true
            }
            if text.count > 1 {
                codeTextView.addLineNum(addText: text)
                return true
            }
        }
        return true
    }
    
    func insertTab() {
        guard let codeView = currentCodeView else { return }
        codeView.insertText("\t")
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollbarBottom.constant = keyboardSize.height - self.view.safeAreaInsets.bottom
            print(keyboardSize)
        }
    }
    
    @objc func keyboardWillHide() {
        removeCompletionBox()
        scrollbarBottom.constant = 0
    }
    
    func recieveCompletion(data: [CompletionItem]) {
        removeCompletionBox()
        
        guard let start = currentCodeView?.selectedTextRange?.start else { return }
        guard let cursorFrame = currentCodeView?.caretRect(for: start) else { return }
        
        guard let position = currentCodeView?.convert(cursorFrame, to: self.view) else { return }
        
        var buttons: [ComplationButton] = []
        for (i, completion) in data.enumerated() {
            let button = ComplationButton(frame: CGRect(x: 0, y: 40 * i, width: 300, height: 40), main: completion.insertText, sub: completion.detail)
            button.addTarget(self, action: #selector(insertCompletion(_ :)), for: .touchUpInside)
            buttons.append(button)
        }
        var boxHeight: Double = 200
        if data.count < 5 {
            boxHeight = Double(40 * data.count)
        }
        
        var position_x = position.origin.x
        if position_x > 200 {
            position_x = position.origin.x - 200
        }
        
        var position_y = position.origin.y + 30
        if position_y > 300 {
            position_y = position.origin.y - 10 - boxHeight
        }
        
        let completionBox = CompletionBox(frame: CGRect(x: position_x, y: position_y, width: 300, height: boxHeight), buttons: buttons)
        self.view.addSubview(completionBox)
        currentCompletionBox = completionBox
        print(data)
    }
    
    @objc func insertCompletion(_ sender: ComplationButton) {
        removeCompletionBox()
        currentCodeView?.insertText(sender.label)
    }
    
    func removeCompletionBox() {
        if let box = self.currentCompletionBox {
            box.removeFromSuperview()
            self.currentCompletionBox = nil
        }
    }
}
