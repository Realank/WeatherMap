//
//  WindMappingModel.h
//  WeatherMap
//
//  Created by Realank on 15/10/16.
//  Copyright © 2015年 Realank. All rights reserved.
//

#import <Foundation/Foundation.h>


@class UIColor;
@interface WindMappingModel : NSObject

+(instancetype) sharedInstance;
-(NSString *)windDirectionForKeycode:(NSString *)keycode;
-(NSString *)keycodeForWindDirection:(NSString *)windDirection;
-(NSString *)windStrengthForKeycode:(NSString *)keycode;
-(NSString *)keycodethFor_AMAP_String:(NSString *)amapString;
-(UIColor *)colorForWindStrengthKeycode:(NSString *)keycode;
-(NSArray *)sortedKeyCodes;
// clue for improper use (produces compile time error)
+(instancetype) alloc __attribute__((unavailable("alloc not available, call sharedInstance instead")));
-(instancetype) init __attribute__((unavailable("init not available, call sharedInstance instead")));
+(instancetype) new __attribute__((unavailable("new not available, call sharedInstance instead")));

@end
