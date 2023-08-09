//
//  LSController.swift
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

class LSController {
    
    static var iosfs_fdops_ls: fd_ops = fd_ops()
    
    static func runLanguageServer(name: String) {
        let write_ls_value: @convention(c) (UnsafeMutablePointer<fd>?, UnsafeRawPointer?, Int) -> (Int) = { fd, buf, bufsize in
            if let buf {
                let data = Data(bytes: buf, count: bufsize)
                let s = String(data: data, encoding: .utf8) ?? ""
                LSClient.recieveData(data: s)
            }
            return bufsize
        }

        iosfs_fdops_ls.write = write_ls_value
        run_language_server(UnsafePointer<fd_ops>?(&iosfs_fdops_ls))
        LSClient.initialize()
    }
    
}
