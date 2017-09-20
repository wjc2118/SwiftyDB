//
//  Statement.swift
//  SwiftyDB
//
//  Created by y7 on 2017/9/5.
//  Copyright © 2017年 y7. All rights reserved.
//

import Foundation

private let SQLITE_STATIC = unsafeBitCast(0, to:sqlite3_destructor_type.self)
private let SQLITE_TRANSIENT = unsafeBitCast(-1, to:sqlite3_destructor_type.self)

class Statement {
    
    var _pStmt: sqlite3_stmt? = nil 
    var _sql: String
    
    private lazy var columnNameToIndexMap: [String: Int32] = {
        var map = [String: Int32]()
        for idx in 0..<sqlite3_column_count(self._pStmt) {
            let name = String(cString: sqlite3_column_name(self._pStmt, idx)).lowercased()
            map[name] = idx
        }
        return map
    }()
    
    init(sql: String) {
        _sql = sql
    }
    
    deinit {
        finalize()
    }
}

extension Statement {
    
    var isBusy: Bool {
        return sqlite3_stmt_busy(_pStmt) != 0
    }

    func prepare(for db: sqlite3) -> Bool {
        let s = _sql.cString(using: .utf8)!
        let result = sqlite3_prepare_v2(db, s, -1, &_pStmt, nil)
        if result != SQLITE_OK {
            sqlite3_finalize(_pStmt)
            print("\(sqlite3_errcode(db))" + "====" + String(cString: sqlite3_errmsg(db)))
            return false
        }
        return true
    }
    
    func bind(_ parameters: [SQLiteValue?]) {
        reset()
        clearBindings()
        
        let bindCnt = Int(sqlite3_bind_parameter_count(_pStmt))
        if parameters.count != bindCnt {
            fatalError("parameters.count != bindCnt")
        }
        
        for (idx, val) in parameters.enumerated() {
            _ = _bind(val, to: Int32(idx + 1))
        }
    }
    
    func bind(_ parameters: [String: SQLiteValue?]) {
        reset()
        clearBindings()
        
        let bindCnt = Int(sqlite3_bind_parameter_count(_pStmt))
        if parameters.count != bindCnt {
            fatalError("parameters.count != bindCnt")
        }
        
        for (name, value) in parameters {
            let idx = sqlite3_bind_parameter_index(_pStmt, ":\(name)")
            if idx > 0 {
                _ = _bind(value, to: idx)
            } else {
                fatalError()
            }
        }
    }
    
    func step() -> Int32 {
        return sqlite3_step(_pStmt)
    }
    
    func typeForColumn(at index: Int32) -> SQLiteType {
        switch sqlite3_column_type(_pStmt, index) {
        case SQLITE_INTEGER:
            return .integer
        case SQLITE_FLOAT:
            return .real
        case SQLITE_TEXT, SQLITE3_TEXT:
            return .text
        case SQLITE_BLOB:
            return .blob
        case SQLITE_NULL:
            return .null
        default:
            return .null
        }
    }
    
    func columnIndex(for name: String) -> Int32 {
        let n = name.lowercased()
        guard let idx = columnNameToIndexMap[n] else {
            fatalError("could not find the column named '\(name)'")
        }
        return idx
    }
    
    func columnValue(name: String, type: SQLiteType) -> Any? {
        let idx = columnIndex(for: name)
        return columnValue(idx: idx, type: type)
    }
    
    func columnValue(idx: Int32, type: SQLiteType) -> Any? {
        guard typeForColumn(at: idx) == type else {
            return nil
        }
        
        switch type {
        case .integer:
            return Int(sqlite3_column_int64(_pStmt, idx))
        case .blob:
            guard let blob = sqlite3_column_blob(_pStmt, idx) else {
                return nil
            }
            let bytes = sqlite3_column_bytes(_pStmt, idx)
            if bytes > 0 {
                return Data(bytes: blob, count: Int(bytes))
            } else {
                return nil
            }
        case .real:
            return sqlite3_column_double(_pStmt, idx)
        case .text:
            return String(cString: sqlite3_column_text(_pStmt, idx))
        case .null:
            return nil
        }
    }
    
    // MARK: - private
    
    private func _bind(_ value: SQLiteValue?, to idx: Int32) -> Bool {
        
        var result: Int32 = 0
        
        guard let val = value else {
            result = sqlite3_bind_null(_pStmt, idx)
            return result == SQLITE_OK
        }
        
        switch val {
            
        case let data as Data:
            result = sqlite3_bind_blob(_pStmt, idx, [UInt8](data), Int32(data.count), SQLITE_TRANSIENT)
        case let date as Date:
            result = sqlite3_bind_double(_pStmt, idx, date.timeIntervalSince1970)
            
        case let bool as Bool:
            result = sqlite3_bind_int(_pStmt, idx, bool ? 1 : 0)
        case let float as Float:
            result = sqlite3_bind_double(_pStmt, idx, Double(float))
        case let double as Double:
            result = sqlite3_bind_double(_pStmt, idx, double)
            
        case let string as String:
            result = sqlite3_bind_text(_pStmt, idx, string, -1, SQLITE_TRANSIENT)
        case let character as Character:
            result = sqlite3_bind_text(_pStmt, idx, String(character), -1, SQLITE_TRANSIENT)
            
        case let int as Int:
            result = sqlite3_bind_int64(_pStmt, idx, Int64(int))
        case let uint as UInt:
            result = sqlite3_bind_int64(_pStmt, idx, Int64(uint))
            
        case is NSNull:
            result = sqlite3_bind_null(_pStmt, idx)
            
        default:
            result = SQLITE_ERROR
        }
        
        return result == SQLITE_OK
    }
    
    private func clearBindings() {
        if _pStmt != nil {
            sqlite3_clear_bindings(_pStmt)
        }
    }
    
    private func reset() {
        if _pStmt != nil {
            sqlite3_reset(_pStmt)
        }
    }
    
    private func finalize() {
        if _pStmt != nil {
            sqlite3_finalize(_pStmt)
            _pStmt = nil
        }
    }
    
    
}








