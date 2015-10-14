//
//  WeatherStatusMappingModel.m
//  WeatherMap
//
//  Created by Realank on 15/10/13.
//  Copyright © 2015年 Realank. All rights reserved.
//

//将天气状态码，转换为对应的文字和图例颜色的模型

#import "WeatherStatusMappingModel.h"

@interface WeatherStatusMappingModel ()

@property (nonatomic,strong) NSDictionary *weatherStatus;

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
        self.weatherStatus = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    }
    
    return self;
}


-(NSString *)stringForKeycode:(NSString *)keycode{
    NSArray *mapping = [self.weatherStatus objectForKey:keycode];
    if (mapping.count == 2) {
        return mapping[0];
    } else {
        return nil;
    }
    
}
-(UIColor *)strokeColorForKeycode:(NSString *)keycode{
    NSArray *mapping = [self.weatherStatus objectForKey:keycode];
    if (mapping.count == 2) {
        NSUInteger rgbColor = [mapping[1] integerValue];
        return [UIColor colorWithRed:rgbColor/0x10000/255.0 green:rgbColor%0x10000/0x100/255.0 blue:rgbColor%0x100/255.0 alpha:0.8];
    } else {
        return [UIColor clearColor];
    }
}

-(UIColor *)fillColorForKeycode:(NSString *)keycode{
    NSArray *mapping = [self.weatherStatus objectForKey:keycode];
    if (mapping.count == 2) {
        NSUInteger rgbColor = [mapping[1] integerValue];
        return [UIColor colorWithRed:rgbColor/0x10000/255.0 green:rgbColor%0x10000/0x100/255.0 blue:rgbColor%0x100/255.0 alpha:0.6];
    } else {
        return [UIColor clearColor];
    }
}


@end
