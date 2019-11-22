//
//  JupyterManager.swift
//  JupyterKit
//
//  Created by Pedro José Pereira Vieito on 10/12/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import FoundationKit

public class JupyterManager {
    private static let jupyterModuleArguments = ["-m", "jupyter"]
    
    internal static func getPythonProcess() throws -> Process {
        do {
            return try Process(executableName: "python3")
        }
        catch {
            return try Process(executableName: "python")
        }
    }
    
    private static func runJupyterAndGetOutput(arguments: [String]) throws -> String {
        let pythonProcess = try getPythonProcess()
        pythonProcess.standardError = FileHandle.nullDevice
        pythonProcess.arguments = JupyterManager.jupyterModuleArguments + arguments
        return try pythonProcess.runAndGetOutputString()
    }
    
    internal static func launchJupyter(arguments: [String]) throws {
        let pythonProcess = try getPythonProcess()
        pythonProcess.standardOutput = FileHandle.nullDevice
        pythonProcess.standardError = FileHandle.nullDevice
        pythonProcess.arguments = JupyterManager.jupyterModuleArguments + arguments
        try pythonProcess.run()
    }
}

extension JupyterManager {
    /// Launches a new notebook server.
    ///
    /// - Throws: Error trying launch the notebook server.
    public static func launchNotebookServer(
        launchBrowser: Bool = false,
        ip: String? = nil,
        port: Int? = nil,
        notebookDirectoryURL: URL? = nil
    ) throws {
        var arguments = ["notebook"]
        
        if let ip = ip {
            arguments.append("--ip=\(ip)")
        }
        if let port = port {
            arguments.append("--port=\(port)")
        }
        if let notebookDirectoryURL = notebookDirectoryURL {
            arguments.append("--notebook-dir=\(notebookDirectoryURL.path)")
        }
        if !launchBrowser {
            arguments.append("--no-browser")
        }
        
        var notebooks = try listNotebookServers()
        let initalNotebookServersCount = notebooks.count
        try JupyterManager.launchJupyter(arguments: arguments)
        while notebooks.count == initalNotebookServersCount {
            notebooks = try listNotebookServers()
        }
    }
    
    /// Stops all the notebooks running servers.
    ///
    /// - Throws: Error listing or stopping the running servers.
    public static func stopNotebookServers() throws {
        let notebooks = try listNotebookServers()
        for notebook in notebooks {
            try notebook.stop()
        }
    }
    
    /// Lists all running notebook servers.
    ///
    /// - Returns: List of `JupyterInstance` objects.
    /// - Throws: Error trying to list running servers.
    public static func listNotebookServers() throws -> [JupyterNotebookServer] {
        var json = try JupyterManager.runJupyterAndGetOutput(arguments: ["notebook", "list", "--json"])
        json = "[\(json.components(separatedBy: .newlines).joined(separator: ","))]"
        guard let jsonData = json.data(using: .utf8) else {
            throw CocoaError(.coderInvalidValue)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode([JupyterNotebookServer].self, from: jsonData)
    }
}
