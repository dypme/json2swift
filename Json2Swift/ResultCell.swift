//
//  ResultCell.swift
//  Json2Swift
//
//  Created by Macintosh on 26/03/22.
//

import Cocoa

class ResultCell: NSTableCellView {

    @IBOutlet weak var containerView: NSView!
    @IBOutlet weak var resultLabel: NSTextField!
    @IBOutlet weak var copyBtn: NSButton!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        
        containerView.wantsLayer = true
        containerView.layer?.cornerRadius = 5
        containerView.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        resultLabel.font = NSFont.systemFont(ofSize: 14)
        
        copyBtn.target = self
        copyBtn.action = #selector(copyResult)
    }
            
    @objc func copyResult() {
        let psb = NSPasteboard.general
        psb.clearContents()
        psb.setString(resultLabel.stringValue, forType: .string)
    }
    
}
