//
//  ResultSet.swift
//  SwiftyDB
//
//  Created by y7 on 2017/9/5.
//  Copyright © 2017年 y7. All rights reserved.
//

import Foundation

struct ResultSet {
    
    fileprivate let _stmt: Statement
    
    init(stmt: Statement) {
        _stmt = stmt
    }
    
}

extension ResultSet {
    
    func next() -> Bool {
        return _stmt.step() == SQLITE_ROW
    }
    
}

// MARK: - value for column index

extension ResultSet {
    
    func intForColumn(at index: Int32) -> Int {
        return _stmt.columnValue(idx: index, type: .integer) as? Int ?? 0
    }
    
    func uintForColumn(at index: Int32) -> UInt {
        return UInt(intForColumn(at: index))
    }
    
    func boolForColumn(at index: Int32) -> Bool {
        return intForColumn(at: index) != 0
    }
    
    func doubleForColumn(at index: Int32) -> Double {
        return _stmt.columnValue(idx: index, type: .real) as? Double ?? 0.0
    }
    
    func stringForColumn(at index: Int32) -> String {
        return _stmt.columnValue(idx: index, type: .text) as? String ?? ""
    }
    
    func dataForColumn(at index: Int32) -> Data {
        return _stmt.columnValue(idx: index, type: .blob) as? Data ?? Data()
    }
    
    func dateForColumn(at index: Int32) -> Date {
        return Date(timeIntervalSince1970: doubleForColumn(at: index))
    }
    
}


// MARK: - value for column name

extension ResultSet {
    
    func intForColumn(name: String) -> Int {
        return intForColumn(at: _stmt.columnIndex(for: name))
    }
    
    func uintForColumn(name: String) -> UInt {
        return uintForColumn(at: _stmt.columnIndex(for: name))
    }
    
    func boolForColumn(name: String) -> Bool {
        return boolForColumn(at: _stmt.columnIndex(for: name))
    }
    
    func doubleForColumn(name: String) -> Double {
        return doubleForColumn(at: _stmt.columnIndex(for: name))
    }
    
    func stringForColumn(name: String) -> String {
        return stringForColumn(at: _stmt.columnIndex(for: name))
    }
    
    func dataForColumn(name: String) -> Data {
        return dataForColumn(at: _stmt.columnIndex(for: name))
    }
    
    func dateForColumn(name: String) -> Date {
        return dateForColumn(at: _stmt.columnIndex(for: name))
    }
}

extension ResultSet: Sequence {
    func makeIterator() -> ResultSet {
        return self
    }
}

extension ResultSet: IteratorProtocol {
    func next() -> ResultSet? {
        if next() {
            return self
        } else {
            return nil 
        }
    }
}









