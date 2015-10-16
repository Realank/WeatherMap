//
//  WeatherStatusMappingModel.m
//  WeatherMap
//
//  Created by Realank on 15/10/13.
//  Copyright © 2015年 Realank. All rights reserved.
//

//将天气状态码，转换为对应的文字和图例颜色的模型

#import "WeatherStatusMappingModel.h"
#import <UIKit/UIKit.h>
@implementation WeatherStatusItem

@end

@interface WeatherStatusMappingModel ()

@property (nonatomic,strong) NSMutableDictionary *weatherStatus;
@property (nonatomic,strong) NSArray *sortedKeycodesArr;

@end

@implementation WeatherStatusMappingModel

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
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"WeatherStatusMapping" ofType:@"plist"];
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        for (NSString *key in [dict allKeys]) {
            NSArray *mapping = [dict objectForKey:key];
            if (mapping.count == 2) {
                WeatherStatusItem *item = [[WeatherStatusItem alloc]init];
                item.status = mapping[0];
                NSUInteger rgbColor = [mapping[1] integerValue];
                item.color = [UIColor colorWithRed:rgbColor/0x10000/255.0 green:rgbColor%0x10000/0x100/255.0 blue:rgbColor%0x100/255.0 alpha:1];
                [self.weatherStatus setValue:item forKey:key];
            }
        }
        NSArray *arr = [[self.weatherStatus allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString*  _Nonnull obj1, NSString*  _Nonnull obj2) {
            NSUInteger num1 = [obj1 integerValue];
            NSUInteger num2 = [obj2  integerValue];
            return num1 > num2 ? NSOrderedDescending : NSOrderedAscending;
        }];
        self.sortedKeycodesArr = arr;
    }
    
    return self;
}

- (NSDictionary *)weatherStatus {
    if (!_weatherStatus) {
        _weatherStatus = [NSMutableDictionary dictionary];
    }
    return _weatherStatus;
}

- (NSArray *)sortedKeyCodes {
    return self.sortedKeycodesArr;
}

-(NSString *)stringForKeycode:(NSString *)keycode{
    WeatherStatusItem *mapping = [self.weatherStatus objectForKey:keycode];
    return mapping.status;
}
-(UIColor *)colorForKeycode:(NSString *)keycode{
    WeatherStatusItem *mapping = [self.weatherStatus objectForKey:keycode];
    if (mapping) {
        return mapping.color;
    } else {
        return [UIColor clearColor];
    }
}


@end
