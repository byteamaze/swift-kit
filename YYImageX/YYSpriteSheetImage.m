//
//  YYSpriteImage.m
//  YYImage <https://github.com/ibireme/YYImage>
//
//  Created by ibireme on 15/4/21.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "YYSpriteSheetImage.h"
#import "YYImageCoder.h"

@implementation YYSpriteSheetImage

- (instancetype)initWithSpriteSheetImage:(NSImage *)image
                            contentRects:(NSArray *)contentRects
                          frameDurations:(NSArray *)frameDurations
                               loopCount:(NSUInteger)loopCount {
    CGImageRef cgImage = [image cgImageRef];
    if (!cgImage) return nil;
    if (contentRects.count < 1 || frameDurations.count < 1) return nil;
    if (contentRects.count != frameDurations.count) return nil;
    
    /* TODO self = [super initWithCGImage:cgImage scale:image.scale orientation:image.imageOrientation]; */
    CGSize size = CGSizeMake(CGImageGetWidth(cgImage), CGImageGetHeight(cgImage));
    self = [self initWithCGImage:cgImage size: size];
    if (!self) return nil;
    
    _contentRects = contentRects.copy;
    _frameDurations = frameDurations.copy;
    _loopCount = loopCount;
    return self;
}

- (CGRect)contentsRectForCALayerAtIndex:(NSUInteger)index {
    CGRect layerRect = CGRectMake(0, 0, 1, 1);
    if (index >= _contentRects.count) return layerRect;
    
    CGSize imageSize = self.size;
    CGRect rect = [self animatedImageContentsRectAtIndex:index];
    if (imageSize.width > 0.01 && imageSize.height > 0.01) {
        layerRect.origin.x = rect.origin.x / imageSize.width;
        layerRect.origin.y = rect.origin.y / imageSize.height;
        layerRect.size.width = rect.size.width / imageSize.width;
        layerRect.size.height = rect.size.height / imageSize.height;
        layerRect = CGRectIntersection(layerRect, CGRectMake(0, 0, 1, 1));
        if (CGRectIsNull(layerRect) || CGRectIsEmpty(layerRect)) {
            layerRect = CGRectMake(0, 0, 1, 1);
        }
    }
    return layerRect;
}

#pragma mark @protocol YYAnimatedImage

- (NSUInteger)animatedImageFrameCount {
    return _contentRects.count;
}

- (NSUInteger)animatedImageLoopCount {
    return _loopCount;
}

- (NSUInteger)animatedImageBytesPerFrame {
    return 0;
}

- (NSImage *)animatedImageFrameAtIndex:(NSUInteger)index {
    return self;
}

- (NSTimeInterval)animatedImageDurationAtIndex:(NSUInteger)index {
    if (index >= _frameDurations.count) return 0;
    return ((NSNumber *)_frameDurations[index]).doubleValue;
}

- (CGRect)animatedImageContentsRectAtIndex:(NSUInteger)index {
    if (index >= _contentRects.count) return CGRectZero;
    return ((NSValue *)_contentRects[index]).rectValue;
}

@end
