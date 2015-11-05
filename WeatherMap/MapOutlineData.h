//
//  MapOutlineData.h
//  WeatherMap
//
//  Created by Realank-Mac on 15/11/3.
//  Copyright © 2015年 Realank. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIColor;
@class AMapDistrict;
@class WeatherModel;

@interface MapOutlineModel : NSObject

@property (nonatomic, strong) NSString *descript;
@property (nonatomic, strong) UIColor *polygonColor;
@property (nonatomic, strong) NSArray *polygonCoordinates;
@property (nonatomic, strong) NSArray *centerCoordinate;
@property (nonatomic, strong) NSString *cityName;
@end

@interface MapOutlineData : NSObject

+(instancetype) sharedInstance;
-(MapOutlineModel *)mapOutlineModelByROMCache:(NSString *)cityName andWeatherInfo:(WeatherModel *)weatherModel;
-(MapOutlineModel *)mapOutlineModelByAMapDistrictInfo:(AMapDistrict *)dist andWeatherInfo:(WeatherModel *)model;

+ (float) cacheCitysSize;

+ (void) delectCacheCitysFolder;

// clue for improper use (produces compile time error)
+(instancetype) alloc __attribute__((unavailable("alloc not available, call sharedInstance instead")));
-(instancetype) init __attribute__((unavailable("init not available, call sharedInstance instead")));
+(instancetype) new __attribute__((unavailable("new not available, call sharedInstance instead")));

@end
