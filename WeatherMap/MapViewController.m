//
//  ViewController.m
//  WeatherMap
//
//  Created by Realank on 15/8/9.
//  Copyright (c) 2015年 Realank. All rights reserved.
//

#import "MapViewController.h"
#import "MAMapKit/MAMapKit.h"
#import <AMapSearchKit/AMapSearchAPI.h>
#import <AMapSearchKit/AMapSearchServices.h>
#import "CommonUtility.h"
#import "JSONKit.h"
#import "MAPolygon+PolygenColor.h"
#import "WeatherData.h"
#import "WeatherModel.h"
#import "WeatherStatusMappingModel.h"
#import "CityListModel.h"
#import "SettingData.h"
#import "WindMappingModel.h"
#import "TemperatureColorModel.h"
#import "Reachability.h"

#import "PopUpBigViewForNotice.h"


@interface MapViewController ()<MAMapViewDelegate,AMapSearchDelegate,WeatherDataLoadSuccessDelegate>

@property (nonatomic,strong) AMapSearchAPI *search;
@property (nonatomic,strong) MAMapView *mapView;
@property (nonatomic,strong) WeatherData *weatherData;
@property (nonatomic ,strong) Reachability *reachability;
@property (nonatomic, strong) NSMutableArray *loadedCitys;

@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@end


@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMapAndSearch];
    self.reachability = [Reachability reachabilityForInternetConnection];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.progress.hidden = YES;
    [self.view bringSubviewToFront:self.progress];
    
    if ([CityListModel sharedInstance].selectStatusChanged || [SettingData sharedInstance].settingStatusChanged) {
        [self updateWeatherMap:nil];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showHelpIfFisrUse];

}

- (void)showHelpIfFisrUse {
    
    BOOL firstUse = [[SettingData sharedInstance] isFirstUse];
    BOOL firstUseThisVersion = [[SettingData sharedInstance] isFirstUseThisVersion];
    if (firstUse) {
        PopUpBigViewForNotice *view = [[PopUpBigViewForNotice alloc]initWithFrame:self.view.bounds];
        view.title = @"-欢迎使用天气地图-";
        NSString *filepath = [[NSBundle mainBundle] pathForResource:@"introduce" ofType:@"txt"];
        NSString *content = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
        view.content = content;
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    } else if(firstUseThisVersion){
        PopUpBigViewForNotice *view = [[PopUpBigViewForNotice alloc]initWithFrame:self.view.bounds];
        NSString *bundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSString *title = [NSString stringWithFormat:@"-欢迎使用天气地图%@-",bundleVersion];
        
        view.title = title;
        NSString *filepath = [[NSBundle mainBundle] pathForResource:@"introduceNewVersion" ofType:@"txt"];
        NSString *content = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
        view.content = content;
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    }
}

# pragma mark -  初始化地图和搜索

- (void)setupMapAndSearch {
    //地图配置
    //配置用户Key
    [MAMapServices sharedServices].apiKey = @"e0ad39f24cfdda6b72bcd826252c96ae";
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    self.mapView.delegate = self;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    self.mapView.showsUserLocation = YES;    //YES 为打开定位，NO为关闭定位
    [self.mapView setZoomLevel:6 animated:YES];
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(34, 117) animated:YES];
    
    [self.mapView setUserTrackingMode: MAUserTrackingModeFollow animated:YES];
    [self.view addSubview:self.mapView];
    
    //搜索配置 高德地图SDK2.0配置
    //    self.search = [[AMapSearchAPI alloc] initWithSearchKey:@"e0ad39f24cfdda6b72bcd826252c96ae" Delegate:self];
    
    //搜索配置 高德地图SDK3.0配置
    //配置用户Key
    [AMapSearchServices sharedServices].apiKey = @"e0ad39f24cfdda6b72bcd826252c96ae";
    //初始化检索对象
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
}

- (void)clearMapView
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    
    
}

- (IBAction)updateWeatherMap:(UIBarButtonItem *)sender {
    
    
    [self clearMapView];
    
    if ([self.reachability currentReachabilityStatus] == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"当前无法联网" delegate:nil  cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    } else {
        self.weatherData = [[WeatherData alloc]init];
        self.weatherData.delegate = self;
        [self.weatherData loadWeatherInfoFromProvincesList:[[CityListModel sharedInstance] selectedProvincesNameArray]];
        self.loadedCitys = [NSMutableArray array];
        [self updatePrograss];
    }
    
}

- (void)updatePrograss {
    NSUInteger loadedCityNum = self.loadedCitys.count;
    NSUInteger selectedCityNum = [[CityListModel sharedInstance] selectedCitysArray].count;
    if (loadedCityNum == 0) {
        self.progress.hidden = NO;
        self.progress.progress = 0;
    } else if(loadedCityNum < selectedCityNum) {
        self.progress.progress = loadedCityNum * 1.0/selectedCityNum;
    } else {
        self.progress.hidden = YES;
        self.progress.progress = 0;
    }
}

- (IBAction)locateMyself:(UIBarButtonItem *)sender {
    
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"定位未被许可" message:@"请在\"设置-隐私-定位服务\"中允许此应用的定位功能" delegate:nil  cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    } else {
        [self.mapView setUserTrackingMode: MAUserTrackingModeFollow animated:YES];
        [self.mapView setZoomLevel:6 animated:YES];
    }
}

#pragma mark - 天气读取完毕代理
- (void)weatherDataDidLoad {
    //DWeahtherLog(@"%@",self.weatherData.weatherInfo);
    for (NSString* city in [self.weatherData.weatherInfo allKeys]) {
        
        [self weatherDataDidLoadForCity:city];
        
    }
    
}
- (void)weatherDataDidLoadForCity:(NSString *)city {
    
    if (![self.weatherData.weatherInfo objectForKey:city]) {
        return;
    }

    DWeahtherLog(@"[地理]搜索区域 %@",city);

    [self searchDistricts:city];
}


# pragma mark -  搜索行政区域
- (void)searchDistricts:(NSString*)district {
    //构造AMapDistrictSearchRequest对象，keywords为必选项
    AMapDistrictSearchRequest *districtRequest = [[AMapDistrictSearchRequest alloc] init];
    districtRequest.keywords = district;
    districtRequest.requireExtension = YES;
    //发起行政区划查询
    [self.search AMapDistrictSearch:districtRequest];
}


//实现行政区划查询的回调函数
- (void)onDistrictSearchDone:(AMapDistrictSearchRequest *)request response:(AMapDistrictSearchResponse *)response
{
    if (response == nil)
    {
        DMapLog(@"[地理]请求失败");
        return;
    }
    //通过AMapDistrictSearchResponse对象处理搜索结果
    for (AMapDistrict *dist in response.districts)
    {
        //获取某个城市的天气信息
        WeatherModel* model = [self.weatherData.weatherInfo objectForKey:dist.name];
        if (!model) {
            DMapLog(@"[地理]找不到%@的天气信息！",dist.name);
            continue;
        }
        [self.loadedCitys addObject:dist.name];
        [self updatePrograss];
        WeatherForcast *dayWeather = model.forcast[1];
        switch ([SettingData sharedInstance].weatherTime) {
            case WEA_TODAY:
                dayWeather = model.forcast[0];
                break;
            case WEA_TOMOTTOW:
                dayWeather = model.forcast[1];
                break;
            case WEA_AFTERTOMORROW:
                dayWeather = model.forcast[2];
                break;
        }
        //大头针显示的内容
        NSString *weatherString;
        //轮廓多边形的颜色
        UIColor *color;
        //判断要显示的天气类型：降水情况、气温或者风力
        switch ([SettingData sharedInstance].weatherContent) {
            case WEA_RAIN: {
                NSString* weatherStatus = dayWeather.daytimeStatus;
                weatherString = [NSString stringWithFormat:@"%@ %@~%@℃",[[WeatherStatusMappingModel sharedInstance] stringForKeycode:weatherStatus],dayWeather.nightTemperature,dayWeather.daytimeTemperature];
                if (weatherStatus.length <= 0) {
                    weatherStatus = dayWeather.nightStatus;
                    weatherString = [NSString stringWithFormat:@"%@ %@℃",[[WeatherStatusMappingModel sharedInstance] stringForKeycode:weatherStatus],dayWeather.nightTemperature];
                }
                
                color = [[WeatherStatusMappingModel sharedInstance] colorForKeycode:weatherStatus];

                break;
            }
    
            case WEA_TEMPERATURE:
            {
                NSString* weatherStatus = dayWeather.daytimeStatus;
                NSInteger temperature = ([dayWeather.daytimeTemperature integerValue] + [dayWeather.nightTemperature integerValue])/2;
                weatherString = [NSString stringWithFormat:@"%@ %@~%@℃",[[WeatherStatusMappingModel sharedInstance] stringForKeycode:weatherStatus],dayWeather.nightTemperature,dayWeather.daytimeTemperature];
                if (weatherStatus.length <= 0) {
                    weatherStatus = dayWeather.nightStatus;
                    temperature = [dayWeather.nightTemperature integerValue];
                    weatherString = [NSString stringWithFormat:@"%@ %@℃",[[WeatherStatusMappingModel sharedInstance] stringForKeycode:weatherStatus],dayWeather.nightTemperature];
                }
                
                color = [TemperatureColorModel colorForTemperature:temperature];
                
                break;
            }
                
            case WEA_WIND:
            {
                weatherString = [NSString stringWithFormat:@"%@ %@",[[WindMappingModel sharedInstance] windDirectionForKeycode:dayWeather.daytimeWindDirection],[[WindMappingModel sharedInstance] windStrengthForKeycode:dayWeather.daytimeWindStrength]];
                color = [[WindMappingModel sharedInstance]  colorForWindStrengthKeycode:dayWeather.daytimeWindStrength];
                
                if (dayWeather.daytimeStatus.length <= 0) {
                    weatherString = [NSString stringWithFormat:@"%@ %@",[[WindMappingModel sharedInstance] windDirectionForKeycode:dayWeather.nightWindDirection],[[WindMappingModel sharedInstance] windStrengthForKeycode:dayWeather.nightWindStrength]];
                    color = [[WindMappingModel sharedInstance]  colorForWindStrengthKeycode:dayWeather.nightWindStrength];
                }
                
                break;
            }

        }
        
        
        if ([SettingData sharedInstance].showSpin) {
            //天气信息别针
            MAPointAnnotation *poiAnnotation = [[MAPointAnnotation alloc] init];
            poiAnnotation.coordinate = CLLocationCoordinate2DMake(dist.center.latitude, dist.center.longitude);
            poiAnnotation.title = dist.name;
            poiAnnotation.subtitle   = weatherString;
            [self.mapView addAnnotation:poiAnnotation];
        }
        
        
        UIColor *strokeColor = [color colorWithAlphaComponent:0.8];
        UIColor *fillColor = [color colorWithAlphaComponent:0.6];
        //增加城市轮廓多边形
        if (dist.polylines.count > 0)
        {
            //MAMapRect bounds = MAMapRectZero;
            DMapLog(@"[地理]正在渲染 %@",dist.name);
            for (NSString *polylineStr in dist.polylines)
            {
                MAPolygon *polygon = [CommonUtility polygonForCoordinateString:polylineStr];
                if (!polygon) {
                    continue;
                }
                
                polygon.strokeColor = strokeColor;
                polygon.fillColor   = fillColor;
  
                [self.mapView addOverlay:polygon];
                
                //bounds = MAMapRectUnion(bounds, polygon.boundingMapRect);
            }
            
            //[self.mapView setVisibleMapRect:bounds animated:YES];
        }
        
//        // sub
//        for (AMapDistrict *subdist in dist.districts)
//        {
//            MAPointAnnotation *subAnnotation = [[MAPointAnnotation alloc] init];
//            
//            subAnnotation.coordinate = CLLocationCoordinate2DMake(subdist.center.latitude, subdist.center.longitude);
//            subAnnotation.title      = subdist.name;
//            subAnnotation.subtitle   = subdist.adcode;
//            
//            [self.mapView addAnnotation:subAnnotation];
//            
//        }
    }
}


#pragma mark - MAMapViewDelegate 地图附加层显示

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *busStopIdentifier = @"districtIdentifier";
        
        MAPinAnnotationView *poiAnnotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:busStopIdentifier];
        
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                                reuseIdentifier:busStopIdentifier];
            //poiAnnotationView.pinColor = MAPinAnnotationColorGreen;
            poiAnnotationView.canShowCallout = YES;
            poiAnnotationView.image = [UIImage imageNamed:@"annotation"];
            poiAnnotationView.calloutOffset = CGPointMake(0, 10);
        }
        
        return poiAnnotationView;
    }
    
    return nil;
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MACircle class]])
    {
        MACircleRenderer *circleRenderer = [[MACircleRenderer alloc] initWithCircle:overlay];
        
        circleRenderer.lineWidth   = 4.f;
        circleRenderer.strokeColor = [UIColor blueColor];
        circleRenderer.fillColor   = [UIColor colorWithRed:1 green:0 blue:0 alpha:.3];
        
        return circleRenderer;
    }
    else if ([overlay isKindOfClass:[MAPolygon class]])
    {
        MAPolygonRenderer *polygonRenderer = [[MAPolygonRenderer alloc] initWithPolygon:overlay];
        polygonRenderer.lineWidth   = 4.f;
        polygonRenderer.strokeColor = ((MAPolygon*)overlay).strokeColor;
        polygonRenderer.fillColor   = ((MAPolygon*)overlay).fillColor;

        
        return polygonRenderer;
    }
    else if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        
        polylineRenderer.lineWidth   = 4.f;
        polylineRenderer.strokeColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:1];
        
        return polylineRenderer;
    }
    if ([overlay isKindOfClass:[MAGroundOverlay class]])
    {
        MAGroundOverlayRenderer *groundOverlayRenderer = [[MAGroundOverlayRenderer alloc] initWithGroundOverlay:overlay];
        [groundOverlayRenderer setAlpha:0.6];
        
        return groundOverlayRenderer;
    }
    
    return nil;
}


# pragma mark - 定位更新

-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    if(updatingLocation)
    {
        //取出当前位置的坐标
      //  NSLog(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
        
    }
}

@end
