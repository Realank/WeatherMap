//
//  WeatherModel.m
//  WeatherMap
//
//  Created by Realank on 15/10/13.
//  Copyright © 2015年 Realank. All rights reserved.
//

//从中国气象台获取的天气信息

#import "WeatherModel.h"

@implementation WeatherForcast

- (instancetype)initWithDict:(NSDictionary *)dict {
    
    if (self = [super init]) {
        _daytimeStatus = dict[@"fa"];
        _nightStatus = dict[@"fb"];
        _daytimeTemperature = dict[@"fc"];
        _nightTemperature = dict[@"fd"];
        _daytimeWindDirection = dict[@"fe"];
        _nightWindDirection = dict[@"ff"];
        _daytimeWindStrength = dict[@"fg"];
        _nightWindStrength = dict[@"fh"];
        NSString *sunriseAndSunset = dict[@"fi"];
        NSArray *sun = [sunriseAndSunset componentsSeparatedByString:@"|"];
        if (sun.count == 2) {
            _sunriseTime = sun[0];
            _sunsetTime = sun[1];
        }
    }
    return self;
}

@end

@implementation WeatherModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    
    if (self = [super init]) {
        NSDictionary *cityInfo = dict[@"c"];
        if (cityInfo) {
            _areaID = cityInfo[@"c1"];
            _cityEnglishName = cityInfo[@"c2"];
            _cityChineseName = [cityInfo[@"c3"]stringByAppendingString:@"市"];
            _bigCityEnglishName = cityInfo[@"c4"];
            _bigCityChineseName = cityInfo[@"c5"];
            _provinceEnglishName = cityInfo[@"c6"];
            _provinceChineseName = cityInfo[@"c7"];
            _stateEnglishName = cityInfo[@"c8"];
            _stateChineseName = cityInfo[@"c9"];
            _cityLevel = cityInfo[@"c10"];
            _cityNumCode = cityInfo[@"c11"];
            _cityZip = cityInfo[@"c12"];
            _longitude = cityInfo[@"c13"];
            _latitude = cityInfo[@"c14"];
            _altitude = cityInfo[@"c15"];
            _radarStation = cityInfo[@"c16"];
        } else {
            return nil;
        }
        NSDictionary *forcast = dict[@"f"];
        if (forcast) {
            _broadcastTime = forcast[@"f0"];
            NSArray *forcastDays = forcast[@"f1"];
            if (forcastDays.count == 3) {
                for (NSDictionary *dayStatus in forcastDays) {
                    [self.forcast addObject:[[WeatherForcast alloc]initWithDict:dayStatus]];
                }
            } else {
                return nil;
            }
        } else {
            return nil;
        }
    }
    return self;
}

- (NSMutableArray<WeatherForcast> *)forcast {
    if (_forcast == nil) {
        _forcast = [NSMutableArray<WeatherForcast> array];
    }
    return _forcast;
}

@end
