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
        var result = ""
        data.forEach { (key, value) in
            result.append(formatProperty(key: key, value: value))
            result.append("\n")
        }
        return result
    }
    
    private func formatProperty(key: String, value: Any) -> String {
        let name = JsonManager.propertyName(fromKey: key)
        let cName = JsonManager.className(fromKey: key)
        
        let type = JsonType(value)
        switch type {
        case .bool:
            return "    var \(name): Bool = false"
        case .integer:
            return "    var \(name): Int = 0"
        case .double:
            return "    var \(name): Double = 0.0"
        case .object:
            return "    var \(name): \(cName)!"
        case .array:
            if let arrayValue = (value as? [Any])?.first {
                let arrayValueType = JsonType(arrayValue)
                if let _ = arrayValue as? [String : Any] {
                    return "    var \(name): [\(cName)] = [\(cName)]()"
                } else if let typeData = arrayValueType.typeData {
                    return "    var \(name): [\(typeData)] = [\(typeData)]()"
                }
            }
            return "    var \(name): [Any]!"
        default:
            return "    var \(name): String = \"\""
        }
    }
    
    private func parser(_ data: [String : Any]) -> String {
        var propertiesParserResult = ""
        data.forEach { (key, value) in
            propertiesParserResult.append(formatPropertyParser(key: key, value: value))
            propertiesParserResult.append("\n")
        }
        return """
    init(fromJson json: JSON) {
\(propertiesParserResult)
    }
"""
    }
    
    private func formatPropertyParser(key: String, value: Any) -> String {
        let name = JsonManager.propertyName(fromKey: key)
        let cName = JsonManager.className(fromKey: key)
        
        let type = JsonType(value)
        switch type {
        case .bool:
            return "        \(name) = json[\"\(key)\"].boolValue"
        case .integer:
            return "        \(name) = json[\"\(key)\"].intValue"
        case .double:
            return "        \(name) = json[\"\(key)\"].doubleValue"
        case .object:
            return "        \(name) = \(cName)(fromJson: json[\"\(key)\"])"
        case .array:
            if let arrayValue = (value as? [Any])?.first {
                let arrayValueType = JsonType(arrayValue)
                if let _ = arrayValue as? [String : Any] {
                    let arrayResult = """
        let \(name)Array = json[\"\(key)\"].arrayValue
        for \(name)Json in \(name)Array {
            let value = \(cName)(fromJson: \(name)Json)
            \(name).append(value)
        }
"""
                    return arrayResult
                } else if let typeData = arrayValueType.typeData {
                    return "        \(name) = json[\"\(key)\"].arrayValue.map({ $0.\(typeData.lowercased())Value })"
                }
            }
            return "        \(name) = json[\"\(key)\"].arrayObject"
        default:
            return "        \(name) = json[\"\(key)\"].stringValue"
        }
    }
}
