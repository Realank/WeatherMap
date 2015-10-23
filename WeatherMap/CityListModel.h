//
//  CityListModel.h
//  WeatherMap
//
//  Created by Realank on 15/10/14.
//  Copyright © 2015年 Realank. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAX_CITY_NUM 5

@interface ProvinceInfo : NSObject

@property (nonatomic, strong) NSString *shortCut;
@property (nonatomic, strong) NSDictionary *citysDict;

@end

@interface CityListModel : NSObject


@property (nonatomic ,strong) NSDictionary *provinceDict;
@property (nonatomic ,strong) NSArray *provincesNameArray;
@property (nonatomic ,strong, readonly) NSMutableArray *selectedProvincesNameArray;
@property (nonatomic ,assign) BOOL selectStatusChanged;

+(instancetype) sharedInstance;
-(BOOL)changeProvinceSelectStatus:(NSString *)provinceName;
-(BOOL)isInSelectedProvinces:(NSString *)provinceName;
-(NSString *)cityNameForAreaCode:(NSString *)areaCode;
- (NSArray *)selectedCitysArray;

// clue for improper use (produces compile time error)
+(instancetype) alloc __attribute__((unavailable("alloc not available, call sharedInstance instead")));
-(instancetype) init __attribute__((unavailable("init not available, call sharedInstance instead")));
+(instancetype) new __attribute__((unavailable("new not available, call sharedInstance instead")));



@end
