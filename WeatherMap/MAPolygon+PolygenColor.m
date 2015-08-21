//
//  MAPolygon+PolygenColor.m
//  WeatherMap
//
//  Created by Realank on 15/8/21.
//  Copyright (c) 2015年 Realank. All rights reserved.
//

#import "MAPolygon+PolygenColor.h"
#import <objc/runtime.h>

@implementation MAPolygon (PolygenColor)

static const void * strokeColorKey;
static const void * fillColorKey;

- (void)setStrokeColor:(UIColor *)color {
    objc_setAssociatedObject(self, strokeColorKey, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)strokeColor {
    return objc_getAssociatedObject(self, strokeColorKey);
}

- (void)setFillColor:(UIColor *)color {
    objc_setAssociatedObject(self, fillColorKey, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)fillColor {
    return objc_getAssociatedObject(self, fillColorKey);
}

@end
