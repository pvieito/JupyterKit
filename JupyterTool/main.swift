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
import CommandLineKit

let openOption = BoolOption(shortFlag: "o", longFlag: "open", helpMessage: "Open running instances or launches a new one.")
let stopOption = BoolOption(shortFlag: "k", longFlag: "kill", helpMessage: "Stop all running instances.")
let verboseOption = BoolOption(shortFlag: "v", longFlag: "verbose", helpMessage: "Verbose mode.")
let debugOption = BoolOption(shortFlag: "d", longFlag: "debug", helpMessage: "Debug mode.")
let helpOption = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Prints a help message.")

let cli = CommandLineKit.CommandLine()
cli.addOptions(openOption, stopOption, verboseOption, debugOption, helpOption)

do {
    try cli.parse(strict: true)
}
catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

if helpOption.value {
    cli.printUsage()
    exit(0)
}

Logger.logMode = .commandLine
Logger.logLevel = verboseOption.value ? .verbose : .info
Logger.logLevel = debugOption.value ? .debug : Logger.logLevel

do {
    var notebooks = try JupyterManager.listNotebookServers()
    if notebooks.isEmpty, openOption.value {
        try JupyterManager.launchNotebookServer(launchBrowser: false)
    }
    notebooks = try JupyterManager.listNotebookServers()

    guard !notebooks.isEmpty else {
        Logger.log(warning: "No Jupyter Notebook instances running.")
        exit(0)
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

        if openOption.value {
            do {
                try notebook.open()
            }
            catch {
                Logger.log(warning: error)
            }
        }
        
        if stopOption.value {
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

