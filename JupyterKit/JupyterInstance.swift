//
//  JupyterInstance.swift
//  JupyterKit
//
//  Created by Pedro José Pereira Vieito on 10/12/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

#if canImport(Cocoa)
import Cocoa
#endif

public struct JupyterInstance: Codable {
    public let url: URL
    public let token: String
    public let pid: Int
    public let port: Int

    public let secure: Bool
    public let password: Bool

    let hostname: String
    let base_url: String
    let notebook_dir: String
    
    public var identifier: String {
        return "\(self.hostname):\(self.port)"
    }
    
    public var notebookDirectory: URL {
        return URL(fileURLWithPath: self.notebook_dir)
    }
    
    public func open() throws {
        #if canImport(Cocoa)
        NSWorkspace.shared.open(url)
        #else
        throw JupyterError.openingNotebookNotSupported
        #endif
    }
    
    public func stop() throws {
        let portString = String(port)
        let _ = try JupyterManager.launchJupyterWithOutput(arguments: ["notebook", "stop", portString])
    }
}
