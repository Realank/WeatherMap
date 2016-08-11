//
//  WeatherData.m
//  WeatherMap
//
//  Created by Realank on 15/8/10.
//  Copyright (c) 2015年 Realank. All rights reserved.
//

#import "WeatherData.h"
#import "JSONKit.h"
#import "WeatherModel.h"
#import "CityListModel.h"
#import "MAMapKit/MAMapKit.h"
#import <AMapSearchKit/AMapSearchAPI.h>
#import <AMapSearchKit/AMapSearchServices.h>
#import "WeatherStatusMappingModel.h"
#import "WindMappingModel.h"

#define USE_AMAP_WEATHER 1

@interface WeatherData ()<AMapSearchDelegate>
#if USE_AMAP_WEATHER
@property (nonatomic,strong) AMapSearchAPI *search;
#endif
@end

@implementation WeatherData

- (instancetype)init {
    if (self = [super init]) {
        _weatherInfo = [[NSMutableDictionary alloc]init];
#if USE_AMAP_WEATHER
        //搜索配置 高德地图SDK3.0配置
        //配置用户Key
        [AMapSearchServices sharedServices].apiKey = @"e0ad39f24cfdda6b72bcd826252c96ae";
        //初始化检索对象
        _search = [[AMapSearchAPI alloc] init];
        _search.delegate = self;
#endif
    }
    return self;
}

- (void)dealloc {
    
    DWeahtherLog(@"bye weatherData");

}

- (void)loadWeatherInfoFromProvincesList:(NSArray *)provinces {

    NSDictionary *dict = [CityListModel sharedInstance].provinceDict;
    for (NSString *provinceName in provinces) {
        ProvinceInfo *province = [dict objectForKey:provinceName];
        if (!province) {
            continue;
        }
        NSDictionary *citysDict = province.citysDict;
        if (!citysDict) {
            continue;
        }
        for (NSString* cityCodeStr in [citysDict allKeys]) {
            NSUInteger cityCode = [cityCodeStr integerValue];
            if (cityCode < 100000000) {
                continue;
            }
            __weak __typeof(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, arc4random_uniform(50)* NSEC_PER_USEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
#if USE_AMAP_WEATHER
                [weakSelf asyncRequestWeatherInfoUse_AMAP_API_WithCityName:[citysDict objectForKey:cityCodeStr] retryTimes:0];
#else
                [weakSelf asyncRequestWeatherInfoWithCityCode:cityCode retryTimes:0];
#endif
            });
        }
    }
    
}


# pragma mark - 获取天气信息

//- (NSString *)requestWeatherInfoWithCityCode:(NSUInteger)cityCode {
//    
//    
//    NSString *urlString = [NSString stringWithFormat:@"http://182.92.183.168/weatherRequest.php?%lu",(unsigned long)cityCode];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
//    //将请求的url数据放到NSData对象中
//    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
//    NSDictionary *resultDict = [response objectFromJSONData];
//    if (!resultDict) {
//        //获取失败
//        return nil;
//    }
//
//    WeatherModel *model = [[WeatherModel alloc]initWithDict:resultDict];
//    WeatherForcast *tomorrowWeather = model.forcast[1];
//    [self.weatherInfo setObject:model forKey:model.cityChineseName];
//    
//    
//    DWeahtherLog(@"[天气]获取 %@ 信息：%@ %@~%@",model.cityChineseName, tomorrowWeather.daytimeStatus,tomorrowWeather.daytimeTemperature,tomorrowWeather.nightTemperature);
//    return model.cityChineseName;
//}

- (void)asyncRequestWeatherInfoWithCityCode:(NSUInteger)cityCode retryTimes:(NSUInteger)retryTimes{
    
    __weak __typeof(self) weakSelf = self;

    NSString *urlString = [NSString stringWithFormat:@"http://182.92.183.168/weatherRequest.php?%lu",(unsigned long)cityCode];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
        NSDictionary *resultDict = [data objectFromJSONData];
        if (!resultDict) {
            NSString *cityCodeStr = [NSString stringWithFormat:@"%lu",cityCode];
            
            ELOG(@"[天气]%@:获取失败,将重试第%lu次",[[CityListModel sharedInstance]cityNameForAreaCode:cityCodeStr],(unsigned long)retryTimes+1);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(200 * NSEC_PER_MSEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (retryTimes < 3) {
                    [weakSelf asyncRequestWeatherInfoWithCityCode:cityCode retryTimes:retryTimes+1];
                }
                
            });
            return;
        }
        WeatherModel *model = [[WeatherModel alloc]initWithDict:resultDict];
        WeatherForcast *tomorrowWeather = model.forcast[1];
        [weakSelf.weatherInfo setObject:model forKey:model.cityChineseName];
        
        DWeahtherLog(@"[天气]获取 %@ 信息：%@ %@~%@",model.cityChineseName, tomorrowWeather.daytimeStatus,tomorrowWeather.daytimeTemperature,tomorrowWeather.nightTemperature);
        
        if (!model) {
            ELOG(@"[天气]%lu:获取失败",(unsigned long)cityCode);
            return;
        }
        if (weakSelf.delegate) {
            [weakSelf.delegate weatherDataDidLoadForCity:model.cityChineseName];
        }
        
    }];

    
}
#if USE_AMAP_WEATHER
- (void)asyncRequestWeatherInfoUse_AMAP_API_WithCityName:(NSString*)cityName retryTimes:(NSUInteger)retryTimes{
    
    //构造AMapWeatherSearchRequest对象，配置查询参数
    AMapWeatherSearchRequest *request = [[AMapWeatherSearchRequest alloc] init];
    request.city = cityName;
    request.type = AMapWeatherTypeForecast; //AMapWeatherTypeLive为实时天气；AMapWeatherTypeForecase为预报天气
    
    //发起行政区划查询
    [_search AMapWeatherSearch:request];
    

    
        
//    NSDictionary *resultDict;
//        if (!resultDict) {
//            
//            ELOG(@"[天气]%@:获取失败,将重试第%lu次",cityName,(unsigned long)retryTimes+1);
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(200 * NSEC_PER_MSEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                if (retryTimes < 3) {
//                    [weakSelf asyncRequestWeatherInfoUse_AMAP_API_WithCityName:cityName retryTimes:retryTimes+1];
//                }
//                
//            });
//            return;
//        }
//        WeatherModel *model = [[WeatherModel alloc]initWithDict:resultDict];
//        WeatherForcast *tomorrowWeather = model.forcast[1];
//        [weakSelf.weatherInfo setObject:model forKey:model.cityChineseName];
//        
//        DWeahtherLog(@"[天气]获取 %@ 信息：%@ %@~%@",model.cityChineseName, tomorrowWeather.daytimeStatus,tomorrowWeather.daytimeTemperature,tomorrowWeather.nightTemperature);
//        
//        if (!model) {
//            ELOG(@"[天气]%@:获取失败",cityName);
//            return;
//        }
//        if (weakSelf.delegate) {
//            [weakSelf.delegate weatherDataDidLoadForCity:model.cityChineseName];
//        }
    
    
    
}

//实现天气查询的回调函数
- (void)onWeatherSearchDone:(AMapWeatherSearchRequest *)request response:(AMapWeatherSearchResponse *)response
{
    //如果是实时天气
    if(request.type == AMapWeatherTypeLive)
    {
        if(response.lives.count == 0)
        {
            return;
        }
        for (AMapLocalWeatherLive *live in response.lives) {
            ELOG(@"%@",live);
        }
    }
    //如果是预报天气
    else
    {
        if(response.forecasts.count == 0)
        {
            return;
        }
        AMapLocalWeatherForecast *forecast = response.forecasts.firstObject;
        
        WeatherModel *model = [[WeatherModel alloc]init];
        model.cityChineseName = forecast.city;
        model.provinceChineseName = forecast.province;
        model.broadcastTime = forecast.reportTime;
        model.forcast = [NSMutableArray array];
        
        for (AMapLocalDayWeatherForecast *dayForecast in forecast.casts) {
            DLog(@"%@",forecast);
            if (model.forcast.count < 3) {
                WeatherForcast *dayWeather = [[WeatherForcast alloc]init];
                dayWeather.daytimeStatus = [[WeatherStatusMappingModel sharedInstance]keycodeForStatusString:dayForecast.dayWeather];
                dayWeather.nightStatus = [[WeatherStatusMappingModel sharedInstance]keycodeForStatusString:dayForecast.nightWeather];
                dayWeather.daytimeTemperature = dayForecast.dayTemp;
                dayWeather.nightTemperature = dayForecast.nightTemp;
                dayWeather.daytimeWindDirection = [[WindMappingModel sharedInstance]keycodeForWindDirection:dayForecast.dayWind];
                dayWeather.nightWindDirection = [[WindMappingModel sharedInstance]keycodeForWindDirection:dayForecast.nightWind];
                dayWeather.daytimeWindStrength = [[WindMappingModel sharedInstance]keycodethFor_AMAP_String:dayForecast.dayPower];
                dayWeather.nightWindStrength = [[WindMappingModel sharedInstance]keycodethFor_AMAP_String:dayForecast.nightPower];
                [model.forcast addObject:dayWeather];
            }

        }
        [self.weatherInfo setObject:model forKey:model.cityChineseName];
        if (model.forcast.count == 3 && self.delegate) {

            [self.delegate weatherDataDidLoadForCity:model.cityChineseName];

        }
    }
}
#endif

@end
