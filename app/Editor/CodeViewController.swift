//
//  CodeViewController.swift
//  iCode
//
//  Created by morinoyu8 on 06/12/23.
//

import UIKit
import Runestone

class CodeViewController: UIViewController {
    
    // Manage multiple CodeTextView.
    var codeTextViewList: CodeTextViewList = CodeTextViewList()
    
    // The currently displayed CodeTextView and its file path.
    // This file path is path from root of the Linux filesystem.
    var currentCodeTextView: CodeTextView?
    var currentFilePath: String = ""
    
    // LSClient communicating to the language server that should currently be running.
    var currentLSClient: LSClient?
    
    // completionBox currently displayed.
    // If No completionBox is displayed, it should be nil.
    var currentCompletionBox: CompletionBox? = nil
    
    // Path to root of the Linux filesystem from root of the iOS filesystem.
    // The last "/" is removed.
    let rootAllPath: String = String(String(cString: get_all_path("/".cString(using: .utf8))).dropLast())
    
    @IBOutlet weak var codeView: UIView!
    @IBOutlet weak var codeViewBottomConstraint: NSLayoutConstraint!
    
    private static var instance: CodeViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Only one instance of CodeViewController is created.
        CodeViewController.instance = self
        
        // Run the language server clangd and generate its clients.
        // TODO: Support multiple language servers.
        currentLSClient = LSClient(name: "clangd")
        LSInitializer.runLanguageServer(name: "clangd")
        currentLSClient?.initialize()
        
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
        
        currentLSClient?.textDocumentDidOpen(path: filePath, text: text)
    }
    
    // Add new CodeTextView as a chile of codeView
    private func setCodeTextViewAsChild(_ new: CodeTextView) {
        new.editorDelegate = self
        new.inputAccessoryView = self.inputAccessoryView
        codeView.addSubview(new)
        new.setConstraint(parent: codeView)
    }
    
    // Alert displayed when a text file cannot be opened.
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
        
        // Generate completion box.
        // Set the completion value to be inserted when the button is touched.
        let boxRect = completionBoxRect(cellCount: data.count)
        let completionBox = CompletionBox(frame: boxRect, completionItem: data)
        completionBox.addButtonTarget(self, action: #selector(insertCompletion(_ :)), for: .touchUpInside)
        self.view.addSubview(completionBox)
        currentCompletionBox = completionBox
        
        // Adjust codeView size.
        codeViewBottomConstraint.constant += boxRect.height
    }
    
    @objc func insertCompletion(_ sender: ComplationButton) {
        removeCompletionBox()
        currentCodeTextView?.insertText(sender.label)
    }
    
    // Calculate the position and size of the CompletionBox
    func completionBoxRect(cellCount: Int) -> CGRect {
        var boxHeight: Double = Double(CompletionBox.complationMaxHeight)
        // If the number of completions is less than certain value, reduce the size of the box.
        if cellCount < Int(CompletionBox.complationMaxHeight) / Int(CompletionBox.completionCellHeight) {
            boxHeight = CompletionBox.completionCellHeight * Double(cellCount)
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
    
    static func getInstance() -> CodeViewController? {
        return CodeViewController.instance
    }
    
}

extension CodeViewController: TextViewDelegate {
    
    // Send message to language servers when text in textView is updated
    func textView(_ textView: TextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let start = textView.textLocation(at: range.location) else { return true }
        guard let end = textView.textLocation(at: range.location + range.length) else { return true }
        currentLSClient?.textDocumentDidChange(path: currentFilePath, text: text, startLocation: start, endLocation: end)
        
        if text == "." {
            currentLSClient?.textDocumentCompletion(path: currentFilePath, line: start.lineNumber, character: start.column + 1)
            return true
        }
        removeCompletionBox()
        return true
    }
}
