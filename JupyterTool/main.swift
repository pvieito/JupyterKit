//
//  main.swift
//  JupyterTool
//
//  Created by Pedro José Pereira Vieito on 30/1/18.
//  Copyright © 2018 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import LoggerKit
import JupyterKit
import ArgumentParser

struct JupyterTool: ParsableCommand {
    static var configuration: CommandConfiguration {
        return CommandConfiguration(commandName: String(describing: Self.self))
    }
    
    @Flag(name: .shortAndLong, help: "Open running instances or launches a new one.")
    var open: Bool
    
    @Flag(name: .shortAndLong, help: "Stop all running instances.")
    var kill: Bool
    
    @Flag(name: .shortAndLong, help: "Verbose mode.")
    var verbose: Bool
    
    @Flag(name: .shortAndLong, help: "Debug mode.")
    var debug: Bool
    
    func run() throws {
        do {
            Logger.logMode = .commandLine
            Logger.logLevel = self.verbose ? .verbose : .info
            Logger.logLevel = self.debug ? .debug : Logger.logLevel
            
            var notebooks = try JupyterManager.listNotebookServers()
            if notebooks.isEmpty, self.open {
                try JupyterManager.launchNotebookServer(launchBrowser: false)
            }
            notebooks = try JupyterManager.listNotebookServers()
            
            guard !notebooks.isEmpty else {
                Logger.log(warning: "No Jupyter Notebook instances running.")
                Foundation.exit(0)
            }
            
            Logger.log(important: "Jupyter Notebooks (\(notebooks.count))")
            
            for notebook in notebooks {
                Logger.log(success: "Notebook “\(notebook.identifier)”")
                Logger.log(verbose: "Directory: \(notebook.notebookDirectory.path)")
                Logger.log(verbose: "URL: \(notebook.url.absoluteURL)")
                Logger.log(verbose: "Port: \(notebook.port)")
                Logger.log(verbose: "Secure: \(notebook.secure)")
                Logger.log(verbose: "Token: \(notebook.token)")
                
                if let sessionURL = notebook.sessionURL {
                    Logger.log(debug: "Session URL: \(sessionURL)")
                }
                
                if self.open {
                    do {
                        try notebook.open()
                    }
                    catch {
                        Logger.log(warning: error)
                    }
                }
                
                if self.kill {
                    do {
                        Logger.log(notice: "Killing Notebook “\(notebook.identifier)”...")
                        try notebook.stop()
                    }
                    catch {
                        Logger.log(warning: error)
                    }
                }
            }
        }
        catch {
            Logger.log(fatalError: error)
        }
    }
}

JupyterTool.main()
