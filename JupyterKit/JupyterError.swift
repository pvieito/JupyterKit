//
//  JupyterError.swift
//  JupyterKit
//
//  Created by Pedro José Pereira Vieito on 1/4/18.
//  Copyright © 2018 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

public enum JupyterError: LocalizedError {
    case executableNotAvailable(URL)
    case jupyterError(String)
    case openingNotebookNotSupported
    case noOutput
    
    public var errorDescription: String? {
        switch self {
        case .executableNotAvailable(let url):
            return "Jupyter executable not available at “\(url.path)”."
        case .jupyterError(let errorString):
            return "Jupyter Error: \(errorString)."
        case .openingNotebookNotSupported:
            return "Opening Notebook on browser is not supported."
        case .noOutput:
            return "No output available."
        }
    }
}
