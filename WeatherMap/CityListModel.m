//
//  CityListModel.m
//  WeatherMap
//
//  Created by Realank on 15/10/14.
//  Copyright © 2015年 Realank. All rights reserved.
//

#import "CityListModel.h"
#import <MobClick.h>
#import "SettingData.h"



@implementation ProvinceInfo


@end

@interface CityListModel ()

@property (nonatomic, strong) NSMutableDictionary *allCityList;

@end

@implementation CityListModel

- (NSMutableDictionary *)allCityList {
    if (!_allCityList) {
        _allCityList = [NSMutableDictionary dictionary];
    }
    return _allCityList;
}


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
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"CityList" ofType:@"plist"];
        NSDictionary *allProvincesDict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        if (!allProvincesDict) {
            return nil;
        }
        NSMutableDictionary *provinceDictM = [NSMutableDictionary dictionary];
        for(NSString *provinceName in [allProvincesDict allKeys]) {
            NSDictionary *aProvinceDict = [allProvincesDict objectForKey:provinceName];
            if (!aProvinceDict) {
                continue;
            }
            ProvinceInfo *provinceModel = [[ProvinceInfo alloc]init];
            NSString *shortCut = [aProvinceDict objectForKey:@"shortcut"];
            if (!shortCut) {
                continue;
            } else {
                provinceModel.shortCut = shortCut;
            }
            NSDictionary *citys = [aProvinceDict objectForKey:@"citys"];
            if ([citys allKeys].count <= 0) {
                continue;
            } else {
                provinceModel.citysDict = citys;
                [self.allCityList addEntriesFromDictionary:citys];
            }
            
            [provinceDictM setValue:provinceModel forKey:provinceName];
            
        }
        self.provinceDict = [provinceDictM copy];
        
        NSArray *list = [[NSUserDefaults standardUserDefaults] objectForKey:@"ProvinceList"];
        if (!list) {
            list = @[@"河北省",@"北京市",@"天津市"];
//            [[NSUserDefaults standardUserDefaults] setObject:list forKey:@"ProvinceList"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        _selectedProvincesNameArray = [list mutableCopy];
        self.selectStatusChanged = YES;
        
        
        
        __weak __typeof(self) weakSelf = self;
        //根据省份城市的编号，排序省份，并保存到列表中
        self.provincesNameArray = [[self.provinceDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString*  _Nonnull obj1, NSString*  _Nonnull obj2) {
            ProvinceInfo *province1 = [weakSelf.provinceDict objectForKey:obj1];
            ProvinceInfo *province2 = [weakSelf.provinceDict objectForKey:obj2];
            NSUInteger pvc1_OneCityCode = [province1.citysDict.allKeys[0] integerValue];
            NSUInteger pvc2_OneCityCode = [province2.citysDict.allKeys[0] integerValue];
            
            return pvc1_OneCityCode > pvc2_OneCityCode ? NSOrderedDescending : NSOrderedAscending;
        }];
        
    }
    
    return self;
}

-(NSString *)cityNameForAreaCode:(NSString *)areaCode {
    return [self.allCityList objectForKey:areaCode];
}

//超出选择数量上限，如果不是CrazyMode，会停止添加，并且返回NO
//               如果是CrazyMode，会继续添加，但是依然返回NO
-(BOOL)changeProvinceSelectStatus:(NSString *)provinceName{
    
    BOOL canfind = NO;
    BOOL crazyMode = NO;
    for (NSString *provinceInArr in [self.selectedProvincesNameArray copy]) {
        if ([provinceInArr isEqualToString:provinceName]) {
            canfind = YES;
            [self.selectedProvincesNameArray removeObject:provinceInArr];
            break;
        }
    }
    if (!canfind) {
        crazyMode = [SettingData sharedInstance].crazyMode;
        if (self.selectedProvincesNameArray.count > MAX_CITY_NUM-1 && !crazyMode) {
            return NO;
        }
        [self.selectedProvincesNameArray addObject:provinceName];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [MobClick event:@"ChangeProvince"label:[NSString stringWithFormat:@"add:%@",provinceName]];
        });
    }
    self.selectStatusChanged = YES;
//    __weak __typeof(self) weakSelf = self;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [[NSUserDefaults standardUserDefaults] setObject:[weakSelf.selectedProvincesNameArray copy]forKey:@"ProvinceList"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    });
    
    if (crazyMode && self.selectedProvincesNameArray.count == MAX_CITY_NUM+1) {
        return NO;
    }
    return YES;
}

-(void)decreaseSelectedProvincesNumTo:(NSUInteger)num {
    self.selectStatusChanged = YES;
    
    while (self.selectedProvincesNameArray.count > num) {
        [self.selectedProvincesNameArray removeObjectAtIndex:0];
    }
//    __weak __typeof(self) weakSelf = self;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [[NSUserDefaults standardUserDefaults] setObject:[weakSelf.selectedProvincesNameArray copy]forKey:@"ProvinceList"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    });
    
}

- (void)clearAllSelection {
    self.selectStatusChanged = YES;
    _selectedProvincesNameArray = [NSMutableArray array];

//    __weak __typeof(self) weakSelf = self;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [[NSUserDefaults standardUserDefaults] setObject:[weakSelf.selectedProvincesNameArray copy]forKey:@"ProvinceList"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    });
}

-(bool)isInSelectedProvinces:(NSString *)provinceName {
    for (NSString *provinceInArr in self.selectedProvincesNameArray) {
        if ([provinceInArr isEqualToString:provinceName]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)selectStatusChanged {
    BOOL ret = _selectStatusChanged;
    _selectStatusChanged = NO;
    
    return ret;
}

- (NSArray *)selectedCitysArray {
    
    NSDictionary *dict = self.provinceDict;
    NSMutableArray *cityarr = [NSMutableArray array];
    
    for (NSString *provinceName in self.selectedProvincesNameArray) {
        ProvinceInfo *province = [dict objectForKey:provinceName];
        if (!province) {
            continue;
        }
        NSDictionary *citysDict = province.citysDict;
        if (!citysDict) {
            continue;
        }
        for (NSString* cityCodeStr in [citysDict allKeys]) {
            NSString* cityName = [citysDict objectForKey:cityCodeStr];
            [cityarr addObject:cityName];
        }
    }
    return [cityarr copy];
}

- (void)syncProvinceSelectionStatusInROM {
    [[NSUserDefaults standardUserDefaults] setObject:[self.selectedProvincesNameArray copy]forKey:@"ProvinceList"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)dealloc {
    [self syncProvinceSelectionStatusInROM];
}

@end
