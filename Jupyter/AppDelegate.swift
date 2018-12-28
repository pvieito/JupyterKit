//
//  AppDelegate.swift
//  Jupyter
//
//  Created by Pedro José Pereira Vieito on 10/12/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Cocoa
import LoggerKit
import JupyterKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.openDocument(self)
    }
    
    @IBAction func openDocument(_ sender: Any?) {
        DispatchQueue.global(qos: .background).async {
            do {
                let notebookServers = try JupyterManager.listNotebookServers()
                if let notebookServer = notebookServers.first {
                    try notebookServer.open()
                }
                else {
                    try JupyterManager.launchNotebookServer(launchBrowser: true)
                }
            }
            catch {
                Logger.log(error: error)
                NSApplication.shared.presentError(error)
            }
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        do {
            try JupyterManager.stopNotebookServers()
            Logger.log(info: "Jupyter has been terminated.")
        }
        catch {
            Logger.log(error: error)
            NSApplication.shared.presentError(error)
        }
    }
}
