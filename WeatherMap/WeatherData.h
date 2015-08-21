//
//  WeatherData.h
//  WeatherMap
//
//  Created by Realank on 15/8/10.
//  Copyright (c) 2015年 Realank. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WeatherDataLoadSuccessDelegate <NSObject>

- (void)weatherDataDidLoadForCity:(NSString *)city;

@optional
- (void)weatherDataDidLoad;

@end

@interface WeatherData : NSObject

@property (nonatomic,strong) NSMutableDictionary *weatherInfo;
@property (nonatomic,weak) id<WeatherDataLoadSuccessDelegate> delegate;

- (void) loadWeatherInfo;

@end
