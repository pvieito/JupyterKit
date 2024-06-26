//
//  JupyterInstance.swift
//  JupyterKit
//
//  Created by Pedro José Pereira Vieito on 10/12/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import FoundationKit

public struct JupyterNotebookServer: Codable {
    /// URL to the Jupyter Notebook server.
    public let url: URL
    
    /// Port of the Jupyter Notebook server.
    public let port: Int
    
    /// Token of the instance.
    public let token: String
    
    /// Process Identifier of the instance.
    public let pid: Int
    
    public let version: String
    public let secure: Bool
    public let password: Bool
    
    let hostname: String
    let root_dir: String
    
    /// Session URL to open in a browser with token parameter.
    public var sessionURL: URL? {
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        
        let queryItem = URLQueryItem(name: "token", value: self.token)
        urlComponents.queryItems = [queryItem]
        return urlComponents.url
    }
    
    /// Identifier of the instance.
    public var identifier: String {
        return "\(self.hostname):\(self.port)"
    }
    
    /// Instance working directory.
    public var notebookDirectory: URL {
        return URL(fileURLWithPath: self.root_dir)
    }
}

extension JupyterNotebookServer {
    /// Opens the Jupyter Notebook server instance on a browser.
    ///
    /// - Throws: Error trying to open the instance.
    public func open() throws {
        guard let sessionURL = self.sessionURL else {
            throw JupyterError.openingNotebookNotSupported
        }
        
        try sessionURL.open()
    }
    
    /// Stops the Jupyter Notebook server instance.
    ///
    /// - Throws: Error trying to stop the server instance.
    public func stop() throws {
        let portString = String(port)
        try JupyterManager.launchJupyterNotebook(arguments: ["stop", portString])
    }
}
