//
//  BlockModel.swift
//  Sockets
//
//  Created by Samarth Paboowal on 20/11/18.
//  Copyright © 2018 Samarth Paboowal. All rights reserved.
//

import Foundation
import ObjectMapper

class Block: NSObject, Mappable {
    
    var op: String?
    var x: X?
    
    override init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        op      <- map["op"]
        x       <- map["x"]
    }
}


class X: NSObject, Mappable {
    
    
    // Block Variables
    var bHash: String?
    var height: Double?
    var reward: Double?
    var totalBTCSent: Double?
    
    // UT Variables
    var utHash: String?
    var time: Double?
    var outs: [Out]?
    
    override init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        bHash       <- map["hash"]
        height      <- map["height"]
        reward      <- map["reward"]
        totalBTCSent    <- map["totalBTCSent"]
        
        utHash      <- map["hash"]
        time        <- map["time"]
        outs        <- map["out"]
    }
}

class Out: NSObject, Mappable {
    
    
    var value: Double?
    
    override init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        value       <- map["value"]
    }
}
