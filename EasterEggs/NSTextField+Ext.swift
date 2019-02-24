//
//  NSTextField+Ext.swift
//
//  Created by Lucca on 2018/8/27.
//  Copyright © 2018年 ByteAmaze. All rights reserved.
//

#if os(OSX)
import Cocoa

public extension NSTextField {
    public var singleLineText: String? {
        get {
            return self.attributedStringValue.string
        }
        set(newValue) {
            let textParagraph = NSMutableParagraphStyle();
            textParagraph.maximumLineHeight = self.height - 2
            textParagraph.minimumLineHeight = self.height - 2
            
            let attrDic: [NSAttributedStringKey: Any] =
                [NSAttributedStringKey.font: self.font!,
                 NSAttributedStringKey.foregroundColor: self.textColor!,
                 NSAttributedStringKey.paragraphStyle: textParagraph]
            let attrString = NSAttributedString(
                string: newValue ?? "", attributes: attrDic)
            self.allowsEditingTextAttributes = true
            self.attributedStringValue = attrString
        }
    }
}
#endif
