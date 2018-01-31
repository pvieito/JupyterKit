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

let openOption = BoolOption(shortFlag: "o", longFlag: "open", helpMessage: "Open running instances.")
let stopOption = BoolOption(shortFlag: "k", longFlag: "kill", helpMessage: "Stop all running instances.")
let verboseOption = BoolOption(shortFlag: "v", longFlag: "verbose", helpMessage: "Verbose mode.")
let helpOption = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Prints a help message.")

let cli = CommandLineKit.CommandLine()
cli.addOptions(openOption, stopOption, verboseOption, helpOption)

do {
    try cli.parse(strict: true)
}
catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

if helpOption.value {
    cli.printUsage()
    exit(-1)
}

Logger.logMode = .commandLine
Logger.logLevel = verboseOption.value ? .debug : .info

do {
    let notebooks = try JupyterManager.shared.listNotebooks()
    
    guard !notebooks.isEmpty else {
        Logger.log(warning: "No Jupyter Notebook instances running.")
        exit(0)
    }
    
    Logger.log(important: "Jupyter Notebooks (\(notebooks.count))")
    
    for notebook in notebooks {
        Logger.log(success: "Notebook “\(notebook.identifier)”")
        Logger.log(info: "Directory: \(notebook.notebookDirectory.path)")
        Logger.log(info: "URL: \(notebook.url.absoluteURL)")
        Logger.log(info: "Port: \(notebook.port)")
        Logger.log(info: "Secure: \(notebook.secure)")
        Logger.log(info: "Token: \(notebook.token)")
        
        if openOption.value {
            notebook.open()
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
    Logger.log(error: error)
}

