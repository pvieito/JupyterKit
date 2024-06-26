//
//  JupyterManager.swift
//  JupyterKit
//
//  Created by Pedro José Pereira Vieito on 10/12/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import FoundationKit
import PythonKit

public class JupyterManager {
    private static let jupyterNotebookModuleArguments = ["-m", "notebook"]
    
    internal static func loadPythonProcess() throws -> Process {
        try PythonLibrary.loadLibrary()
        let sys = try Python.attemptImport("sys")
        guard let executable = sys.checking.executable, let executablePath = String(executable) else {
            throw NSError(description: "Python executable not available.")
        }
        return Process(executableURL: executablePath.pathURL)
    }
    
    private static func runJupyterNotebookAndGetOutput(arguments: [String]) throws -> String {
        let pythonProcess = try loadPythonProcess()
        pythonProcess.standardError = FileHandle.nullDevice
        pythonProcess.arguments = JupyterManager.jupyterNotebookModuleArguments + arguments
        return try pythonProcess.runAndGetOutputString()
    }
    
    internal static func launchJupyterNotebook(arguments: [String]) throws {
        let pythonProcess = try loadPythonProcess()
        pythonProcess.standardOutput = FileHandle.nullDevice
        pythonProcess.standardError = FileHandle.nullDevice
        pythonProcess.arguments = JupyterManager.jupyterNotebookModuleArguments + arguments
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
        var arguments: [String] = []
        
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
        try JupyterManager.launchJupyterNotebook(arguments: arguments)
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
        var json = try JupyterManager.runJupyterNotebookAndGetOutput(arguments: ["list", "--json"])
        json = "[\(json.components(separatedBy: .newlines).joined(separator: ","))]"
        guard let jsonData = json.data(using: .utf8) else {
            throw CocoaError(.coderInvalidValue)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode([JupyterNotebookServer].self, from: jsonData)
    }
}
