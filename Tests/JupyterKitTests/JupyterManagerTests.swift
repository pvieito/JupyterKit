//
//  JupyterManagerTests.swift
//  JupyterKitTests
//
//  Created by Pedro José Pereira Vieito on 22/11/2019.
//  Copyright © 2019 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import FoundationKit
import XCTest
@testable import JupyterKit

class TabulaKitTests: XCTestCase {
    func testJupyterManager() throws {
        if let pythonProcess = try? JupyterManager.getPythonProcess() {
            pythonProcess.arguments = ["-m", "jupyter", "notebook", "list", "--json"]
            if let _ = try? pythonProcess.runAndGetOutputString() {
                let _ = try JupyterManager.listNotebookServers()
                return
            }
        }
        
        XCTAssertThrowsError(try JupyterManager.listNotebookServers())
    }
}
