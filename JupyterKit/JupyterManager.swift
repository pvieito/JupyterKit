//
//  JupyterManager.swift
//  JupyterKit
//
//  Created by Pedro José Pereira Vieito on 10/12/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

public class JupyterManager {
    
    public enum JupyterError: LocalizedError {
        case executableNotAvailable(String)
        case jupyterError(String)
        case noOutput
        
        public var errorDescription: String? {
            
            switch self {
            case .executableNotAvailable(let path):
                return "Jupyter executable not available at “\(path)”."
            case .jupyterError(let errorString):
                return "Jupyter Error: \(errorString)."
            case .noOutput:
                return "No output."
            }
        }
    }
    
    // MARK: Private properties and methods.
    
    private static var jupyterExecutablePath = "/usr/local/bin/jupyter"

    private static func getJupyterExecutableURL() throws -> URL {
        
        let jupyterExecutablePath = JupyterManager.jupyterExecutablePath
        
        guard FileManager.default.isExecutableFile(atPath: jupyterExecutablePath) else {
            throw JupyterError.executableNotAvailable(jupyterExecutablePath)
        }
    
        return URL(fileURLWithPath: jupyterExecutablePath)
    }
    
    internal static func launchJupyterWithOutput(arguments: [String]) throws -> String {
        
        let task = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        task.executableURL = try getJupyterExecutableURL()
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        task.arguments = arguments
        
        try task.run()
        
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
        
        try task.run()
    }

    
    // MARK: Public implementation.

    public static var shared = JupyterManager()
    
    public func openNotebook() throws {

        let notebooks = try self.listNotebooks()
        
        guard let notebook = notebooks.first else {
            try self.launchNotebook()
            return
        }
        
        notebook.open()
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
        
        let json = try JupyterManager.launchJupyterWithOutput(arguments: ["notebook", "list", "--json"])
        
        let decoder = JSONDecoder()
        var notebooks: [JupyterInstance] = []
        
        json.enumerateLines { (line, _) in
            
            if let lineData = line.data(using: .utf8),
                let notebookInstance = try? decoder.decode(JupyterInstance.self, from: lineData) {
                notebooks.append(notebookInstance)
            }
        }
        
        return notebooks
    }
}
