//
//  UserDefaults+Ext.swift
//
//  Created by Lucca on 2019/1/8.
//  Copyright © 2019 ByteAmaze. All rights reserved.
//

extension UserDefaults {
    
    public struct Key {
        public var rawValue: String
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    public func setValue(_ value: Any?, forKey k: Key, sync: Bool = true) {
        self.setValue(value, forKey: k.rawValue)
        if sync { self.synchronize() }
    }
    
    public func set(_ value: Any?, forKey k: Key, sync: Bool = true) {
        self.set(value, forKey: k.rawValue)
        if sync { self.synchronize() }
    }
    
    public func value(forKey key: Key) -> Any? {
        return self.value(forKey: key.rawValue)
    }
    
    public func set(_ value: Bool, forKey k: Key, sync: Bool = true) {
        self.set(value, forKey: k.rawValue)
        if sync { self.synchronize() }
    }
    
    public func bool(forKey key: Key) -> Bool {
        return self.bool(forKey: key.rawValue)
    }
    
    public func set(_ value: Double, forKey k: Key, sync: Bool = true) {
        self.set(value, forKey: k.rawValue)
        if sync { self.synchronize() }
    }
    
    public func double(forKey key: Key) -> Double {
        return self.double(forKey: key.rawValue)
    }
    
    public func set(_ value: Float, forKey k: Key, sync: Bool = true) {
        self.set(value, forKey: k.rawValue)
        if sync { self.synchronize() }
    }
    
    public func float(forKey key: Key) -> Float {
        return self.float(forKey: key.rawValue)
    }
    
    public func set(_ value: Int, forKey k: Key, sync: Bool = true) {
        self.set(value, forKey: k.rawValue)
        if sync { self.synchronize() }
    }
    
    public func integer(forKey key: Key) -> Int {
        return self.integer(forKey: key.rawValue)
    }
    
    public func set(_ value: URL?, forKey k: Key, sync: Bool = true) {
        self.set(value, forKey: k.rawValue)
        if sync { self.synchronize() }
    }
    
    public func url(forKey key: Key) -> URL? {
        return self.url(forKey: key.rawValue)
    }
    
    public func string(forKey key: Key) -> String? {
        return self.string(forKey: key.rawValue)
    }
    
    public func array(forKey key: Key) -> [Any]? {
        return self.array(forKey: key.rawValue)
    }
    
    public func dictionary(forKey key: Key) -> [String : Any]? {
        return self.dictionary(forKey: key.rawValue)
    }
    
    public func object(forKey key: Key) -> Any? {
        return self.object(forKey: key.rawValue)
    }

    public func data(forKey key: Key) -> Data? {
        return self.data(forKey: key.rawValue)
    }
        
    public func removeObject(forKey key: Key) {
        self.removeObject(forKey: key.rawValue)
    }
}
