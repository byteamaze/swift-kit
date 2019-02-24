//
//  NSError+Ext.swift
//
//  Created by Lucca on 2018/9/14.
//  Copyright © 2018年 ByteAmaze. All rights reserved.
//

import Foundation

public extension NSError {
    
    public static func error(withCode code: Int, description: String) -> NSError {
        return NSError(domain: Bundle.main.bundleIdentifier!, code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
    
}
