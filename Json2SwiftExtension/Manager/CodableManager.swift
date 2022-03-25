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
        let result = data.sorted(by: { $0.key.lowercased() < $1.key.lowercased() }).map({ formatProperty(key: $0.key, value: $0.value) }).joined(separator: "\n")
        return result
    }
    
    private func formatProperty(key: String, value: Any) -> String {
        let name = JsonManager.propertyName(fromKey: key)
        let cName = JsonManager.className(fromKey: key)
        
        let type = JsonType(value)
        switch type {
        case .bool:
            return "\tlet \(name): Bool?"
        case .integer:
            return "\tlet \(name): Int?"
        case .double:
            return "\tlet \(name): Double?"
        case .object:
            return "\tlet \(name): \(cName)?"
        case .array:
            if let arrayValue = (value as? [Any])?.first {
                let arrayValueType = JsonType(arrayValue)
                if let _ = arrayValue as? [String : Any] {
                    return "\tlet \(name): [\(cName)]?"
                } else if let typeData = arrayValueType.typeData {
                    return "\tlet \(name): [\(typeData)]?"
                }
            }
            return "\tlet \(name): [Any]?"
        default:
            return "\tlet \(name): String?"
        }
    }
    
    private func codingKeys(_ data: [String : Any]) -> String {
        var keys = [String]()
        data.forEach { (key, value) in
            let propertyName = JsonManager.propertyName(fromKey: key)
            keys.append("\t\tcase \(propertyName) = \"\(key)\"")
        }
        return """
\tenum CodingKeys: String, CodingKey {
\(keys.joined(separator: "\n"))
\t}
"""
    }
    
    private func parser(_ data: [String : Any]) -> String {
        var propertiesParserResult = [String]()
        data.forEach { (key, value) in
            propertiesParserResult.append(formatPropertyParser(key: key, value: value))
        }
        return """
\tinit(from decoder: Decoder) throws {
\t\tlet values = try decoder.container(keyedBy: CodingKeys.self)
\(propertiesParserResult.joined(separator: "\n"))
\t}
"""
    }
    
    private func formatPropertyParser(key: String, value: Any) -> String {
        let name = JsonManager.propertyName(fromKey: key)
        let cName = JsonManager.className(fromKey: key)
        
        let type = JsonType(value)
        switch type {
        case .bool, .integer, .double, .string:
            return "\t\t\(name) = try values.decodeIfPresent(\(type.typeData!).self, forKey: .\(name))"
        case .object:
            return "\t\t\(name) = try values.decodeIfPresent(\(cName).self, forKey: .\(name))"
        case .array:
            if let arrayValue = (value as? [Any])?.first {
                let arrayValueType = JsonType(arrayValue)
                if let _ = arrayValue as? [String : Any] {
                    return "\t\t\(name) = try values.decodeIfPresent([\(cName)].self, forKey: .\(name))"
                } else if let typeData = arrayValueType.typeData {
                    return "\t\t\(name) = try values.decodeIfPresent([\(typeData)].self, forKey: .\(name))"
                }
            }
            return "\t\(name) = try values.decodeIfPresent([Any].self, forKey: .\(name))"
        }
    }
}
