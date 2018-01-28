//
//  AppDelegate.swift
//  Jupyter
//
//  Created by Pedro José Pereira Vieito on 10/12/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Cocoa
import JupyterKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        self.openDocument(self)
    }
    
    @IBAction func openDocument(_ sender: Any?) {
        
        do {
            try JupyterManager.shared.openNotebook()
        }
        catch {
            print("[x] \(error)")
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        
        do {
            try JupyterManager.shared.stopNotebooks()
            print("[ ] Jupyter has been terminated.")
        }
        catch {
            print("[x] \(error)")
        }
    }
}
