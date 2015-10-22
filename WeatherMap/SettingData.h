//
//  SettingData.h
//  WeatherMap
//
//  Created by Realank on 15/10/16.
//  Copyright © 2015年 Realank. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SDWeatherTime) {
    WEA_TODAY,
    WEA_TOMOTTOW,
    WEA_AFTERTOMORROW
};

typedef NS_ENUM(NSUInteger, SDWeatherContent) {
    WEA_RAIN,
    WEA_TEMPERATURE,
    WEA_WIND
};

@interface SettingData : NSObject

@property (nonatomic ,assign) SDWeatherTime weatherTime;
@property (nonatomic ,assign) SDWeatherContent weatherContent;
@property (nonatomic ,assign) BOOL showSpin;
@property (nonatomic ,assign) BOOL crazyMode;

+(instancetype) sharedInstance;
@property (nonatomic ,assign) BOOL settingStatusChanged;

// clue for improper use (produces compile time error)
+(instancetype) alloc __attribute__((unavailable("alloc not available, call sharedInstance instead")));
-(instancetype) init __attribute__((unavailable("init not available, call sharedInstance instead")));
+(instancetype) new __attribute__((unavailable("new not available, call sharedInstance instead")));

@end
