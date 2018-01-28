//
//  JupyterInstance.swift
//  JupyterKit
//
//  Created by Pedro José Pereira Vieito on 10/12/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import Cocoa

public struct JupyterInstance: Codable {
    public let url: URL
    public let token: String

    let secure: Bool
    let hostname: String
    let pid: Int
    let password: Bool
    let port: Int

    let base_url: String
    let notebook_dir: String
    
    public func open() {
        NSWorkspace.shared.open(url)
    }
    
    public func stop() throws {
        let portString = String(port)
        let _ = try JupyterManager.launchJupyterWithOutput(arguments: ["notebook", "stop", portString])
    }
}
