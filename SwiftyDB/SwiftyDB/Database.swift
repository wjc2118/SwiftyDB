//
//  Database.swift
//  SwiftyDB
//
//  Created by y7 on 2017/9/5.
//  Copyright © 2017年 y7. All rights reserved.
//

import Foundation

typealias sqlite3_stmt = OpaquePointer
typealias sqlite3 = OpaquePointer

protocol SQLiteValue {
    func toSQL() -> String
}

extension SQLiteValue {
    func toSQL() -> String {
        return "\(self)"
    }
}

extension Data: SQLiteValue {}
extension Date: SQLiteValue {}

extension String: SQLiteValue {}
extension Character: SQLiteValue {}

extension Bool: SQLiteValue {
    func toSQL() -> String {
        return self ? "1" : "0"
    }
}

extension Float: SQLiteValue {}
extension Double: SQLiteValue {}

extension Int: SQLiteValue {}
extension UInt: SQLiteValue {}

enum SQLiteType: String {
    case text       = "TEXT"
    case integer    = "INTEGER"
    case real       = "REAL"
    case blob       = "BLOB"
    case null       = "NULL"
}

extension SQLiteType {
    
    init(type: SQLiteValue.Type) {
        switch type {
        case is Int.Type, is UInt.Type, is Bool.Type:
            self = .integer
        case is String.Type, is Character.Type:
            self = .text
        case is Float.Type, is Double.Type, is Date.Type:
            self = .real
        case is Data.Type:
            self = .blob
        default:
            fatalError()
        }
    }
}

class Database {
    
    // MARK: - public
    
    // MARK: - open
    
    func open() -> Bool {
        if _db != nil { return true }
        return _dbOpen()
    }
    
    // MARK: - query
    
    func query(_ sql: String, _ parameters: [SQLiteValue?]) -> ResultSet? {
        guard let stmt = _prepareStmt(sql: sql) else { return nil }
        
        if parameters.count > 0 {
            stmt.bind(parameters)
        }
        
        return ResultSet(stmt: stmt)
    }
    
    func query(_ sql: String, _ parameters: SQLiteValue?...) -> ResultSet? {
        return query(sql, parameters)
    }
    
    func query(_ sql: String, _ parameters: [String: SQLiteValue?]) -> ResultSet? {
        guard let stmt = _prepareStmt(sql: sql) else { return nil }
        
        if parameters.count > 0 {
            stmt.bind(parameters)
        }
        
        return ResultSet(stmt: stmt)
    }
    
    // MARK: - update
    
    func update(_ sql: String, _ parameters: [SQLiteValue?]) -> Bool {
        guard let stmt = _prepareStmt(sql: sql) else {
            return false
        }
        if parameters.count > 0 {
            stmt.bind(parameters)
        }
        
        return stmt.step() == SQLITE_DONE
    }
    
    func update(_ sql: String, _ parameters: SQLiteValue?...) -> Bool {
        return update(sql, parameters)
    }
    
    func update(_ sql: String, _ parameters: [String: SQLiteValue?]) -> Bool {
        guard let stmt = _prepareStmt(sql: sql) else {
            return false
        }
        if parameters.count > 0 {
            stmt.bind(parameters)
        }
        
        return stmt.step() == SQLITE_DONE
    }
    
    // MARK: - transaction
    
    private(set) var isInTransaction: Bool = false
    
    func beginTransaction() -> Bool {
        let suc = update("begin transaction")
        if suc {
            isInTransaction = true
        }
        return suc
    }
    
    func commit() -> Bool {
        let suc = update("commit transaction")
        if suc {
            isInTransaction = false
        }
        return suc
    }
    
    func rollback() -> Bool {
        let suc = update("rollback transaction")
        if suc {
            isInTransaction = false
        }
        return suc
    }
    
    // MARK: - exists
    
    func contains(table name: String) -> Bool {
        guard let rs = query("select [sql] from sqlite_master where [type] = 'table' and lower(name) = ?", name.lowercased()) else {
            return false
        }
        return rs.next()        
    }
    
    func contains(index name: String) -> Bool {
        guard let rs = query("select [sql] from sqlite_master where [type] = 'index' and lower(name) = ?", name.lowercased()) else {
            return false
        }
        return rs.next()
    }
    
    func tableSchema(_ name: String) -> ResultSet? {
        //result colums: cid[INTEGER], name, type [STRING], notnull[INTEGER], dflt_value[], pk[INTEGER]
        return query("pragma table_info('\(name)')")
    }
    
    func contains(column name: String, in table: String) -> Bool {
        let n = name.lowercased()
        let t = table.lowercased()
        guard let rs = tableSchema(t) else {
            return false
        }
        var exists = false
        while rs.next() {
            if rs.stringForColumn(name: "name").lowercased() == n {
                exists = true
                break
            }
        }
        return exists
    }
    
    // MARK: - error
    
    var error: String {
        return "\(sqlite3_errcode(_db)) : " + String(cString: sqlite3_errmsg(_db))
    }
    
    // MARK: - init
    
    init(path: String) {
        _dbPath = path
    }
    
    deinit {
        _ = _dbClose()
    }
    
    // MARK: - private
    
    private let Max_Error_Retry_Count = 8
    private let Min_Retry_Time_Interval: TimeInterval = 2.0
    
    private var _db: sqlite3? // sqlite3 *
    
    private var _dbPath: String
    
    private var _dbOpenErrorCount: Int = 0
    
    private var _dbLastOpenErrorTime: TimeInterval = 0.0
    
//    private lazy var _stmtCache: [String: Set] = {
//        return [String: Set]()
//    }()
    
    // MARK: - open
    
    private func _dbOpen() -> Bool {
        
        let result = sqlite3_open(_dbPath, &_db) // sqlite3_open_v2(_dbPath, &_db, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil) //
        if result == SQLITE_OK {
            _dbOpenErrorCount = 0
            _dbLastOpenErrorTime = 0
            return true
        } else {
            _db = nil
            _dbOpenErrorCount += 1
            _dbLastOpenErrorTime = NSDate.timeIntervalSinceReferenceDate
            return false
        }
    }
    
    private func _dbClose() -> Bool  {
        guard let db = _db else { return true }
        var result: Int32
        var retry: Bool
        var isStmtFinalized = false
//        _dbStmtCache.removeAll()
        
        repeat {
            retry = false
            result = sqlite3_close_v2(db)
            if result == SQLITE_BUSY || result == SQLITE_LOCKED {
                if !isStmtFinalized {
                    isStmtFinalized = true
                    var stmt = sqlite3_next_stmt(db, nil)
                    while stmt != nil {
                        sqlite3_finalize(stmt)
                        stmt = sqlite3_next_stmt(db, nil)
                        retry = true
                    }
                }
            }
        } while retry
        _db = nil
        return result == SQLITE_OK
    }
    
    private func _dbCheck() -> Bool {
        if _db == nil {
            if _dbOpenErrorCount < Max_Error_Retry_Count && NSDate.timeIntervalSinceReferenceDate - _dbLastOpenErrorTime > Min_Retry_Time_Interval {
                return _dbOpen() //&& _dbInitialize()
            } else {
                return false
            }
        }
        return true
    }
    
    // MARK: - statement
    
    private func _prepareStmt(sql: String) -> Statement? {
        if sql.isEmpty || !_dbCheck() { return nil }
        
        let stmt = Statement(sql: sql)
        if stmt.prepare(for: self._db!) {
            return stmt
        } else {
            return nil
        }
    }
    
    
    
    
    
    
    
}


























