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
    
    private static var pythonDefaultExecutableURL = URL(fileURLWithPath: "/usr/bin/python")

    private static func getPythonExecutableURL() throws -> URL {
        
        let jupyterExecutableURL = Process.getExecutableURL(name: pythonDefaultExecutableURL.lastPathComponent) ?? pythonDefaultExecutableURL
        
        guard FileManager.default.isExecutableFile(atPath: jupyterExecutableURL.path) else {
            throw JupyterError.executableNotAvailable(jupyterExecutableURL)
        }
    
        return jupyterExecutableURL
    }
    
    internal static func launchJupyterWithOutput(arguments: [String]) throws -> String {
        
        let task = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        task.executableURL = try getPythonExecutableURL()
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        task.arguments = ["-m", "jupyter"] + arguments
        
        task.launch()
        
        task.waitUntilExit()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        
        guard let outputString = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: CharacterSet.newlines) else {
            throw JupyterError.noOutput
        }
        
        guard let errorOuputString = String(data: errorData, encoding: .utf8)?.trimmingCharacters(in: CharacterSet.newlines) else {
            throw JupyterError.noOutput
        }
        
        guard errorOuputString == "" else {
            throw JupyterError.jupyterError(errorOuputString)
        }
        
        return outputString
    }
    
    internal static func launchJupyter(arguments: [String]) throws {
        
        let task = Process()

        task.executableURL = try getPythonExecutableURL()
        task.standardOutput = FileHandle.nullDevice
        task.standardError = FileHandle.nullDevice
        task.arguments = arguments
        
        task.launch()
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
