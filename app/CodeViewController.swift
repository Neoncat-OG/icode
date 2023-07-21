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
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var innerScrollViewLeading: NSLayoutConstraint!
    
    var currentCompletionBox: CompletionBox? = nil
    
    let complationMaxHeight: Double = 120
    let completionCellHeight:Double = 40
    
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
        fitCursorPosition()
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
            fitCursorPosition()
        }
    }
    
    @objc func keyboardWillHide() {
        removeCompletionBox()
        scrollbarBottom.constant = 0
    }
    
    func recieveCompletion(data: [CompletionItem]) {
        removeCompletionBox()
        
        if data.count < 1 {
            return
        }
        
        guard let start = currentCodeView?.selectedTextRange?.start else { return }
        guard let cursorFrame = currentCodeView?.caretRect(for: start) else { return }
        
        guard let position = currentCodeView?.convert(cursorFrame, to: self.view) else { return }
        
        var buttons: [ComplationButton] = []
        for (i, completion) in data.enumerated() {
            let button = ComplationButton(frame: CGRect(x: 0, y: completionCellHeight * Double(i), width: safeAreaSize().width, height: completionCellHeight), main: completion.insertText, sub: completion.detail)
            button.addTarget(self, action: #selector(insertCompletion(_ :)), for: .touchUpInside)
            buttons.append(button)
        }
        
        let boxRect = calculateBoxRect(cursorPosition: position, cellCount: data.count)
        let completionBox = CompletionBox(frame: boxRect, buttons: buttons)
        self.view.addSubview(completionBox)
        scrollbarBottom.constant += boxRect.height
        fitCursorPosition()
        currentCompletionBox = completionBox
    }
    
    @objc func insertCompletion(_ sender: ComplationButton) {
        removeCompletionBox()
        currentCodeView?.insertText(sender.label)
    }
    
    func calculateBoxRect(cursorPosition: CGRect, cellCount: Int) -> CGRect {
        var boxHeight: Double = Double(complationMaxHeight)
        if cellCount < Int(complationMaxHeight) / Int(completionCellHeight) {
            boxHeight = completionCellHeight * Double(cellCount)
        }
        
        let position_x = 0.0
        let position_y = self.view.safeAreaInsets.top + safeAreaSize().height - scrollbarBottom.constant - boxHeight
        
        return CGRect(x: position_x, y: position_y, width: safeAreaSize().width, height: boxHeight)
    }
    
    func removeCompletionBox() {
        if let box = self.currentCompletionBox {
            scrollbarBottom.constant -= box.frame.height
            box.removeFromSuperview()
            self.currentCompletionBox = nil
        }
    }
    
    func safeAreaSize() -> (width: CGFloat, height: CGFloat) {
        let safeAreaWidth = self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right
        let safeAreaHeight = self.view.bounds.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom
        return (width: safeAreaWidth, height: safeAreaHeight)
    }
    
    func isPortrait() -> Bool {
        return self.view.bounds.height - self.view.bounds.width > 0
    }
    
    func fitCursorPosition() {
        guard let start = currentCodeView?.selectedTextRange?.start else { return }
        guard let cursorFrame = currentCodeView?.caretRect(for: start) else { return }
        guard let position = currentCodeView?.convert(cursorFrame, to: self.view) else { return }
        
        if position.origin.y < self.view.safeAreaInsets.top {
            scrollView.contentOffset.y -= self.view.safeAreaInsets.top - position.origin.y
        }
        
        if position.origin.y + 10 > self.view.safeAreaInsets.top + safeAreaSize().height - scrollbarBottom.constant {
            scrollView.contentOffset.y += position.origin.y - (self.view.safeAreaInsets.top + safeAreaSize().height - scrollbarBottom.constant) + cursorFrame.height
        }
    }
}
