//
//  LSInitializer.swift
//  iCode
//
//  Created by morinoyu8 on 08/09/23.
//

import Foundation

enum CodeLanguage: String {
    case c = "c"
    case cpp = "cpp"
    case python = "python"
    case swift = "swift"
}

class LSInitializer {
    
    static var fd_ops_ls: fd_ops = fd_ops()
    
    static func runLanguageServer(name: String) {
        
        // Called when values is written from LS process.
        // Get values from LS by setting write function pointer of fd_ops to the pointer of this function.
        let write_ls_value: @convention(c) (UnsafeMutablePointer<fd>?, UnsafeRawPointer?, Int) -> (Int) = { fd, buf, bufsize in
            if let buf {
                let data = Data(bytes: buf, count: bufsize)
                guard let message = String(data: data, encoding: .utf8) else {
                    print("Converting data to string error on write_ls_value.")
                    return bufsize
                }
                LSClient.recieveResponse(message: message)
            }
            return bufsize
        }
        
        // var fd_ops_ls: fd_ops = fd_ops()
        fd_ops_ls.write = write_ls_value
        
        run_language_server(UnsafePointer<fd_ops>?(&fd_ops_ls))
    }
    
}
