//
//  PropertyItem.swift
//  SwiftyDB
//
//  Created by y7 on 2017/9/7.
//  Copyright © 2017年 y7. All rights reserved.
//

import Foundation

struct PropertyInfo {
    
    let name: String
    let value: SQLiteValue?
    let type: SQLiteValue.Type //Any.Type
    let isOptional: Bool
    
    //    private let _property: Mirror.Child
    
    init(property: Mirror.Child) {
        //        _property = property
        name = property.label!
        
        value = property.value as? SQLiteValue
        
        let m = Mirror(reflecting: property.value)
        type = PropertyInfo.type(for: m) //m.subjectType as! SQLiteValue.Type
        isOptional = m.displayStyle == .optional
        
        
    }
    
    
}

extension PropertyInfo {
    
    static func propertyInfo(for value: Storable) -> [PropertyInfo] {
        return propertyInfo(for: Mirror(reflecting: value))
    }
    
    private static func propertyInfo(for mirror: Mirror) -> [PropertyInfo] {
        var infos = [PropertyInfo]()
        if let superMirror = mirror.superclassMirror, superMirror.subjectType is Storable.Type {
            infos += propertyInfo(for: superMirror)
        }
        for child in mirror.children {
            if child.label == nil {
                continue
            }
            infos.append(PropertyInfo(property: child))
        }
        return infos
    }
    
    fileprivate static func type(for mirror: Mirror) -> SQLiteValue.Type {
        switch mirror.subjectType {
            
        case is Optional<String>.Type:      return String.self
        case is Optional<Character>.Type:   return Character.self
            
        case is Optional<Date>.Type:      return Date.self
        case is Optional<Data>.Type:      return Data.self
            
        case is Optional<Bool>.Type:        return Bool.self
            
        case is Optional<Int>.Type:         return Int.self
        case is Optional<UInt>.Type:        return UInt.self
            
        case is Optional<Float>.Type:       return Float.self
        case is Optional<Double>.Type:      return Double.self
        default:
            return mirror.subjectType as! SQLiteValue.Type
        }
    }
}



