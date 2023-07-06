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
    var rootUri: String = "file:///"
    
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var innerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var codeInnerView: UIView!
    @IBOutlet weak var codeInnerWidth: NSLayoutConstraint!
    
    @IBOutlet weak var innerScrollViewLeading: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let root = String(cString: get_all_path("/".cString(using: .utf8)))
        self.rootUri = URL(fileURLWithPath: root).absoluteString
        print(self.rootUri)
        run_language_server()
    }
    
    func addCodeEditView(filePath: String) {
        let textStorage = CodeAttributedString(lineHeight: 2.4)
        textStorage.language = getLanguage(filePath: filePath)
        textStorage.highlightr.setTheme(to: "xcode")
        textStorage.highlightr.theme.codeFont = UIFont(name: "Menlo-Regular", size: 13)
        
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(size: view.bounds.size)
        layoutManager.addTextContainer(textContainer)
        
        let numView = CodeNumTextView(frame: self.innerView.frame, textContainer: nil, lineHeight: 2.4)
        let codeView = CodeTextView(frame: self.innerView.frame, textContainer: textContainer, numView: numView, filePath: filePath, viewHeight: innerHeight, viewWidth: codeInnerWidth, leading: innerScrollViewLeading)
        
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
        initializeLS()
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
    
    // Initialization
    // {
    //    "jsonrpc": "2.0",
    //    "id": 1,
    //    "method": "initialize"
    //    "params": {
    //      "processId": 1,
    //      "rootUri": rootUri
    //      "capabilities": {},
    //    }
    // }
    func initializeLS() {
        struct InitializeParams: Codable {
            var processId: Int
            var rootUri: String
            var capabilities: [String]
        }
        
        struct Initialize: Codable {
            var jsonrpc: String
            var id: Int
            var method: String
            var params: InitializeParams
        }
        
        let initializeParams = InitializeParams(processId: 1, rootUri: self.rootUri, capabilities: [])
        let initialize = Initialize(jsonrpc: "2.0", id: 1, method: "initialize", params: initializeParams)
        let initializeData = try! JSONEncoder().encode(initialize)
        var initializeString = String(data: initializeData, encoding: .utf8)!
        
        let del: Set<Character> = ["\\"]
        initializeString.removeAll(where:{del.contains($0)})
        
        sendData(json: initializeString)
    }
    
    func sendData(json: String) {
        let contentLength = json.utf8.count
        let sendData = "Content-Length: \(contentLength)\r\n\(json)\n"
        let length = sendData.utf8.count
        send_server(sendData, Int32(length))
    }
}
