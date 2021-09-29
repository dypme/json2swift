//
//  ViewController.swift
//  Json2Swift
//
//  Created by Crocodic-MBP2017 on 23/09/21.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var kofiBtn: NSButton!
    @IBOutlet weak var githubBtn: NSButton!
    @IBOutlet weak var rootClassNameFld: NSTextField!
    @IBOutlet weak var saveRootClassNameBtn: NSButton!
    @IBOutlet weak var jsonFormatParserBtn: NSPopUpButton!
    @IBOutlet weak var jsonView: NSTextView!
    @IBOutlet weak var resultView: NSTextView!
    @IBOutlet weak var convertBtn: NSButton!
    
    let manager = JsonManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        githubBtn.bezelStyle = .texturedSquare
        githubBtn.isBordered = false
        githubBtn.wantsLayer = true
        githubBtn.layer?.backgroundColor = NSColor.white.cgColor
        githubBtn.layer?.cornerRadius = 25
        githubBtn.layer?.masksToBounds = true
        
        kofiBtn.bezelStyle = .texturedSquare
        kofiBtn.isBordered = false
        kofiBtn.wantsLayer = true
        kofiBtn.layer?.backgroundColor = NSColor(red: 151/255, green: 128/255, blue: 183/255, alpha: 1).cgColor
        kofiBtn.layer?.cornerRadius = 25
        kofiBtn.layer?.masksToBounds = true
        kofiBtn.isHidden = true
        
        rootClassNameFld.stringValue = JsonManager.rootClassName ?? ""
        
        kofiBtn.target = self
        kofiBtn.action = #selector(openKofi)
        githubBtn.target = self
        githubBtn.action = #selector(openGithub)
        saveRootClassNameBtn.target = self
        saveRootClassNameBtn.action = #selector(saveRootClassName)
        convertBtn.target = self
        convertBtn.action = #selector(convertJson)
        
        guard let url = Bundle.main.url(forResource: "sample", withExtension: "json") else { return }
        do {
            let jsonString = try String(contentsOf: url)
            jsonView.string = jsonString
        } catch {
            print("Error:", error.localizedDescription)
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @objc func openKofi() {
        let url = "https://ko-fi.com/dypme"
        NSWorkspace.shared.open(URL(string: url)!)
    }
    
    @objc func openGithub() {
        let url = "https://github.com/dypme/json2swift"
        NSWorkspace.shared.open(URL(string: url)!)
    }
    
    @objc func saveRootClassName() {
        manager.saveRootClassName(rootClassNameFld.stringValue)
    }
    
    @objc func convertJson() {
        let jsonString = jsonView.string
        let format = jsonFormatParserBtn.selectedItem?.identifier?.rawValue ?? ""
        if jsonString.isEmpty {
            alertView(message: "Please insert JSON")
            return
        }
        
        do {
            guard let data = jsonString.data(using: .utf8) else { return }
            guard let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
                return
            }
            
            let object = ClassObject(data: dict)
            resultView.string = manager.parseJson(object: object, format: JsonFormatType(rawValue: format)!)
        } catch {
            print("Error:", error.localizedDescription)
            self.alertView(message: error.localizedDescription)
        }
    }
    
    func alertView(message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
