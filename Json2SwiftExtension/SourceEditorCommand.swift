//
//  SourceEditorCommand.swift
//  Json2SwiftExtension
//
//  Created by Crocodic-MBP2017 on 23/09/21.
//

import Foundation
import XcodeKit
import AppKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    var buffer: XCSourceTextBuffer!
    
    let manager = JsonManager()
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        self.buffer = invocation.buffer
        
        let jsonString = NSPasteboard.general.string(forType: .string)
        if let data = jsonString?.data(using: .utf8) {
            do {
                guard let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
                    completionHandler(nil)
                    return
                }
                let object = ClassObject(data: dict)
                output(object: object, identifier: invocation.commandIdentifier)
            } catch {
                let errorResult = "// \(error.localizedDescription)\n\(jsonString ?? "")"
                outputResult(text: errorResult)
            }
        }
        
        completionHandler(nil)
    }
    
    func output(object: ClassObject, identifier: String) {
        let formatType = JsonFormatType(rawValue: identifier)!
        let result = manager.parseJsonString(object: object, format: formatType)
        outputResult(text: result)
    }
    
    func outputResult(text: String) {
        guard let range = self.buffer.selections.firstObject as? XCSourceTextRange else { return }
        let startLine = range.start.line
        var endLine = range.end.line - range.start.line + 1
        
        let totalLines = self.buffer.lines.count
        if (startLine + endLine) > totalLines {
           endLine = totalLines - startLine
        }
        
        self.buffer.lines.removeObjects(in: NSRange(location: startLine, length: endLine))
        self.buffer.lines.insert(text, at: range.start.line)
        
        let selection = XCSourceTextRange(start: XCSourceTextPosition(line: 0, column: 0), end: XCSourceTextPosition(line: 0, column: 0))
        self.buffer.selections.removeAllObjects()
        self.buffer.selections.insert(selection, at: 0)
    }
    
    
}
