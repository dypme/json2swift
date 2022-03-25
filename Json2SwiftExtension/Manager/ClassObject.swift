//
//  JsonObject.swift
//  Json2Swift
//
//  Created by Crocodic-MBP2017 on 25/09/21.
//

import Foundation

enum JsonType {
    case bool
    case integer
    case double
    case string
    case array
    case object
    
    init(_ value: Any) {
        if let number = value as? NSNumber {
            if number.isBool {
                self = .bool
            } else {
                if String(describing: value).contains(".") {
                    self = .double
                } else {
                    self = .integer
                }
            }
        } else if value is [Any] {
            self = .array
        } else if value is [String : Any] {
            self = .object
        } else {
            self = .string
        }
    }
    
    var typeData: String? {
        switch self {
        case .bool:
            return "Bool"
        case .integer:
            return "Int"
        case .double:
            return "Double"
        case .string:
            return "String"
        default:
            return nil
        }
    }
}

class ClassObject {
    private(set) var name: String = ""
    private(set) var data = [String : Any]()
    
    init(data: [String : Any]) {
        self.name = "Datum"
        self.data = data
    }
    
    init(className: String, data: [String : Any]) {
        self.name = className
        self.data = data
    }
    
    // Child class is type array and object and make it create new class
    var childs: [ClassObject] {
        return data.compactMap { (key, value) -> ClassObject? in
            let name = key.capitalized.replacingOccurrences(of: "_", with: "")
            var childValue: [String : Any]?
            if let dictValue = value as? [String : Any] {
                childValue = dictValue
            } else if let arrayValue = value as? [Any], let firstValue = arrayValue.first as? [String : Any] {
                childValue = firstValue
            }
            
            if let child = childValue {
                return ClassObject(className: name, data: child)
            }
            return nil
        }
    }
}

private let trueNumber = NSNumber(value: true)
private let falseNumber = NSNumber(value: false)
private let trueObjCType = String(cString: trueNumber.objCType)
private let falseObjCType = String(cString: falseNumber.objCType)

extension NSNumber {
    fileprivate var isBool: Bool {
        let objCType = String(cString: self.objCType)
        if (self.compare(trueNumber) == .orderedSame && objCType == trueObjCType) || (self.compare(falseNumber) == .orderedSame && objCType == falseObjCType) {
            return true
        } else {
            return false
        }
    }
}
