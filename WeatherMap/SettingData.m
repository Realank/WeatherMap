//
//  SettingData.m
//  WeatherMap
//
//  Created by Realank on 15/10/16.
//  Copyright © 2015年 Realank. All rights reserved.
//

#import "SettingData.h"
#import <MobClick.h>
#import "CityListModel.h"

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
        
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"settingData"];
        if (!dict) {
            dict = @{@"time":[self weatherTimeToString:WEA_TOMOTTOW],@"content":[self weatherContentToString:WEA_RAIN],@"showSpin":[self boolToString:YES],@"crazyMode":[self boolToString:NO]};
            [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"settingData"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        _weatherTime = [self weatherTimeStringToEnum:[dict objectForKey:@"time"]];
        _weatherContent = [self weatherContentStringToEnum:[dict objectForKey:@"content"]];
        _showSpin = [self stringToBool:[dict objectForKey:@"showSpin"]];
        _crazyMode = [self stringToBool:[dict objectForKey:@"crazyMode"]];
        self.settingStatusChanged = YES;
        
    }
    
    return self;
}

#pragma mark - change setting status

- (void) syncCoreData {
    NSDictionary *dict = @{@"time":[self weatherTimeToString:_weatherTime],@"content":[self weatherContentToString:_weatherContent],@"showSpin":[self boolToString:_showSpin],@"crazyMode":[self boolToString:_crazyMode]};
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"settingData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)setWeatherTime:(SDWeatherTime)weatherTime {
    
    _weatherTime = weatherTime;
    [MobClick event:@"Setting"label:@"time"];
    self.settingStatusChanged = YES;
    [self syncCoreData];
   
}

- (void)setWeatherContent:(SDWeatherContent)weatherContent {
    _weatherContent = weatherContent;
    [MobClick event:@"Setting"label:@"content"];
    self.settingStatusChanged = YES;
    [self syncCoreData];

}

- (void)setShowSpin:(BOOL)showSpin {
    
    _showSpin = showSpin;
    self.settingStatusChanged = YES;
    [MobClick event:@"Setting"label:@"spin"];
    [self syncCoreData];
    
}

- (void)setCrazyMode:(BOOL)crazyMode {
    _crazyMode = crazyMode;
    if (!crazyMode) {
        while ([CityListModel sharedInstance].selectedProvincesNameArray.count > MAX_CITY_NUM) {
            [[CityListModel sharedInstance].selectedProvincesNameArray removeObjectAtIndex:0];
        }
    }
    self.settingStatusChanged = YES;
    [MobClick event:@"Setting"label:@"crazyMode"];
    [self syncCoreData];
}

- (BOOL)settingStatusChanged {
    BOOL ret = _settingStatusChanged;
    _settingStatusChanged = NO;
    return ret;
}

#pragma mark - use for core data storage

- (NSString *)weatherTimeToString:(SDWeatherTime)time {
    switch (time) {
        case WEA_TODAY:
            return @"WEA_TODAY";
        case WEA_TOMOTTOW:
            return @"WEA_TOMOTTOW";
        case WEA_AFTERTOMORROW:
            return @"WEA_AFTERTOMORROW";

    }
}



- (SDWeatherTime)weatherTimeStringToEnum:(NSString *)timeString {
    if ([timeString isEqualToString:@"WEA_TODAY"]) {
        return WEA_TODAY;
    } else if ([timeString isEqualToString:@"WEA_TOMOTTOW"]) {
        return WEA_TOMOTTOW;
    } else {
        return WEA_AFTERTOMORROW;
    }
}

- (NSString *)weatherContentToString:(SDWeatherContent)content {
    switch (content) {
        case WEA_RAIN:
            return @"WEA_RAIN";
        case WEA_TEMPERATURE:
            return @"WEA_TEMPERATURE";
        case WEA_WIND:
            return @"WEA_WIND";
            
    }
}

- (SDWeatherContent)weatherContentStringToEnum:(NSString *)contentString {
    if ([contentString isEqualToString:@"WEA_RAIN"]) {
        return WEA_RAIN;
    } else if ([contentString isEqualToString:@"WEA_TEMPERATURE"]) {
        return WEA_TEMPERATURE;
    } else {
        return WEA_WIND;
    }
}

- (NSString *)boolToString:(BOOL)yes {
    if (yes) {
        return @"YES";
    }
    return @"NO";
}

- (BOOL)stringToBool:(NSString *)yesString {
    if ([yesString isEqualToString:@"YES"]) {
        return YES;
    }
    return NO;
}

@end
