//
//  WeatherStatusMappingModel.h
//  WeatherMap
//
//  Created by Realank on 15/10/13.
//  Copyright © 2015年 Realank. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIColor;

@interface WeatherStatusItem : NSObject

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) UIColor *color;
@end

@interface WeatherStatusMappingModel : NSObject

-(NSString *)stringForKeycode:(NSString *)keycode;
-(NSString *)keycodeForStatusString:(NSString*)statusString;
-(UIColor *)colorForKeycode:(NSString *)keycode;
-(NSArray *)sortedKeyCodes;
+(instancetype) sharedInstance;

// clue for improper use (produces compile time error)
+(instancetype) alloc __attribute__((unavailable("alloc not available, call sharedInstance instead")));
-(instancetype) init __attribute__((unavailable("init not available, call sharedInstance instead")));
+(instancetype) new __attribute__((unavailable("new not available, call sharedInstance instead")));


@end
