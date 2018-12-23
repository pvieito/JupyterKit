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
    
    // MARK: Private properties and methods.
    private static let jupyterModuleArguments = ["-m", "jupyter"]
    
    private static func getPythonProcess() throws -> Process {
        return try Process(executableName: "python")
    }
    
    internal static func launchJupyterWithOutput(arguments: [String]) throws -> String {
        let pythonProcess = try getPythonProcess()
        pythonProcess.arguments = JupyterManager.jupyterModuleArguments + arguments
        let outputData = try pythonProcess.runAndGetOutputData()
        
        guard let outputString =
            String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: CharacterSet.newlines) else {
            throw JupyterError.noOutput
        }
        return outputString
    }
    
    internal static func launchJupyter(arguments: [String]) throws {
        let pythonProcess = try getPythonProcess()
        pythonProcess.standardOutput = FileHandle.nullDevice
        pythonProcess.standardError = FileHandle.nullDevice
        pythonProcess.arguments = JupyterManager.jupyterModuleArguments + arguments
        try pythonProcess.run()
    }

    
    // MARK: Public implementation.

    /// Shared `JupyterManager` object of the process.
    public static var shared = JupyterManager()
    
    /// Opens the first running notebook instances or launchs a new one.
    ///
    /// - Throws: Error trying to open or launching the notebook.
    public func openNotebook() throws {
        let notebooks = try self.listNotebooks()
        
        guard let notebook = notebooks.first else {
            try self.launchNotebook()
            return
        }
        
        try notebook.open()
    }
    
    /// Launches a new notebook instance.
    ///
    /// - Throws: Error trying launch the notebook.
    private func launchNotebook() throws {
        try JupyterManager.launchJupyter(arguments: ["notebook"])
    }
    
    /// Stops all the notebooks running instances.
    ///
    /// - Throws: Error listing or stopping the running instances.
    public func stopNotebooks() throws {
        let notebooks = try self.listNotebooks()
        for notebook in notebooks {
            try notebook.stop()
        }
    }
    
    /// Lists all running notebook instances.
    ///
    /// - Returns: List of `JupyterInstance` objects.
    /// - Throws: Error trying to list running instances.
    public func listNotebooks() throws -> [JupyterInstance] {
        var json = try JupyterManager.launchJupyterWithOutput(arguments: ["notebook", "list", "--json"])
        json = "[\(json.components(separatedBy: .newlines).joined(separator: ","))]"
        guard let jsonData = json.data(using: .utf8) else {
            throw CocoaError(.coderInvalidValue)
        }

        let decoder = JSONDecoder()
        return try decoder.decode([JupyterInstance].self, from: jsonData)
    }
}
