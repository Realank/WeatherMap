//
//  ViewController.m
//  WeatherMap
//
//  Created by Realank on 15/8/9.
//  Copyright (c) 2015年 Realank. All rights reserved.
//

#import "ViewController.h"
#import "MAMapKit/MAMapKit.h"
#import <AMapSearchKit/AMapSearchAPI.h>
#import <AMapSearchKit/AMapSearchServices.h>
#import "CommonUtility.h"
#import "JSONKit.h"
#import "MAPolygon+PolygenColor.h"
#import "WeatherData.h"
#import "WeatherModel.h"


@interface ViewController ()<MAMapViewDelegate,AMapSearchDelegate,WeatherDataLoadSuccessDelegate>
{
    AMapSearchAPI *_search;
    MAMapView *_mapView;
    WeatherData *_weatherData;
    NSMutableDictionary *_weatherStatus;
}

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"WeatherStatusMapping" ofType:@"plist"];
    _weatherStatus = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    [self setupMapAndSearch];
    
    _weatherData = [[WeatherData alloc]init];
    _weatherData.delegate = self;
    [_weatherData loadWeatherInfo];

}


#pragma mark - 天气读取完毕代理
- (void)weatherDataDidLoad {
    //NSLog(@"%@",_weatherData.weatherInfo);
    for (NSString* city in [_weatherData.weatherInfo allKeys]) {
        
        [self weatherDataDidLoadForCity:city];
        
    }
    
}
- (void)weatherDataDidLoadForCity:(NSString *)city {
    
    if (![_weatherData.weatherInfo objectForKey:city]) {
        return;
    }

    NSLog(@"[地理]搜索区域%@",city);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10* NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        [self searchDistricts:city];
    });

    
}


# pragma mark -  初始化地图和搜索

- (void)setupMapAndSearch {
    //地图配置
    //配置用户Key
    [MAMapServices sharedServices].apiKey = @"e0ad39f24cfdda6b72bcd826252c96ae";
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    _mapView.delegate = self;
    _mapView.showsCompass = NO;
    _mapView.showsScale = NO;
    _mapView.showsUserLocation = YES;    //YES 为打开定位，NO为关闭定位
    [_mapView setUserTrackingMode: MAUserTrackingModeFollow animated:YES];
    [self.view addSubview:_mapView];
    
    //搜索配置 高德地图SDK2.0配置
//    _search = [[AMapSearchAPI alloc] initWithSearchKey:@"e0ad39f24cfdda6b72bcd826252c96ae" Delegate:self];
    
    //搜索配置 高德地图SDK3.0配置
    //配置用户Key
    [AMapSearchServices sharedServices].apiKey = @"e0ad39f24cfdda6b72bcd826252c96ae";
    //初始化检索对象
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;

}

# pragma mark -  搜索行政区域
- (void)searchDistricts:(NSString*)district {
    //构造AMapDistrictSearchRequest对象，keywords为必选项
    AMapDistrictSearchRequest *districtRequest = [[AMapDistrictSearchRequest alloc] init];
    districtRequest.keywords = district;
    districtRequest.requireExtension = YES;
    //发起行政区划查询
    [_search AMapDistrictSearch:districtRequest];
}


//实现行政区划查询的回调函数
- (void)onDistrictSearchDone:(AMapDistrictSearchRequest *)request response:(AMapDistrictSearchResponse *)response
{
    if (response == nil)
    {
        NSLog(@"[地理]请求失败");
        return;
    }
    //通过AMapDistrictSearchResponse对象处理搜索结果
    for (AMapDistrict *dist in response.districts)
    {
        //天气信息别针
        MAPointAnnotation *poiAnnotation = [[MAPointAnnotation alloc] init];
        poiAnnotation.coordinate = CLLocationCoordinate2DMake(dist.center.latitude, dist.center.longitude);
        poiAnnotation.title = dist.name;
        WeatherModel* model = [_weatherData.weatherInfo objectForKey:dist.name];
        WeatherForcast *tomorrowWeather = model.forcast[1];
        NSArray *weatherStautsToColor = [[_weatherStatus objectForKey:tomorrowWeather.daytimeStatus] copy];

            
        NSString *weatherString = [NSString stringWithFormat:@"%@ %@~%@℃",weatherStautsToColor[0],tomorrowWeather.nightTemperature,tomorrowWeather.daytimeTemperature];
        poiAnnotation.subtitle   = weatherString;

        [_mapView addAnnotation:poiAnnotation];
        
        
        //增加城市轮廓多边形
        if (dist.polylines.count > 0)
        {
            //MAMapRect bounds = MAMapRectZero;
            NSLog(@"[地理]正在渲染 %@",dist.name);
            for (NSString *polylineStr in dist.polylines)
            {
                MAPolygon *polygon = [CommonUtility polygonForCoordinateString:polylineStr];
                if (!polygon) {
                    continue;
                }
                NSUInteger rgbColor = [weatherStautsToColor[1] integerValue];
                //NSLog(@"color : %ld",rgbColor);
                polygon.strokeColor = [UIColor colorWithRed:rgbColor/0x10000/255.0 green:rgbColor%0x10000/0x100/255.0 blue:rgbColor%0x100/255.0 alpha:0.8];
                polygon.fillColor   = [UIColor colorWithRed:rgbColor/0x10000/255.0 green:rgbColor%0x10000/0x100/255.0 blue:rgbColor%0x100/255.0 alpha:0.6];
                
                [_mapView addOverlay:polygon];
                
                //bounds = MAMapRectUnion(bounds, polygon.boundingMapRect);
            }
            
            //[_mapView setVisibleMapRect:bounds animated:YES];
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
//            [_mapView addAnnotation:subAnnotation];
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
        }
        //poiAnnotationView.pinColor = MAPinAnnotationColorGreen;
        poiAnnotationView.canShowCallout = YES;
        poiAnnotationView.image = [UIImage imageNamed:@"annotation"];
        poiAnnotationView.calloutOffset = CGPointMake(0, 10);
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
