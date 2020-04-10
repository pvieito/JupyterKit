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
        do {
            try JupyterManager.stopNotebookServers()
            try JupyterManager.launchNotebookServer()
            let l1 = try JupyterManager.listNotebookServers()
            
            XCTAssertEqual(l1.count, 1)
            
            try JupyterManager.launchNotebookServer()
            try JupyterManager.launchNotebookServer()
            let l2 = try JupyterManager.listNotebookServers()
            
            XCTAssertEqual(l2.count, 3)
            
            let l2s = l2.last!
            try l2s.stop()
            
            Thread.sleep(forTimeInterval: 1.0)
            
            let l3 = try JupyterManager.listNotebookServers()
            
            let l2Set = Set(l2[0...1].map({ $0.identifier }))
            let l3Set = Set(l3.map({ $0.identifier }))
            
            XCTAssertEqual(l3.count, 2)
            XCTAssertEqual(l3Set, l2Set)
            XCTAssertTrue(l3Set.intersection(Set([l2s.identifier])).isEmpty)
            
            try JupyterManager.stopNotebookServers()
            
            Thread.sleep(forTimeInterval: 1.0)
            
            let l4 = try JupyterManager.listNotebookServers()
            
            XCTAssertEqual(l4.count, 0)
            return
        }
        catch {
            try? JupyterManager.stopNotebookServers()
            throw error
        }
    }
}
