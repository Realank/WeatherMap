//
//  MAPolygon+PolygenColor.h
//  WeatherMap
//
//  Created by Realank on 15/8/21.
//  Copyright (c) 2015年 Realank. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

@interface MAPolygon (PolygenColor)

- (void) setStrokeColor:(UIColor *)color;
- (UIColor *) strokeColor;
- (void) setFillColor:(UIColor *)color;
- (UIColor *) fillColor;

@end
