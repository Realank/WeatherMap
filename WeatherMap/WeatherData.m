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

@interface WeatherData ()

@end

@implementation WeatherData

- (instancetype)init {
    if (self = [super init]) {
        _weatherInfo = [[NSMutableDictionary alloc]init];
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
            [self asyncRequestWeatherInfoWithCityCode:cityCode];
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

- (void)asyncRequestWeatherInfoWithCityCode:(NSUInteger)cityCode {
    
    __weak __typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, arc4random_uniform(50)* NSEC_PER_USEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        NSString *urlString = [NSString stringWithFormat:@"http://182.92.183.168/weatherRequest.php?%lu",(unsigned long)cityCode];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            
            NSDictionary *resultDict = [data objectFromJSONData];
            if (!resultDict) {
                NSString *cityCodeStr = [NSString stringWithFormat:@"%lu",cityCode];
                
                DLog(@"[天气]%@:获取失败",[[CityListModel sharedInstance]cityNameForAreaCode:cityCodeStr]);
                return;
            }
            WeatherModel *model = [[WeatherModel alloc]initWithDict:resultDict];
            WeatherForcast *tomorrowWeather = model.forcast[1];
            [weakSelf.weatherInfo setObject:model forKey:model.cityChineseName];
            
            DWeahtherLog(@"[天气]获取 %@ 信息：%@ %@~%@",model.cityChineseName, tomorrowWeather.daytimeStatus,tomorrowWeather.daytimeTemperature,tomorrowWeather.nightTemperature);
            
            if (!model) {
                DLog(@"[天气]%lu:获取失败",(unsigned long)cityCode);
                return;
            }
            if (weakSelf.delegate) {
                [weakSelf.delegate weatherDataDidLoadForCity:model.cityChineseName];
            }
            
        }];
        
        
    });
    
    
}


@end
