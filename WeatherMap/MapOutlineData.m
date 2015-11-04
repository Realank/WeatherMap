//
//  MapOutlineData.m
//  WeatherMap
//
//  Created by Realank-Mac on 15/11/3.
//  Copyright © 2015年 Realank. All rights reserved.
//

#import "MapOutlineData.h"
#import <UIKit/UIKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "WeatherData.h"
#import "WeatherModel.h"
#import "WeatherStatusMappingModel.h"
#import "CityListModel.h"
#import "SettingData.h"
#import "WindMappingModel.h"
#import "TemperatureColorModel.h"
#import "CommonUtility.h"
@implementation MapOutlineModel

@end

@implementation MapOutlineData

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
        
    }

    return self;
}

-(MapOutlineModel *)mapOutlineModelByROMCache:(NSString *)cityName andWeatherInfo:(WeatherModel *)weatherModel {
    
    NSDictionary *polygonData = [[NSUserDefaults standardUserDefaults] objectForKey:cityName];
    if (!polygonData) {
        return nil;
    }
    MapOutlineModel *mapOutlineModel = [[MapOutlineModel alloc]init];
    mapOutlineModel.cityName = cityName;
    
    NSArray *centerCoordinates = [polygonData objectForKey:@"center"];
    if (centerCoordinates.count != 2) {
        return nil;
    }
    mapOutlineModel.centerCoordinate = centerCoordinates;
    NSArray *polylineArr = [polygonData objectForKey:@"polygon"];
    if (polylineArr.count <= 0) {
        return nil;
    }
    mapOutlineModel.polygonCoordinates = polylineArr;
    
    mapOutlineModel = [self fillMapOutlineModel:mapOutlineModel withWeatherInfo:weatherModel];
    
    return mapOutlineModel;
}

-(MapOutlineModel *)mapOutlineModelByAMapDistrictInfo:(AMapDistrict *)dist andWeatherInfo:(WeatherModel *)weatherModel{
    
    
    
    MapOutlineModel *mapOutlineModel = [[MapOutlineModel alloc]init];

    mapOutlineModel = [self fillMapOutlineModel:mapOutlineModel withWeatherInfo:weatherModel];
    mapOutlineModel.cityName = dist.name;
    
    NSNumber *centerLatitude = [NSNumber numberWithDouble:dist.center.latitude];
    NSNumber *centerLongitude = [NSNumber numberWithDouble:dist.center.longitude];
    mapOutlineModel.centerCoordinate = [NSArray arrayWithObjects:centerLatitude, centerLongitude, nil];

    //增加城市轮廓多边形
    if (dist.polylines.count > 0)
    {
        DMapLog(@"[地理]正在渲染 %@",dist.name);
        NSMutableArray *polylineArr = [NSMutableArray array];
        for (NSString *polylineStr in dist.polylines)
        {
            NSArray *polylineCoordinatesArr = [CommonUtility shortCoordinatesArrByString:polylineStr withParseToken:@";" maxCount:180];
            if (polylineCoordinatesArr) {
                [polylineArr addObject:polylineCoordinatesArr];
            }
            
        }
        if (polylineArr.count == 0) {
            return nil;
        }
        mapOutlineModel.polygonCoordinates = [polylineArr copy];
  
    }
    
    NSDictionary *storeDict = @{@"center":mapOutlineModel.centerCoordinate, @"polygon":mapOutlineModel.polygonCoordinates};
    [[NSUserDefaults standardUserDefaults] setObject:storeDict forKey:mapOutlineModel.cityName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return mapOutlineModel;
}


-(MapOutlineModel *)fillMapOutlineModel:(MapOutlineModel *)model withWeatherInfo:(WeatherModel *)weatherModel {
    
    WeatherForcast *dayWeather = weatherModel.forcast[1];
    switch ([SettingData sharedInstance].weatherTime) {
        case WEA_TODAY:
            dayWeather = weatherModel.forcast[0];
            break;
        case WEA_TOMOTTOW:
            dayWeather = weatherModel.forcast[1];
            break;
        case WEA_AFTERTOMORROW:
            dayWeather = weatherModel.forcast[2];
            break;
    }
    //大头针显示的内容
    NSString *weatherString;
    //轮廓多边形的颜色
    UIColor *color;
    //判断要显示的天气类型：降水情况、气温或者风力
    switch ([SettingData sharedInstance].weatherContent) {
        case WEA_RAIN: {
            NSString* weatherStatus = dayWeather.daytimeStatus;
            weatherString = [NSString stringWithFormat:@"%@ %@~%@℃",[[WeatherStatusMappingModel sharedInstance] stringForKeycode:weatherStatus],dayWeather.nightTemperature,dayWeather.daytimeTemperature];
            if (weatherStatus.length <= 0) {
                weatherStatus = dayWeather.nightStatus;
                weatherString = [NSString stringWithFormat:@"%@ %@℃",[[WeatherStatusMappingModel sharedInstance] stringForKeycode:weatherStatus],dayWeather.nightTemperature];
            }
            
            color = [[WeatherStatusMappingModel sharedInstance] colorForKeycode:weatherStatus];
            
            break;
        }
            
        case WEA_TEMPERATURE:
        {
            NSString* weatherStatus = dayWeather.daytimeStatus;
            NSInteger temperature = ([dayWeather.daytimeTemperature integerValue] + [dayWeather.nightTemperature integerValue])/2;
            weatherString = [NSString stringWithFormat:@"%@ %@~%@℃",[[WeatherStatusMappingModel sharedInstance] stringForKeycode:weatherStatus],dayWeather.nightTemperature,dayWeather.daytimeTemperature];
            if (weatherStatus.length <= 0) {
                weatherStatus = dayWeather.nightStatus;
                temperature = [dayWeather.nightTemperature integerValue];
                weatherString = [NSString stringWithFormat:@"%@ %@℃",[[WeatherStatusMappingModel sharedInstance] stringForKeycode:weatherStatus],dayWeather.nightTemperature];
            }
            
            color = [TemperatureColorModel colorForTemperature:temperature];
            
            break;
        }
            
        case WEA_WIND:
        {
            weatherString = [NSString stringWithFormat:@"%@ %@",[[WindMappingModel sharedInstance] windDirectionForKeycode:dayWeather.daytimeWindDirection],[[WindMappingModel sharedInstance] windStrengthForKeycode:dayWeather.daytimeWindStrength]];
            color = [[WindMappingModel sharedInstance]  colorForWindStrengthKeycode:dayWeather.daytimeWindStrength];
            
            if (dayWeather.daytimeStatus.length <= 0) {
                weatherString = [NSString stringWithFormat:@"%@ %@",[[WindMappingModel sharedInstance] windDirectionForKeycode:dayWeather.nightWindDirection],[[WindMappingModel sharedInstance] windStrengthForKeycode:dayWeather.nightWindStrength]];
                color = [[WindMappingModel sharedInstance]  colorForWindStrengthKeycode:dayWeather.nightWindStrength];
            }
            
            break;
        }
            
    }
    model.descript = weatherString;
    model.polygonColor = color;
    return model;
}
@end
