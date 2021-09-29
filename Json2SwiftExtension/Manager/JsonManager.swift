//
//  JsonManager.swift
//  Json2Swift
//
//  Created by Crocodic-MBP2017 on 25/09/21.
//

import Foundation

enum JsonFormatType: String {
    case swiftyJson = "Json2Swift.SwiftyJSON"
    case codable = "Json2Swift.Codable"
}

class JsonManager {
    private let swifty = SwiftyManager()
    private let codable = CodableManager()
    
    func parseJson(object: ClassObject, format: JsonFormatType) -> String {
        let results = parseJsonSeparated(object: object, format: format)
        return results.joined(separator: "\n\n")
    }
    
    func parseJsonSeparated(object: ClassObject, format: JsonFormatType) -> [String] {
        var results = [String]()
        
        switch format {
        case .swiftyJson:
            results.append(swifty.parse(className: object.name, data: object.data))
        default:
            results.append(codable.parse(className: object.name, data: object.data))
        }
        
        object.childs.forEach { (child) in
            results.append(contentsOf: parseJsonSeparated(object: child, format: format))
        }
        return results
    }
    
    static var rootClassName: String? {
        let superclass = UserDefaults.standard.string(forKey: "RootClassName")
            
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = dir.appending("RootClassName.txt")
        do {
            let name = try String(contentsOfFile: path, encoding: .utf8)
            return name.isEmpty ? superclass : name
        } catch {
            print("Error read superclass name from file", error.localizedDescription)
            return superclass
        }
    }
    
    func saveRootClassName(_ name: String) {
        UserDefaults.standard.setValue(name, forKey: "RootClassName")
        
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documents = dir.replacingOccurrences(of: "/Documents", with: "/Library/Containers/com.dypme.Json2Swift.Json2SwiftExtension/Data/Documents")
        let path = documents.appending("RootClassName.txt")
        do {
            try name.write(toFile: path, atomically: false, encoding: .utf8)
        } catch let error {
            print("Error saving name to file: \(error.localizedDescription)")
        }
    }
    
    static func className(fromKey key: String) -> String {
        key.capitalized.replacingOccurrences(of: "_", with: "")
    }
    
    static func propertyName(fromKey key: String) -> String {
        var name = key.capitalized.replacingOccurrences(of: "_", with: "")
        name.replaceSubrange(...name.startIndex, with: name.first?.lowercased() ?? "")
        return name
    }
}
