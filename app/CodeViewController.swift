//
//  CodeViewController.swift
//  iCode
//
//  Created by morinoyu8 on 06/12/23.
//

import UIKit
import Runestone

class CodeViewController: UIViewController {
    var filenames = [String](repeating: "", count: 100)
    var tabCount = 0
    var lsClients: [String:LSClient] = [:]
    var currentCodeTextView: CodeTextView? = nil
    var rootAllPath: String = ""
    
    @IBOutlet weak var codeView: UIView!
    @IBOutlet weak var codeViewBottomConstraint: NSLayoutConstraint!
    
    var currentCompletionBox: CompletionBox? = nil
    
    let complationMaxHeight: Double = 120
    let completionCellHeight:Double = 40
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.rootAllPath = String(cString: get_all_path("/".cString(using: .utf8)))
        self.rootAllPath.removeLast()
        LSController.runLanguageServer(name: "clangd")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func addCodeEditView(filePath: String) {
        let language = getLanguage(filePath: filePath)
        let codeTextView = CodeTextView(filePath: rootAllPath + filePath)
        currentCodeTextView = codeTextView
        
        guard let text = try? String(contentsOfFile: rootAllPath + filePath) else {
            showAlert()
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let state = TextViewState(text: text, language: .c)
            DispatchQueue.main.async {
                codeTextView.setState(state)
            }
        }
        
        filenames[tabCount] = filePath
        tabCount += 1
        
        codeTextView.editorDelegate = self
        codeView.addSubview(codeTextView)
        codeTextView.setConstraint(parent: codeView)
        LSClient.codeVC = self
        LSClient.textDocument_didOpen(path: filePath, text: text)
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
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        removeCompletionBox()
    }
    
    func insertTab() {
        currentCodeTextView?.insertText("\t")
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            codeViewBottomConstraint.constant = keyboardSize.height - self.view.safeAreaInsets.bottom
        }
    }
    
    @objc func keyboardWillHide() {
        removeCompletionBox()
        codeViewBottomConstraint.constant = 0
    }
    
    func recieveCompletion(data: [CompletionItem]) {
        removeCompletionBox()
        
        if data.count < 1 {
            return
        }
        
        var buttons: [ComplationButton] = []
        for (i, completion) in data.enumerated() {
            let button = ComplationButton(frame: CGRect(x: 0, y: completionCellHeight * Double(i), width: safeAreaSize().width, height: completionCellHeight), main: completion.insertText, sub: completion.detail ?? "")
            button.addTarget(self, action: #selector(insertCompletion(_ :)), for: .touchUpInside)
            buttons.append(button)
        }
        
        let boxRect = calculateBoxRect(cellCount: data.count)
        let completionBox = CompletionBox(frame: boxRect, buttons: buttons)
        self.view.addSubview(completionBox)
        codeViewBottomConstraint.constant += boxRect.height
        currentCompletionBox = completionBox
    }
    
    @objc func insertCompletion(_ sender: ComplationButton) {
        removeCompletionBox()
        currentCodeTextView?.insertText(sender.label)
    }
    
    func calculateBoxRect(cellCount: Int) -> CGRect {
        var boxHeight: Double = Double(complationMaxHeight)
        if cellCount < Int(complationMaxHeight) / Int(completionCellHeight) {
            boxHeight = completionCellHeight * Double(cellCount)
        }
        
        let position_x = 0.0
        let position_y = self.view.frame.height - codeViewBottomConstraint.constant - self.view.safeAreaInsets.bottom - boxHeight
        
        return CGRect(x: position_x, y: position_y, width: safeAreaSize().width, height: boxHeight)
    }
    
    func removeCompletionBox() {
        if let box = self.currentCompletionBox {
            codeViewBottomConstraint.constant -= box.frame.height
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
    
//    func fitCursorPosition() {
//        guard let start = currentCodeView?.selectedTextRange?.start else { return }
//        guard let cursorFrame = currentCodeView?.caretRect(for: start) else { return }
//        guard let position = currentCodeView?.convert(cursorFrame, to: self.view) else { return }
//        if position.origin.y.isInfinite {
//            return
//        }
//
//        if position.origin.y < self.view.safeAreaInsets.top {
//            scrollView.contentOffset.y -= self.view.safeAreaInsets.top - position.origin.y
//        }
//
//        if position.origin.y + 10 > self.view.safeAreaInsets.top + safeAreaSize().height - scrollbarBottom.constant {
//            scrollView.contentOffset.y += position.origin.y - (self.view.safeAreaInsets.top + safeAreaSize().height - scrollbarBottom.constant) + cursorFrame.height
//        }
//    }
}

extension CodeViewController: TextViewDelegate {
    func textView(_ textView: TextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let startLocation = textView.textLocation(at: range.location) else { return true }
        guard let endLocation = textView.textLocation(at: range.location + range.length) else { return true }
        LSClient.textDocument_didChange(path: filenames[tabCount - 1], text: text, startLocation: startLocation, endLocation: endLocation)
        
        if text == "." {
            LSClient.textDocument_completion(path: filenames[tabCount - 1], line: startLocation.lineNumber, character: endLocation.column + 1)
        }
        return true
    }
}
