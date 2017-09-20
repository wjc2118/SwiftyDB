//
//  ViewController.swift
//  SwiftyDB
//
//  Created by y7 on 2017/9/5.
//  Copyright © 2017年 y7. All rights reserved.
//

import UIKit

class C: CustomStringConvertible {
    let a = "aa"
    let i: Int? = nil
    
    var description: String {
        return "awfewfewf"
    }
}

struct Test: Storable {
//    let s: String
//    var ss: String
//    var o: Int?
//    var v: [Int]
//    let c = C()
    let id: Int
    let name: String
    let bool: Bool
//    let date: Date
    
    var primaryKey: String? {
        return "id"
    }
}

class ViewController: UIViewController {
    
    var queue: DatabaseQueue!

    let db = SwiftyDB(path: "/Users/y7/Desktop/aaa.sqlite")

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        
        
        
//        let t = Test(s: "str", ss: "sstr", o: nil, v: [3, 5])
//        let m = Mirror(reflecting: t)
//        
//        print(type(of: t))
//        print(String(describing: m.subjectType))
//        print(m.displayStyle, m.displayStyle == .optional)
//        print(m.superclassMirror)
//        print("")
//        for (l, v) in m.children {
//            guard let l = l else { continue }
//            print(l, v)
//            let n = Mirror(reflecting: v)
//            print(type(of: v))
//            print(String(describing: n.subjectType))
//            print(n.displayStyle, n.displayStyle == .optional)
//            print("")
//        }
        
        
        
        for i in 0..<20 {
//            _ = db.insert(Test(id: i, name: (i % 2 == 0 ? "a\(i)" : nil), bool: i % 2 == 0))
//            _ = db.insert(Test(id: i, name: "a\(i)", bool: i % 2 == 0))
//            _ = SwiftyDB.shared.insert(Test(id: i, name: "a\(i)", bool: i % 2 == 0))
        }
        
        /*
        queue = DatabaseQueue(path: "/Users/y7/Desktop/aaa.sqlite")
        
        queue.sync { (db, rollback) in
            let suc = db.update("CREATE TABLE IF NOT EXISTS tab(id INTEGER PRIMARY KEY NOT NULL, name TEXT, bool INTEGER, date BLOB)")
            if !suc {
                rollback = true
            }
        }
        queue.sync { (db, rollback) in
            for i in 0..<20 {
                let suc = db.update("INSERT OR REPLACE INTO tab (id,name,bool,date) VALUES (?,?,?,?)", i, "a\(i)", i%2 == 0, Date())
                if !suc {
                    rollback = true
                }
            }
            
            _ = db.update("INSERT OR REPLACE INTO tab VALUES (:a,:b,:c,:d)", ["b": nil, "a": 30, "c": true, "d": Date()])
        }
         */
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
//        let db = SwiftyDB(path: "/Users/y7/Desktop/aaa.sqlite")
//        _ = db.delete(Test.self)
        
//        _ = db.delete(Test.self, filter: .in(name: "id", range: [3, 13]) || .equal("id", 7) || .equal("name", "a15"))
        
        
//        queue.async { (db, roll) in
//            let r = db.query("SELECT * FROM tab WHERE name IS NULL")!
//            
//            
//            r.forEach { (r) in
//                print(r["id"] as Int)
//                print(r["name"] as String)
//                print(r.boolForColumn(name: "bool"))
//                print(r.dateForColumn(name: "date"))
//                print("")
//            }
//        }
        
        
        
    }


}





