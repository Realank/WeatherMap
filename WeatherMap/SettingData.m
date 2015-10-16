//
//  SettingData.m
//  WeatherMap
//
//  Created by Realank on 15/10/16.
//  Copyright © 2015年 Realank. All rights reserved.
//

#import "SettingData.h"

@implementation SettingData

+(instancetype) sharedInstance {
    static dispatch_once_t pred;
    static id shared = nil; //设置成id类型的目的，是为了继承
    dispatch_once(&pred, ^{
        shared = [[super alloc] initUniqueInstance];
    });
    return shared;
}

-(instancetype) initUniqueInstance {
    
    if (self = [super init]) {
        _weatherTime = WEA_TOMOTTOW;
        _weatherContent = WEA_RAIN;
        _showSpin = YES;
    }
    
    return self;
}

- (void)setWeatherTime:(SDWeatherTime)weatherTime {
    
    if (_weatherTime != weatherTime) {
        self.settingStatusChanged = YES;
    }
    _weatherTime = weatherTime;
}

- (void)setWeatherContent:(SDWeatherContent)weatherContent {
    if (_weatherContent != weatherContent) {
        self.settingStatusChanged = YES;
    }
    _weatherContent = weatherContent;
}

- (void)setShowSpin:(BOOL)showSpin {
    if (_showSpin != showSpin) {
        self.settingStatusChanged = YES;
    }
    _showSpin = showSpin;
}

- (BOOL)settingStatusChanged {
    BOOL ret = _settingStatusChanged;
    _settingStatusChanged = NO;
    return ret;
}



@end
