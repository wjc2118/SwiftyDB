//
//  SwiftyDB.swift
//  SwiftyDB
//
//  Created by y7 on 2017/9/6.
//  Copyright © 2017年 y7. All rights reserved.
//

import Foundation

protocol Storable {
    var primaryKey: String? { get }
}

extension Storable {
    var primaryKey: String? {
        return nil
    }
}

class SwiftyDB {
    
    fileprivate let databaseQueue: DatabaseQueue
    
    fileprivate var existTables = Set<String>()
    
    init(path: String) {
        databaseQueue = DatabaseQueue(path: path)
    }
    
}

extension SwiftyDB {
    
    func createTable(_ sql: String) -> Bool {
        var suc = false
        databaseQueue.sync { (db, rollback) in
            suc = db.update(sql)
            if !suc { rollback = true }
        }
        return suc
    }
    
    func insert(_ value: Storable) -> Bool {
        var suc = false
        
        if !tableExists(for: type(of: value)) {
            let sql = SQLGenerator.create(for: value)
            print(sql)
            if !createTable(sql) { return false }
        }
        
        let (sql, parameters) = SQLGenerator.insert(for: value)
        print(sql, parameters)
        databaseQueue.sync { (db, rollback) in
            suc = db.update(sql, parameters)
            if !suc { rollback = true }
        }
        return suc
    }
    
    func delete(_ type: Storable.Type, filter: Filter? = nil) -> Bool {
        var suc = false
        let sql = SQLGenerator.delete(for: type, filter: filter)
        print(sql)
        databaseQueue.sync { (db, rollback) in
            suc = db.update(sql)
            if !suc { rollback = true }
        }
        return suc
    }
    
    func select(_ type: Storable.Type, filter: Filter? = nil) -> ResultSet? {
        var rs: ResultSet? = nil
        let sql = SQLGenerator.select(for: type, filter: filter)
        databaseQueue.sync { (db, rollback) in
            guard let resultSet = db.query(sql) else { rollback = false; return }
            rs = resultSet
        }
        return rs
    }
    
}

extension SwiftyDB {
    
    fileprivate func tableExists(for type: Storable.Type) -> Bool {
        let name = tableName(for: type)
        var exists = existTables.contains(name)
        if exists { return true }
        
        databaseQueue.sync { (db, _) in
            exists = db.contains(table: name)
        }
        
        if exists {
            existTables.insert(name)
        }
        
        return exists
    }
    
    fileprivate func tableName(for type: Storable.Type) -> String {
        return "\(type)"
    }
    
}

















