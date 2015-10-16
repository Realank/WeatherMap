//
//  WindMappingModel.m
//  WeatherMap
//
//  Created by Realank on 15/10/16.
//  Copyright © 2015年 Realank. All rights reserved.
//

#import "WindMappingModel.h"
#import <UIKit/UIKit.h>

@interface WindMappingModel ()

@property (nonatomic,strong) NSDictionary *windDirection;
@property (nonatomic,strong) NSMutableDictionary *windColor;

@property (nonatomic,strong) NSArray *sortedKeycodesArr;
@end

@implementation WindMappingModel

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
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"WindMapping" ofType:@"plist"];
        self.windDirection = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        
        self.windColor = [NSMutableDictionary dictionary];
        NSString *plistPath2 = [[NSBundle mainBundle] pathForResource:@"windStrengthColor" ofType:@"plist"];
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath2];
        for (NSString *key in [dict allKeys]) {
            NSUInteger rgbColor = [[dict objectForKey:key] integerValue];
            if (rgbColor > 0) {
                UIColor *color = [UIColor colorWithRed:rgbColor/0x10000/255.0 green:rgbColor%0x10000/0x100/255.0 blue:rgbColor%0x100/255.0 alpha:1];
                [self.windColor setValue:color forKey:key];
                
            }
        }
        
        NSArray *arr = [[self.windDirection allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString*  _Nonnull obj1, NSString*  _Nonnull obj2) {
            NSUInteger num1 = [obj1 integerValue];
            NSUInteger num2 = [obj2  integerValue];
            return num1 > num2 ? NSOrderedDescending : NSOrderedAscending;
        }];
        self.sortedKeycodesArr = arr;
    }
    
    return self;
}


-(NSString *)windDirectionForKeycode:(NSString *)keycode{
    
    return [self.windDirection objectForKey:keycode];
    
}

-(NSString *)windStrengthForKeycode:(NSString *)keycode{
    
    NSUInteger strength = [keycode integerValue];
    NSString *string = nil;
    if (strength == 0) {
        string = @"微风";
    } else {
        string = [NSString stringWithFormat:@"%lu-%lu级",strength+2,strength+3];
    }
    
    return string;
}
-(UIColor *)colorForWindStrengthKeycode:(NSString *)keycode{
    return [self.windColor objectForKey:keycode];
}

- (NSArray *)sortedKeyCodes {
    return self.sortedKeycodesArr;
}

@end
