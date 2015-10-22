//
//  TemperatureColorModel.h
//  WeatherMap
//
//  Created by Realank on 15/10/22.
//  Copyright © 2015年 Realank. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIColor;
@interface TemperatureColorModel : NSObject

+ (UIColor *)colorForTemperature:(NSInteger)temperature;

@end
