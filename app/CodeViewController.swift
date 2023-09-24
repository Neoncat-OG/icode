//
//  CodeViewController.swift
//  iCode
//
//  Created by morinoyu8 on 06/12/23.
//

import UIKit
import Runestone

class CodeViewController: UIViewController {
    var codeTextViewList: CodeTextViewList = CodeTextViewList()
    var currentCodeTextView: CodeTextView?
    var currentFilePath: String = ""
    
    // Path to root of the Linux filesystem
    // The last "/" is removed
    let rootAllPath: String = String(String(cString: get_all_path("/".cString(using: .utf8))).dropLast())
    
    @IBOutlet weak var codeView: UIView!
    @IBOutlet weak var codeViewBottomConstraint: NSLayoutConstraint!
    
    var currentCompletionBox: CompletionBox? = nil
    
    let complationMaxHeight: Double = 120
    let completionCellHeight:Double = 40
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LSClient.codeVC = self
        LSController.runLanguageServer(name: "clangd")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Called when a file is selected from the File page
    func openCode(filePath: String) {
        let codeTextView = CodeTextView()
        setCodeTextViewAsChild(codeTextView)
        
        // Update codeTextView list and current things
        codeTextViewList.append(filePath: filePath, codeTextView: codeTextView)
        currentCodeTextView = codeTextView
        currentFilePath = filePath
        
        // Open file
        guard let text = try? String(contentsOfFile: rootAllPath + filePath) else {
            showAlert()
            return
        }
        
        // Set file text to codeTextView
        // https://docs.runestone.app/documentation/runestone/gettingstarted/#4-Set-the-state-of-the-text-view
        //
        DispatchQueue.global(qos: .userInitiated).async {
            let state = TextViewState(text: text, language: .c)
            DispatchQueue.main.async {
                codeTextView.setState(state)
            }
        }
        
        LSClient.textDocument_didOpen(path: filePath, text: text)
    }
    
    // Add new CodeTextView as a chile of codeView
    private func setCodeTextViewAsChild(_ new: CodeTextView) {
        new.editorDelegate = self
        new.inputAccessoryView = self.inputAccessoryView
        codeView.addSubview(new)
        new.setConstraint(parent: codeView)
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
    
    // Remove completionBox when cursor is moved
    // TODO: Refine timing of completionBox removing
    func textViewDidChangeSelection(_ textView: UITextView) {
        removeCompletionBox()
    }
    
    func insertTab() {
        currentCodeTextView?.insertText("\t")
    }
    
    // Adjust size of codeEditView when keyboard appears
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            codeViewBottomConstraint.constant = keyboardSize.height - self.view.safeAreaInsets.bottom
        }
    }
    
    @objc func keyboardWillHide() {
        removeCompletionBox()
        codeViewBottomConstraint.constant = 0
    }
    
    // Show completionBox
    func showCompletion(data: [CompletionItem]) {
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
        
        let boxRect = completionBoxRect(cellCount: data.count)
        let completionBox = CompletionBox(frame: boxRect, buttons: buttons)
        self.view.addSubview(completionBox)
        codeViewBottomConstraint.constant += boxRect.height
        currentCompletionBox = completionBox
    }
    
    @objc func insertCompletion(_ sender: ComplationButton) {
        removeCompletionBox()
        currentCodeTextView?.insertText(sender.label)
    }
    
    func completionBoxRect(cellCount: Int) -> CGRect {
        var boxHeight: Double = Double(complationMaxHeight)
        if cellCount < Int(complationMaxHeight) / Int(completionCellHeight) {
            boxHeight = completionCellHeight * Double(cellCount)
        }
        
        let position_x = 0.0
        let position_y = self.view.frame.height - codeViewBottomConstraint.constant - self.view.safeAreaInsets.bottom - boxHeight
        
        return CGRect(x: position_x, y: position_y, width: safeAreaSize().width, height: boxHeight)
    }
    
    // Remove completionBox if it is shown
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
}

extension CodeViewController: TextViewDelegate {
    
    // Send message to language servers when text in textView is updated
    func textView(_ textView: TextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let startLocation = textView.textLocation(at: range.location) else { return true }
        guard let endLocation = textView.textLocation(at: range.location + range.length) else { return true }
        LSClient.textDocument_didChange(path: currentFilePath, text: text, startLocation: startLocation, endLocation: endLocation)
        
        if text == "." {
            LSClient.textDocument_completion(path: currentFilePath, line: startLocation.lineNumber, character: endLocation.column + 1)
            return true
        }
        removeCompletionBox()
        return true
    }
}
