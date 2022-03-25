//
//  SwiftyManager.swift
//  Json2Swift
//
//  Created by Crocodic-MBP2017 on 27/09/21.
//

import Foundation

class SwiftyManager {
    func parse(className: String, data: [String : Any]) -> String {
        let result = """
class \(className): NSObject {
\(parseProperties(data))

\(parser(data))
}
"""
        return result
    }
    
    private func parseProperties(_ data: [String : Any]) -> String {
        let result = data.sorted(by: { $0.key.lowercased() < $1.key.lowercased() }).map({ formatProperty(key: $0.key, value: $0.value) }).joined(separator: "\n")
        return result
    }
    
    private func formatProperty(key: String, value: Any) -> String {
        let name = JsonManager.propertyName(fromKey: key)
        let cName = JsonManager.className(fromKey: key)
        
        let type = JsonType(value)
        switch type {
        case .bool:
            return "\tvar \(name): Bool = false"
        case .integer:
            return "\tvar \(name): Int = 0"
        case .double:
            return "\tvar \(name): Double = 0.0"
        case .object:
            return "\tvar \(name): \(cName)!"
        case .array:
            if let arrayValue = (value as? [Any])?.first {
                let arrayValueType = JsonType(arrayValue)
                if let _ = arrayValue as? [String : Any] {
                    return "\tvar \(name): [\(cName)] = [\(cName)]()"
                } else if let typeData = arrayValueType.typeData {
                    return "\tvar \(name): [\(typeData)] = [\(typeData)]()"
                }
            }
            return "\tvar \(name): [Any]!"
        default:
            return "\tvar \(name): String = \"\""
        }
    }
    
    private func parser(_ data: [String : Any]) -> String {
        let propertiesParserResult = data.sorted(by: { $0.key.lowercased() < $1.key.lowercased() }).map({ formatPropertyParser(key: $0.key, value: $0.value) }).joined(separator: "\n")
        return """
\tinit(fromJson json: JSON) {
\(propertiesParserResult)
\t}
"""
    }
    
    private func formatPropertyParser(key: String, value: Any) -> String {
        let name = JsonManager.propertyName(fromKey: key)
        let cName = JsonManager.className(fromKey: key)
        
        let type = JsonType(value)
        switch type {
        case .bool:
            return "\t\t\(name) = json[\"\(key)\"].boolValue"
        case .integer:
            return "\t\t\(name) = json[\"\(key)\"].intValue"
        case .double:
            return "\t\t\(name) = json[\"\(key)\"].doubleValue"
        case .object:
            return "\t\t\(name) = \(cName)(fromJson: json[\"\(key)\"])"
        case .array:
            if let arrayValue = (value as? [Any])?.first {
                let arrayValueType = JsonType(arrayValue)
                if let _ = arrayValue as? [String : Any] {
                    return "\t\t\(name) = json[\"\(key)\"].arrayValue.map({ \(cName)(fromJson: $0) })"
                } else if let typeData = arrayValueType.typeData {
                    return "\t\t\(name) = json[\"\(key)\"].arrayValue.map({ $0.\(typeData.lowercased())Value })"
                }
            }
            return "\t\t\(name) = json[\"\(key)\"].arrayObject"
        default:
            return "\t\t\(name) = json[\"\(key)\"].stringValue"
        }
    }
}
