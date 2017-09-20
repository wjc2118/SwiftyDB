//
//  DatabaseQueue.swift
//  SwiftyDB
//
//  Created by y7 on 2017/9/6.
//  Copyright © 2017年 y7. All rights reserved.
//

import Foundation

class DatabaseQueue {
    
    private let _queue = DispatchQueue(label: "swiftydb.queue")
    
    private let _db: Database
    
    init(path: String) {
        _db = Database(path: path)
        _ = _db.open()
    }
}

extension DatabaseQueue {
    
    func sync(_ closure: (Database, inout Bool) -> ()) {
        _queue.sync {
            _handle(closure)
        }
    }
    
    func async(_ closure: @escaping (Database, inout Bool) -> ()) {
        _queue.async {
            self._handle(closure)
        }
    }
    
}

extension DatabaseQueue {
    
    private func _handle(_ closure: (Database, inout Bool) -> ()) {
        var rollback = false
        _ = _db.beginTransaction()
        closure(_db, &rollback)
        if rollback {
            _ = _db.rollback()
        } else {
            _ = _db.commit()
        }
    } 
}
