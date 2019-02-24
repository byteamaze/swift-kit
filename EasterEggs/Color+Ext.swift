//
//  Color扩展
//
//  Created by Lucca on 2018/9/14.
//  Copyright © 2018年 ByteAmaze. All rights reserved.
//

/// 将16进制颜色转换为10进制色值
public func colorComponent(
    _ hex: String, start: Int, length: Int) -> Float {
    var fullHex = (hex as NSString).substring(
        with: NSMakeRange(start, length))
    if length == 1 { fullHex.append(fullHex) }
    var hexComponent:CUnsignedInt = 0
    Scanner(string: fullHex).scanHexInt32(&hexComponent)
    return Float(hexComponent) / 255.0
}

/// 16进制颜色转ARGB数组
fileprivate func colorComponentsOf(hexString: String)
    -> (Float, Float, Float, Float) {
    var colorString = hexString.uppercased()
    if colorString .hasPrefix("#") {
        colorString = colorString.replacingOccurrences(of: "#", with: "")
    } else if colorString.hasPrefix("0X") {
        colorString = colorString.replacingOccurrences(of: "0X", with: "")
    }
    var alpha: Float! = 1.0
    var red: Float! = 1.0
    var blue:Float! = 1.0
    var green: Float! = 1.0
    switch colorString.count {
    case 3: // #RGB
        alpha = 1.0
        
        red   = colorComponent(colorString, start: 0, length: 1)
        green = colorComponent(colorString, start: 1, length: 1)
        blue  = colorComponent(colorString, start: 2, length: 1)
    case 4: // #ARGB
        alpha = colorComponent(colorString, start: 0, length: 1)
        red   = colorComponent(colorString, start: 1, length: 1)
        green = colorComponent(colorString, start: 2, length: 1)
        blue  = colorComponent(colorString, start: 3, length: 1)
    case 6: // #RRGGBB
        alpha = 1.0
        red   = colorComponent(colorString, start: 0, length: 2)
        green = colorComponent(colorString, start: 2, length: 2)
        blue  = colorComponent(colorString, start: 4, length: 2)
    case 8: // #AARRGGBB
        alpha = colorComponent(colorString, start: 0, length: 2)
        red   = colorComponent(colorString, start: 2, length: 2)
        green = colorComponent(colorString, start: 4, length: 2)
        blue  = colorComponent(colorString, start: 6, length: 2)
    default: break
    }
    return (alpha, red, green, blue)
}

/// 颜色转16进制字符串
fileprivate func toHex(ofColor color: CGColor) -> String? {
    if let components = color.components, components.count >= 3 {
        let r = components[0]
        let g = components[1]
        let b = components[2]
        let a = (components.count > 3) ? components[3] : 1
        let hexString = NSString(format: "#%02X%02X%02X%02X",
                                 Int(a * 255), Int(r * 255),
                                 Int(g * 255), Int(b * 255))
        return hexString as String
    }
    return nil
}

#if os(OSX)
public extension NSColor {

    /// #AARRGGBB 16进制字符转颜色值
    public convenience init(hex: String) {
        self.init(hexString: hex)
    }
    
    /// #AARRGGBB 16进制字符转颜色值
    public convenience init(hexString: String) {
        let (a,r,g,b) = colorComponentsOf(hexString: hexString)
        self.init(red: CGFloat(r), green: CGFloat(g),
                  blue: CGFloat(b), alpha: CGFloat(a))
    }
    
    /// 颜色转为16进制字符
    public func hexString() -> String? {
        return toHex(ofColor: self.cgColor)
    }
    
    /// 颜色创建图片
    public var image: NSImage {
        return image(withSize: CGSize(width: 1, height: 1))
    }

    /// create image with radius and border
    public func image(withSize size: CGSize, radius r: CGFloat = 0,
                      border: (CGFloat, NSColor?) = (0, nil)) -> NSImage {
        var rect = CGRect(origin: .zero, size: size)
        let image = NSImage(size: size)
        image.lockFocus()
        let (bWidth, bColor) = border
        // fill
        let r2 = r - bWidth
        rect = rect.insetBy(dx: bWidth, dy: bWidth)
        let path = NSBezierPath(roundedRect: rect, xRadius: r2, yRadius: r2)
        self.setFill()
        path.fill()
        // border
        if bWidth > 0 {
            let bRect = CGRect(origin: .zero, size: size)
                .insetBy(dx: bWidth, dy: bWidth)
            let br = r - bWidth / 2
            let color = bColor ?? self.blended(withFraction: 0.2, of: .black)
            let path = NSBezierPath(roundedRect: bRect, xRadius: br, yRadius: br)
            path.lineWidth = bWidth
            color?.setStroke()
            path.stroke()
        }
        image.unlockFocus()
        return image
    }

    /// create ring image
    public func ringImage(withSize size: CGSize, lineWidth lw: CGFloat) -> NSImage {
        let rect = CGRect(origin: .zero, size: size).insetBy(dx: lw, dy: lw)
        let path = NSBezierPath(ovalIn: rect)
        let image = NSImage(size: size)
        image.lockFocus()
        self.setStroke()
        path.lineWidth = lw
        path.stroke()
        image.unlockFocus()
        return image
    }
}
#elseif os(iOS)
public extension UIColor {
    /// #AARRGGBB 16进制字符转颜色值
    public convenience init(hex: String) {
        self.init(hexString: hex)
    }
    
    /// #AARRGGBB 16进制字符转颜色值
    public convenience init(hexString:String) {
        let (a,r,g,b) = colorComponentsOf(hexString: hexString)
        self.init(red: CGFloat(r), green: CGFloat(g),
                  blue: CGFloat(b), alpha: CGFloat(a))
    }
    
    /// 颜色转为16进制字符
    public func hexString() -> String? {
        return toHex(ofColor: self.cgColor)
    }
    
    /// 颜色混合
    func blended(withFraction fraction: CGFloat, of color: UIColor) -> UIColor {
        var r1: CGFloat = 1.0, g1: CGFloat = 1.0
        var b1: CGFloat = 1.0, a1: CGFloat = 1.0
        var r2: CGFloat = 1.0, g2: CGFloat = 1.0
        var b2: CGFloat = 1.0, a2: CGFloat = 1.0
        
        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return UIColor(red: r1 * (1 - fraction) + r2 * fraction,
                       green: g1 * (1 - fraction) + g2 * fraction,
                       blue: b1 * (1 - fraction) + b2 * fraction,
                       alpha: a1 * (1 - fraction) + a2 * fraction);
    }

    /// 颜色创建图片
    public var image: UIImage? {
        return image(withSize: CGSize(width: 1, height: 1))
    }
    
    /// create image with radius and border
    public func image(withSize size: CGSize, radius r: CGFloat = 0,
                      border: (CGFloat, UIColor?) = (0, nil)) -> UIImage? {
        var rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let (bWidth, bColor) = border
        // fill
        let r2 = r - bWidth
        rect = rect.insetBy(dx: bWidth, dy: bWidth)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: r2)
        self.setFill()
        path.fill()
        // border
        if bWidth > 0 {
            let bRect = CGRect(origin: .zero, size: size)
                .insetBy(dx: bWidth, dy: bWidth)
            let br = r - bWidth / 2
            let color = bColor ?? self.blended(withFraction: 0.2, of: .black)
            let path = UIBezierPath(roundedRect: bRect, cornerRadius: br)
            path.lineWidth = bWidth
            color.setStroke()
            path.stroke()
        }
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// create ring image
    public func ringImage(withSize size: CGSize, lineWidth lw: CGFloat) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size).insetBy(dx: lw, dy: lw)
        let path = UIBezierPath(ovalIn: rect)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.setStroke()
        path.lineWidth = lw
        path.stroke()
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
#endif
