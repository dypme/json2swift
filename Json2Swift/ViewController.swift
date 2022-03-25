//
//  ViewController.swift
//  Json2Swift
//
//  Created by Crocodic-MBP2017 on 23/09/21.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var jsonFormatParserBtn: NSPopUpButton!
    @IBOutlet weak var jsonView: NSTextView!
    @IBOutlet weak var errorLabel: NSTextField!
    @IBOutlet weak var exampleBtn: NSButton!
    @IBOutlet weak var resultView: NSTextView!
    @IBOutlet weak var copyResultBtn: NSButton!
    
    let manager = JsonManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupJsonView()
        setupResultView()
        setupMethod()
        
        setExample()
    }

    func setupJsonView() {
        jsonView.isAutomaticQuoteSubstitutionEnabled = false
        jsonView.isAutomaticDataDetectionEnabled = false
        jsonView.isAutomaticLinkDetectionEnabled = false
        jsonView.isAutomaticTextCompletionEnabled = false
        jsonView.isAutomaticTextReplacementEnabled = false
        jsonView.isAutomaticDashSubstitutionEnabled = false
        jsonView.isAutomaticSpellingCorrectionEnabled = false
        
        jsonView.font = NSFont.systemFont(ofSize: 15)
    }
    
    func setupResultView() {
        resultView.isAutomaticQuoteSubstitutionEnabled = false
        resultView.isAutomaticDataDetectionEnabled = false
        resultView.isAutomaticLinkDetectionEnabled = false
        resultView.isAutomaticTextCompletionEnabled = false
        resultView.isAutomaticTextReplacementEnabled = false
        resultView.isAutomaticDashSubstitutionEnabled = false
        resultView.isAutomaticSpellingCorrectionEnabled = false
        
        resultView.font = NSFont.systemFont(ofSize: 15)
    }
    
    func setupMethod() {
        jsonView.delegate = self
        exampleBtn.target = self
        exampleBtn.action = #selector(setExample)
        copyResultBtn.target = self
        copyResultBtn.action = #selector(copyResult)
        jsonFormatParserBtn.target = self
        jsonFormatParserBtn.action = #selector(updateJsonResult)
    }
    
    // MARK: Action
    @objc func setExample() {
        guard let url = Bundle.main.url(forResource: "sample", withExtension: "json") else { return }
        do {
            let jsonString = try String(contentsOf: url)
            jsonView.string = jsonString
        } catch {
            print("Error:", error.localizedDescription)
        }
        updateJsonResult()
    }
    
    @objc func copyResult() {
        let psb = NSPasteboard.general
        psb.clearContents()
        psb.setString(resultView.string, forType: .string)
        alertView(message: "Successfully copied to clipboard")
    }
    
    @objc func openKofi() {
        let url = "https://ko-fi.com/dypme"
        NSWorkspace.shared.open(URL(string: url)!)
    }
    
    @objc func openGithub() {
        let url = "https://github.com/dypme/json2swift"
        NSWorkspace.shared.open(URL(string: url)!)
    }
    
    @objc func updateJsonResult() {
        let jsonString = jsonView.string
        let format = jsonFormatParserBtn.selectedItem?.identifier?.rawValue ?? ""
        do {
            guard let data = jsonString.data(using: .utf8) else { return }
            guard let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
                return
            }
            
            let object = ClassObject(data: dict)
            resultView.string = manager.parseJson(object: object, format: JsonFormatType(rawValue: format)!)
            errorLabel.isHidden = true
        } catch {
            errorLabel.stringValue = error.localizedDescription
            errorLabel.isHidden = false
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

extension ViewController: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        updateJsonResult()
    }
}

extension Data {
    var prettyPrintedJSONString: String? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        return prettyPrintedString as String
    }
}
