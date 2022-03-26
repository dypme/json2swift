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
    
    func parseJson(object: ClassObject, format: JsonFormatType) -> [String] {
        let results = parseJsonSeparated(object: object, format: format)
        return results
    }
    
    func parseJsonString(object: ClassObject, format: JsonFormatType) -> String {
        let results = parseJsonSeparated(object: object, format: format)
        var resultStr = results.map({ $0.replacingOccurrences(of: "import SwiftyJSON", with: "").trimmingCharacters(in: .whitespacesAndNewlines) }).joined(separator: "\n\n")
        if format == .swiftyJson {
           resultStr = "import SwiftyJSON\n\n" + resultStr
        }
        return resultStr
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
    
    static func className(fromKey key: String) -> String {
        key.capitalized.replacingOccurrences(of: "_", with: "")
    }
    
    static func propertyName(fromKey key: String) -> String {
        var name = key.capitalized.replacingOccurrences(of: "_", with: "")
        if name.isEmpty {
            return "_"
        }
        name.replaceSubrange(...name.startIndex, with: name.first?.lowercased() ?? "")
        return name
    }
}
