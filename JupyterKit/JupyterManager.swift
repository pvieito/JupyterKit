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
    
    private static var jupyterDefaultExecutableURL = URL(fileURLWithPath: "/usr/local/bin/jupyter")

    private static func getJupyterExecutableURL() throws -> URL {
        
        let jupyterExecutableURL = Process.getExecutableURL(name: jupyterDefaultExecutableURL.lastPathComponent) ?? jupyterDefaultExecutableURL
        
        guard FileManager.default.isExecutableFile(atPath: jupyterExecutableURL.path) else {
            throw JupyterError.executableNotAvailable(jupyterExecutableURL)
        }
    
        return jupyterExecutableURL
    }
    
    internal static func launchJupyterWithOutput(arguments: [String]) throws -> String {
        
        let task = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        task.executableURL = try getJupyterExecutableURL()
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        task.arguments = arguments
        
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
        
        task.executableURL = try getJupyterExecutableURL()
        task.arguments = arguments
        
        task.launch()
    }

    
    // MARK: Public implementation.

    public static var shared = JupyterManager()
    
    public func openNotebook() throws {

        let notebooks = try self.listNotebooks()
        
        guard let notebook = notebooks.first else {
            try self.launchNotebook()
            return
        }
        
        try notebook.open()
    }
    
    private func launchNotebook() throws {
        try JupyterManager.launchJupyter(arguments: ["notebook"])
    }
    
    public func stopNotebooks() throws {
    
        let notebooks = try self.listNotebooks()

        for notebook in notebooks {
            try notebook.stop()
        }
    }
    
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
