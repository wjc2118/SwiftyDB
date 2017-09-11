//
//  SQLGenerator.swift
//  SwiftyDB
//
//  Created by y7 on 2017/9/7.
//  Copyright © 2017年 y7. All rights reserved.
//

import Foundation

struct SQLGenerator {
    
    static func create(for value: Storable) -> String {
        // CREATE TABLE IF NOT EXISTS tab(id INTEGER NOT NULL, name TEXT, bool INTEGER, date BLOB, PRIMARY KEY (id))
        var sql = "CREATE TABLE IF NOT EXISTS \(type(of: value)) ("
        sql += _createProperty(for: value)
        if let primaryKey = value.primaryKey {
            sql += ", PRIMARY KEY (\(primaryKey))"
        }
        sql += ")"
        return sql
    }
    
    static func insert(for value: Storable, replace: Bool = true) -> (String, [String: SQLiteValue?]) {
        // INSERT OR REPLACE INTO tab VALUES (:id,:name,:bool,:date)
        var sql = "INSERT OR \(replace ? "REPLACE" : "ABORT") INTO \(type(of: value)) VALUES ("
        let (s, v) = _insertProperty(for: value)
        sql += s
        sql += ")"
        return (sql, v)
    }
    
    static func delete(for type: Storable.Type, filter: Filter?) -> String {
        return "DELETE FROM \(type)" + (filter?.toSQL() ?? "")
    }
    
    static func select(for type: Storable.Type) -> String {
        return "SELECT * FROM \(type)"
    }
    
}

extension SQLGenerator {
    
    fileprivate static func _createProperty(for value: Storable) -> String {
        var columns = [String]()
        let infos = PropertyInfo.propertyInfo(for: value)
        for info in infos {
            var column = "\(info.name) \(SQLiteType(type: info.type).rawValue)"
            if !info.isOptional {
                column += " NOT NULL"
            }
            columns.append(column)
        }
        return columns.joined(separator: ", ")
    }
    
    fileprivate static func _insertProperty(for value: Storable) -> (String, [String: SQLiteValue?]) {
        
        var columns = [String]()
        var values = [String: SQLiteValue?]()
        let infos = PropertyInfo.propertyInfo(for: value)
        for info in infos {
            columns.append(":\(info.name)")
            values[info.name] = info.value
        }
        return (columns.joined(separator: ", "), values)
    }
    
//    fileprivate static func _delete
}















