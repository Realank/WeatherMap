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
@property (nonatomic,strong) NSMutableArray *windColor;

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
        
        self.windColor = [NSMutableArray array];
        for (int i = 0; i < 10; i++) {

            UIColor *color = [UIColor colorWithRed:180/255.0 green:(180 - 10 * i)/255.0 blue:(180 - 10 * i)/255.0 alpha:1];
            [self.windColor addObject:color];

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
    return [self.windColor objectAtIndex:[keycode integerValue]];
}

- (NSArray *)sortedKeyCodes {
    return self.sortedKeycodesArr;
}

@end
