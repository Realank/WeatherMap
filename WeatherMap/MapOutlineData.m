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
#import "JSONKit.h"
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
    
    NSDictionary *polygonData = [self fetchOutLineForCity:cityName];
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
        NSUInteger minCount = 300;
        if ([dist.name isEqualToString:@"舟山市"]) {
            minCount = 200;
        } else if ([dist.name isEqualToString:@"澳門特別行政區"]){
            minCount = 50;
        }
        for (NSString *polylineStr in dist.polylines)
        {
            NSArray *polylineCoordinatesArr = [CommonUtility shortCoordinatesArrByString:polylineStr withParseToken:@";" maxCount:180 minCount:minCount];
            if (polylineCoordinatesArr.count > 0) {
                [polylineArr addObject:polylineCoordinatesArr];
            }
            
        }
        if (polylineArr.count == 0) {
            return nil;
        }
        mapOutlineModel.polygonCoordinates = [polylineArr copy];
        NSDictionary *storeDict = @{@"center":mapOutlineModel.centerCoordinate, @"polygon":mapOutlineModel.polygonCoordinates};
        [self storeOutLineForCity:mapOutlineModel.cityName withDict:storeDict];
        return mapOutlineModel;
    }
    
    return nil;
    

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

#pragma mark - 数据持久化
- (void)storeOutLineForCity:(NSString *)cityName withDict:(NSDictionary *)dict{
    if (!dict) {
        return;
    }
    NSData *dateToStore = [dict JSONData];
    NSString *cityFolderPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"citys"];
    NSString *fileName = [NSString stringWithFormat:@"%@.city",cityName];
    NSString *filePath = [cityFolderPath stringByAppendingPathComponent:fileName];
    
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:cityFolderPath isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:cityFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    BOOL success = [dateToStore writeToFile:filePath atomically:YES];
}

- (NSDictionary *)fetchOutLineForCity:(NSString *)cityName {
    NSString *cityFolderPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"citys"];
    NSString *fileName = [NSString stringWithFormat:@"%@.city",cityName];
    NSString *filePath = [cityFolderPath stringByAppendingPathComponent:fileName];
    
    NSData *dataLoaded = [NSData dataWithContentsOfFile:filePath];
    if (!dataLoaded) {
        return nil;
    }
    NSDictionary *dict = [dataLoaded objectFromJSONData];
    return dict;
}

//单个文件的大小
+ (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}
//遍历文件夹获得文件夹大小，返回多少M
+ (float ) folderSizeAtPath:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}

+ (float) cacheCitysSize {
    NSString *cityFolderPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"citys"];
    return [MapOutlineData folderSizeAtPath:cityFolderPath];
}

+ (void) delectCacheCitysFolder {
    NSString *cityFolderPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"citys"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:cityFolderPath error:nil];
}

@end
