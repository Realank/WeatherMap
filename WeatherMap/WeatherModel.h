//
//  WeatherModel.h
//  WeatherMap
//
//  Created by Realank on 15/10/13.
//  Copyright © 2015年 Realank. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol WeatherForcast <NSObject>
@end

@interface WeatherForcast : NSObject

@property (nonatomic, strong) NSString *daytimeStatus;
@property (nonatomic, strong) NSString *nightStatus;
@property (nonatomic, strong) NSString *daytimeTemperature;
@property (nonatomic, strong) NSString *nightTemperature;
@property (nonatomic, strong) NSString *daytimeWindDirection;
@property (nonatomic, strong) NSString *nightWindDirection;
@property (nonatomic, strong) NSString *daytimeWindStrength;
@property (nonatomic, strong) NSString *nightWindStrength;
@property (nonatomic, strong) NSString *sunriseTime;
@property (nonatomic, strong) NSString *sunsetTime;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end

@interface WeatherModel : NSObject

@property (nonatomic, strong) NSString *areaID;
@property (nonatomic, strong) NSString *cityEnglishName;
@property (nonatomic, strong) NSString *cityChineseName;
@property (nonatomic, strong) NSString *bigCityEnglishName;
@property (nonatomic, strong) NSString *bigCityChineseName;
@property (nonatomic, strong) NSString *provinceEnglishName;
@property (nonatomic, strong) NSString *provinceChineseName;
@property (nonatomic, strong) NSString *stateEnglishName;
@property (nonatomic, strong) NSString *stateChineseName;
@property (nonatomic, strong) NSString *cityLevel;
@property (nonatomic, strong) NSString *cityNumCode;
@property (nonatomic, strong) NSString *cityZip;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSString *altitude;
@property (nonatomic, strong) NSString *radarStation;
@property (nonatomic, strong) NSString *broadcastTime;
@property (nonatomic, strong) NSMutableArray<WeatherForcast> *forcast;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
