//
//  DatabaseQueue.swift
//  SwiftyDB
//
//  Created by y7 on 2017/9/6.
//  Copyright © 2017年 y7. All rights reserved.
//

import Foundation

class DatabaseQueue {
    
    fileprivate let _queue = DispatchQueue(label: "swiftydb.queue")
    
    fileprivate let _db: Database
    
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
    
    fileprivate func _handle(_ closure: (Database, inout Bool) -> ()) {
        var need = false
        _ = _db.beginTransaction()
        closure(_db, &need)
        if need {
            _ = _db.rollback()
        } else {
            _ = _db.commit()
        }
    } 
}
