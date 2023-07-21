//
//  LSClient.swift
//  iCode
//
//  Created by morinoyu8 on 06/23/23.
//

import Foundation

class LSClient {
    
    let rootUri: String
    let name: String
    var id: Int
    var id2Method: [Int: LSMethod]
    let fileHandle: FileHandle
    let source: DispatchSourceFileSystemObject
    let codeViewController: CodeViewController
    
    init (codeViewController: CodeViewController) {
        let root = String(cString: get_all_path("/".cString(using: .utf8)))
        self.rootUri = URL(fileURLWithPath: root).absoluteString
        self.name = "Clangd"
        self.id = 1
        self.id2Method = [:]
        run_language_server()
        self.fileHandle = FileHandle(forReadingAtPath: root + "var/log/clangd-stdout.txt")!
        self.source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileHandle.fileDescriptor, eventMask: .write, queue: DispatchQueue.main)
        self.codeViewController = codeViewController
        
        source.setEventHandler {
            self.recieveData(event: self.source.data)
        }
        
        fileHandle.seekToEndOfFile()
        source.resume()
    }
    
    private func recieveData(event: DispatchSource.FileSystemEvent) {
        guard event.contains(.write) else {
            return
        }
        let newData = self.fileHandle.readDataToEndOfFile()
        guard let string = String(data: newData, encoding: .utf8) else { return }
        guard let jsonString = parseData(data: string) else { return }
        do {
            let jsonData = try JSONDecoder().decode(Data_Recieve.self, from: jsonString.data(using: .utf8)!)
            guard let id = jsonData.id else { return }
            guard let method = id2Method[id] else { return }
            id2Method.removeValue(forKey: id)
            switch (method) {
            case LSMethod.Initialize:
                recieveInitialize(json: jsonString)
                print("LS-initialize: \(jsonString)")
                break
            case LSMethod.TextDocument_Completion:
                print("LS-complation: \(jsonString)")
                recieveCompletion(json: jsonString)
                break
            default:
                return
            }
            
        } catch {
            print("Recieve Data error: \(error).")
            return
        }
    }
    
    private func parseData(data: String) -> String? {
        let components = data.components(separatedBy: "\r\n")
        if (components.count < 3) {
            return nil
        }
        return components[2]
    }
    
    private func recieveInitialize(json: String) {
        initialized()
    }
    
    private func recieveCompletion(json: String) {
        do {
            let data = try JSONDecoder().decode(Completion_Recieve.self, from: json.data(using: .utf8)!)
            var complationItems: [CompletionItem] = data.result.items
            codeViewController.recieveCompletion(data: complationItems)
        } catch {
            print("RecieveCompletion error: \(error).")
        }

    }
    
    
    private func sendData(json: String) {
        self.id += 1
        let contentLength = json.utf8.count
        let sendData = "Content-Length: \(contentLength)\r\n\(json)\n"
        let length = sendData.utf8.count
        send_server(sendData, Int32(length))
    }
    
    //
    //  initialize
    //
    func initialize() {
        let initializeParams = InitializeParams(processId: 1, rootUri: self.rootUri, capabilities: [])
        let initialize = Initialize(id: self.id, method: "initialize", params: initializeParams)
        let initializeData = try! JSONEncoder().encode(initialize)
        var initializeString = String(data: initializeData, encoding: .utf8)!
        
        let del: Set<Character> = ["\\"]
        initializeString.removeAll(where:{del.contains($0)})
        self.id2Method.updateValue(LSMethod.Initialize, forKey: self.id)
        sendData(json: initializeString)
    }
    
    //
    //  initialized
    //
    func initialized() {
        let initialized = Initialized(method: "initialized", params: InitializedParams())
        let initializedData = try! JSONEncoder().encode(initialized)
        let initializedString = String(data: initializedData, encoding: .utf8)!
        self.id2Method.updateValue(LSMethod.Initialized, forKey: self.id)
        sendData(json: initializedString)
    }
    
    //
    //  textDocument/didOpen
    //
    func textDocument_didOpen(allPath: String, text: String) {
        let uri = URL(fileURLWithPath: allPath).absoluteString
        let textDocumentItem = TextDocumentItem(uri: uri, languageId: "cpp", version: 0, text: text)
        let didOpenTextDocumentParams = DidOpenTextDocumentParams(textDocument: textDocumentItem)
        let didOpen = DidOpen(method: "textDocument/didOpen", params: didOpenTextDocumentParams)
        let didOpenData = try! JSONEncoder().encode(didOpen)
        var didOpenString = String(data: didOpenData, encoding: .utf8)!
        //let del: Set<Character> = ["\\"]
        //didOpenString.removeAll(where:{del.contains($0)})
        self.id2Method.updateValue(LSMethod.TextDocument_DidOpen, forKey: self.id)
        sendData(json: didOpenString)
    }
    
    //
    //  textDocument/didChange
    //
    func textDocument_didChange(allPath: String, text: String) {
        let uri = URL(fileURLWithPath: allPath).absoluteString
        let versionedTextDocumentIdentifier = VersionedTextDocumentIdentifier(uri: uri, version: 1)
        let textDocumentContentChangeEvent = TextDocumentContentChangeEvent(text: text)
        let didChangeTextDocumentParams = DidChangeTextDocumentParams(textDocument: versionedTextDocumentIdentifier, contentChanges: [textDocumentContentChangeEvent])
        let didChange = DidChange(method: "textDocument/didChange", params: didChangeTextDocumentParams)
        let didChangeData = try! JSONEncoder().encode(didChange)
        var didChangeString = String(data: didChangeData, encoding: .utf8)!
        self.id2Method.updateValue(LSMethod.TextDocument_DidChange, forKey: self.id)
        sendData(json: didChangeString)
    }
    
    //
    //  textDocument/completion
    //
    func textDocument_completion(allPath: String, line: Int, character: Int) {
        let uri = URL(fileURLWithPath: allPath).absoluteString
        let textDocumentIdentifier = TextDocumentIdentifier(uri: uri)
        let position = Position(line: line, character: character)
        let completionParams = CompletionParams(textDocument: textDocumentIdentifier, position: position)
        let completion = Completion(id: self.id, method: "textDocument/completion", params: completionParams)
        let completionData = try! JSONEncoder().encode(completion)
        var completionString = String(data: completionData, encoding: .utf8)!
        self.id2Method.updateValue(LSMethod.TextDocument_Completion, forKey: self.id)
        sendData(json: completionString)
    }
}
