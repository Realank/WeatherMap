//
//  WeatherData.m
//  WeatherMap
//
//  Created by Realank on 15/8/10.
//  Copyright (c) 2015年 Realank. All rights reserved.
//

#import "WeatherData.h"
#import "JSONKit.h"

@interface WeatherData ()

@end

@implementation WeatherData

- (instancetype)init {
    if (self = [super init]) {
        _weatherInfo = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)loadWeatherInfo {
    //山东
    [self enumerCityInfoFrom:101120101 count:17];
    //天津
    [self enumerCityInfoFrom:101030100 count:1];
    //江苏
    [self enumerCityInfoFrom:101190101 count:13];
    //河北
    [self enumerCityInfoFrom:101090101 count:11];
    
}

- (void)enumerCityInfoFrom:(NSUInteger)fromNum count:(NSUInteger)cityCount {
    dispatch_queue_t myQueue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(myQueue, ^{
        for (NSUInteger i = 0; i < cityCount; i++) {
            NSUInteger cityCode = fromNum + i * 100;
            
            //特殊情况的判断
            //承德
            if (cityCode == 101090401) {
                cityCode = 101090402;
            }
            
            NSString *city = [self requestWeatherInfoWithCityCode:cityCode];
            if (!city) {
                city = [self requestWeatherInfoWithCityCode:cityCode];
                if (!city) {
                    NSLog(@"[天气]%lu:获取失败",cityCode);
                    continue;
                }
            }
            if (self.delegate) {
                [self.delegate weatherDataDidLoadForCity:city];
            }
            
        }
        
        //        if (self.delegate) {
        //            [self.delegate weatherDataDidLoad];
        //        }
    });
}



# pragma mark - 获取天气信息

- (NSString *)requestWeatherInfoWithCityCode:(NSUInteger)cityCode {
    
    
    NSString *urlString = [NSString stringWithFormat:@"http://182.92.183.168/weatherRequest.php?%lu",(unsigned long)cityCode];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    //将请求的url数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSDictionary *resultDict = [response objectFromJSONData];
    if (!resultDict) {
        //获取失败
        return nil;
    }
    NSString *city = [resultDict[@"c"][@"c3"] stringByAppendingString:@"市"];
    NSString *tomorrowWeather = resultDict[@"f"][@"f1"][1][@"fa"];
    NSString *tomorrowHighestTemp = resultDict[@"f"][@"f1"][1][@"fc"];
    NSString *tomorrowLowestTemp = resultDict[@"f"][@"f1"][1][@"fd"];
   // NSLog(@"%@ %@ %@ %@",city,tomorrowWeather,tomorrowHighestTemp,tomorrowLowestTemp);
    NSArray *cityWeather = [[NSArray alloc]initWithObjects:tomorrowWeather, tomorrowHighestTemp, tomorrowLowestTemp, nil];
    [self.weatherInfo setObject:cityWeather forKey:city];
    
    NSLog(@"[天气]获取 %@ 信息：%@ %@~%@",city,tomorrowWeather,tomorrowHighestTemp,tomorrowLowestTemp);
    return city;
}


@end
