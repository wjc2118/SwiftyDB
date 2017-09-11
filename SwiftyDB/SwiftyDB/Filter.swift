//
//  Filter.swift
//  SwiftyDB
//
//  Created by y7 on 2017/9/8.
//  Copyright © 2017年 y7. All rights reserved.
//

import Foundation

//enum Filter {
//    
//    case equal(String, SQLiteValue?)
//    case notEqual(String, SQLiteValue?)
//    case less(String, SQLiteValue)
//    case greater(String, SQLiteValue)
//    case lessOrEqual(String, SQLiteValue)
//    case greaterOrEqual(String, SQLiteValue)
//    
//    case like(String, SQLiteValue)
//    case notLike(String, SQLiteValue)
//    
//    case `in`(String, (SQLiteValue, SQLiteValue))
//    case notIn(String, (SQLiteValue, SQLiteValue))
//    
//    case none
//    
//    fileprivate static var sql: String = ""
//}

struct Filter {
    
    static func &&(_ l: Filter, _ r: inout Filter) -> Filter {
        return l.and(&r)
    }
    
    static func ||(_ l: Filter, _ r: inout Filter) -> Filter {
        return l.or(&r)
    }
    
    fileprivate enum Relationship: String {
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
    
    
    fileprivate let _name: String
    fileprivate let _value: Any?
    fileprivate let _relationship: Relationship
    
    fileprivate var _preSQL: String = ""
    
    fileprivate init(name: String, value: Any?, relationship: Relationship) {
        _name = name
        _value = value
        _relationship = relationship
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
    
    func and(_ other: inout Filter) -> Filter {
        other._preSQL = self.toSQL() + " AND "
        return other
    }
    
    func or(_ other: inout Filter) -> Filter {
        other._preSQL = self.toSQL() + " OR "
        return other
    }
    
    func toSQL() -> String {
        var sql = _preSQL.isEmpty ? " WHERE \(_name) " : _preSQL + "\(_name) "
        switch _relationship {
        case .equal, .notEqual:
            if let val = _value as? SQLiteValue {
                sql += _relationship.rawValue + " \(val.toSQL())"
            } else {
                sql += "IS " + (_relationship == .notEqual ? "NOT " : "") + "NULL"
            }
        case .less, .greater, .lessOrEqual, .greaterOrEqual:
            sql += _relationship.rawValue + " \((_value as! SQLiteValue).toSQL())"
        case .like, .notLike:
            sql += _relationship.rawValue + " '\(_value as! String)'"
        case .in, .notIn:
            let range = _value as! [SQLiteValue]
            let para = range.map({ (val) -> String in
                return val.toSQL()
            }).joined(separator: ", ")
            sql += _relationship.rawValue + " (" + para + ")"
        }
        return sql
    }
}




