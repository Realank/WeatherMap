//
//  TemperatureColorModel.m
//  WeatherMap
//
//  Created by Realank on 15/10/22.
//  Copyright © 2015年 Realank. All rights reserved.
//

#import "TemperatureColorModel.h"
#import <UIKit/UIKit.h>

@implementation TemperatureColorModel

+ (UIColor *)colorForTemperature:(NSInteger)temperature{
    
    if (temperature > 50) {
        temperature = 50;
    } else if (temperature < -50){
        temperature = -50;
    }
    
    if (temperature <= 25 && temperature >= -25) {
        return [self colorWith255Red:150 + 4*temperature green:150 blue:150 - 4*temperature];
    } else if (temperature > 25) {
        return [self colorWith255Red:250  green:150 - 2*(temperature-25) blue:50];
    }else {
        return [self colorWith255Red:50  green:150 - 2*(temperature+25) blue:250];
    }
}

+ (UIColor *)colorWith255Red:(NSUInteger)red green:(NSInteger)green blue:(NSUInteger)blue {
    red = red > 255 ? 255 : red;
    green = green > 255 ? 255 : green;
    blue = blue > 255 ? 255 : blue;
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
}

@end
