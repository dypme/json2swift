//
//  CodableManager.swift
//  Json2Swift
//
//  Created by Crocodic-MBP2017 on 27/09/21.
//

import Foundation

class CodableManager {
    func parse(className: String, data: [String : Any]) -> String {
        let result = """
struct \(className): Codable {
\(parseProperties(data))

\(codingKeys(data))

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
            return "    let \(name): Bool?"
        case .integer:
            return "    let \(name): Int?"
        case .double:
            return "    let \(name): Double?"
        case .object:
            return "    let \(name): \(cName)?"
        case .array:
            if let arrayValue = (value as? [Any])?.first {
                let arrayValueType = JsonType(arrayValue)
                if let _ = arrayValue as? [String : Any] {
                    return "    let \(name): [\(cName)]?"
                } else if let typeData = arrayValueType.typeData {
                    return "    let \(name): [\(typeData)]?"
                }
            }
            return "    let \(name): [Any]?"
        default:
            return "    let \(name): String?"
        }
    }
    
    private func codingKeys(_ data: [String : Any]) -> String {
        var keys = ""
        data.forEach { (key, value) in
            let propertyName = JsonManager.propertyName(fromKey: key)
            keys.append("       case \(propertyName) = \"\(key)\"")
            keys.append("\n")
        }
        return """
    enum CodingKeys: String, CodingKey {
\(keys)
    }
"""
    }
    
    private func parser(_ data: [String : Any]) -> String {
        var propertiesParserResult = ""
        data.forEach { (key, value) in
            propertiesParserResult.append(formatPropertyParser(key: key, value: value))
            propertiesParserResult.append("\n")
        }
        return """
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
\(propertiesParserResult)
    }
"""
    }
    
    private func formatPropertyParser(key: String, value: Any) -> String {
        let name = JsonManager.propertyName(fromKey: key)
        let cName = JsonManager.className(fromKey: key)
        
        let type = JsonType(value)
        switch type {
        case .bool, .integer, .double, .string:
            return "        \(name) = try values.decodeIfPresent(\(type.typeData!).self, forKey: .\(name))"
        case .object:
            return "        \(name) = try values.decodeIfPresent(\(cName).self, forKey: .\(name))"
        case .array:
            if let arrayValue = (value as? [Any])?.first {
                let arrayValueType = JsonType(arrayValue)
                if let _ = arrayValue as? [String : Any] {
                    return "        \(name) = try values.decodeIfPresent([\(cName)].self, forKey: .\(name))"
                } else if let typeData = arrayValueType.typeData {
                    return "        \(name) = try values.decodeIfPresent([\(typeData)].self, forKey: .\(name))"
                }
            }
            return "        \(name) = try values.decodeIfPresent([Any].self, forKey: .\(name))"
        }
    }
}
