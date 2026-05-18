//
//  Clipboard.swift
//  linkedinME
//
//  Created by John Demirci on 3/28/26.
//

import UIKit

actor Clipboard {
    enum Failure: Error {
        case noTextInClipboard
    }

    private let pasteboard: UIPasteboard

    init(pasteboard: UIPasteboard = .general) {
        self.pasteboard = pasteboard
    }

    func copy(_ text: String) {
        pasteboard.string = text
    }

    func paste() throws -> String {
        guard let str = pasteboard.string else {
            throw Failure.noTextInClipboard
        }

        return str
    }
}
