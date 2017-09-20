//
//  Filter.swift
//  SwiftyDB
//
//  Created by y7 on 2017/9/8.
//  Copyright © 2017年 y7. All rights reserved.
//

import Foundation

struct Filter {
    
    static func &&(l: Filter, r: Filter) -> Filter {
        return l.and(r)
    }
    
    static func ||(l: Filter, r: Filter) -> Filter {
        return l.or(r)
    }
    
    private enum Relationship: String {
        case equal            =    "="
        case notEqual         =    "!="
        case less             =    "<"
        case greater          =    ">"
        case lessOrEqual      =    "<="
        case greaterOrEqual   =    ">="
        
        case like             =    "LIKE"
        case notLike          =    "NOT LIKE"
        
        case `in`             =    "IN"
        case notIn            =    "NOT IN"
    }
    
    
    private let _name: String
    private let _value: Any?
    private let _relationship: Relationship
    
    private var _preSQL: String = ""
    
    private init(name: String, value: Any?, relationship: Relationship, preSQL: String = "") {
        _name = name
        _value = value
        _relationship = relationship
        _preSQL = preSQL
    }
    
}

extension Filter {

    static func equal(_ name: String, _ value: SQLiteValue?) -> Filter {
        return Filter(name: name, value: value, relationship: .equal)
    }
    
    static func notEqual(_ name: String, _ value: SQLiteValue?) -> Filter {
        return Filter(name: name, value: value, relationship: .notEqual)
    }
    
    static func less(_ name: String, _ value: SQLiteValue) -> Filter {
        return Filter(name: name, value: value, relationship: .less)
    }
    
    static func greater(_ name: String, _ value: SQLiteValue) -> Filter  {
        return Filter(name: name, value: value, relationship: .greater)
    }
    
    static func lessOrEqual(_ name: String, _ value: SQLiteValue) -> Filter {
        return Filter(name: name, value: value, relationship: .lessOrEqual)
    }
    
    static func greaterOrEqual(_ name: String, _ value: SQLiteValue) -> Filter {
        return Filter(name: name, value: value, relationship: .greaterOrEqual)
    }
    
    static func like(name: String, pattern: String) -> Filter {
        return Filter(name: name, value: pattern, relationship: .like)
    }
    
    static func notLike(name: String, pattern: String) -> Filter {
        return Filter(name: name, value: pattern, relationship: .notLike)
    }
    
    static func `in`(name: String, range: [SQLiteValue]) -> Filter {
        return Filter(name: name, value: range, relationship: .in)
    }
    
    static func notIn(name: String, range: [SQLiteValue]) -> Filter {
        return Filter(name: name, value: range, relationship: .notIn)
    }
    
    
}

extension Filter {
    
    func and(_ other: Filter) -> Filter {
        return Filter(name: other._name, value: other._value, relationship: other._relationship, preSQL: self.toSQL() + " AND ")
    }
    
    func or(_ other: Filter) -> Filter {
        return Filter(name: other._name, value: other._value, relationship: other._relationship, preSQL: self.toSQL() + " OR ")
    }
    
    func toSQL() -> String {
        var sql = _preSQL.isEmpty ? " WHERE \(_name) " : _preSQL + "\(_name) "
        switch _relationship {
        case .equal, .notEqual:
            if let val = _value as? SQLiteValue {
                sql += _relationship.rawValue + " '\(val.toSQL())'"
            } else {
                sql += "IS " + (_relationship == .notEqual ? "NOT " : "") + "NULL"
            }
        case .less, .greater, .lessOrEqual, .greaterOrEqual:
            sql += _relationship.rawValue + " '\((_value as! SQLiteValue).toSQL())'"
        case .like, .notLike:
            sql += _relationship.rawValue + " '\(_value as! String)'"
        case .in, .notIn:
            let range = _value as! [SQLiteValue]
            let para = range.map{ "'\($0.toSQL())'" }.joined(separator: ", ")
            sql += _relationship.rawValue + " (" + para + ")"
        }
        return sql
    }
}




