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
#import "CommonUtility.h"
#import "CustomCalloutView.h"
#import "JSONKit.h"
#import <objc/runtime.h>

@interface MAPolygon (PolygenColor)

- (void) setStrokeColor:(UIColor *)color;
- (UIColor *) strokeColor;
- (void) setFillColor:(UIColor *)color;
- (UIColor *) fillColor;

@end

@implementation MAPolygon (PolygenColor)

static const void * strokeColorKey;
static const void * fillColorKey;

- (void)setStrokeColor:(UIColor *)color {
    objc_setAssociatedObject(self, strokeColorKey, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)strokeColor {
    return objc_getAssociatedObject(self, strokeColorKey);
}

- (void)setFillColor:(UIColor *)color {
    objc_setAssociatedObject(self, fillColorKey, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)fillColor {
    return objc_getAssociatedObject(self, fillColorKey);
}

@end

@interface ViewController ()<MAMapViewDelegate,AMapSearchDelegate>
{
    AMapSearchAPI *_search;
    MAMapView *_mapView;
}

@property (nonatomic,strong) NSMutableDictionary *weatherDict;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self requestWeatherInfo];
    [self setupMapAndSearch];
    [self searchDistricts:@"滨海新区"];
}



# pragma mark - 获取天气信息

- (void)requestWeatherInfo {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://182.92.183.168/weatherRequest.php?101031100"]];
    //将请求的url数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSDictionary *resultDict = [response objectFromJSONData];
    if (!resultDict) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"读取天气信息失败" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSString *city = resultDict[@"c"][@"c3"];
    NSString *tomorrowWeather = resultDict[@"f"][@"f1"][1][@"fa"];
    NSString *tomorrowHighestTemp = resultDict[@"f"][@"f1"][1][@"fc"];
    NSString *tomorrowLowestTemp = resultDict[@"f"][@"f1"][1][@"fd"];
    NSLog(@"%@ %@ %@ %@",city,tomorrowWeather,tomorrowHighestTemp,tomorrowLowestTemp);
    NSArray *cityWeather = [[NSArray alloc]initWithObjects:tomorrowWeather, tomorrowHighestTemp, tomorrowLowestTemp, nil];
    self.weatherDict = [[NSMutableDictionary alloc] init];
    [self.weatherDict setObject:cityWeather forKey:city];
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
    
    //搜索配置
    _search = [[AMapSearchAPI alloc] initWithSearchKey:@"e0ad39f24cfdda6b72bcd826252c96ae" Delegate:self];
    
    
    [self.view addSubview:_mapView];
}

# pragma mark -  搜索行政区域
- (void)searchDistricts:(NSString*)disctrict {
    //构造AMapDistrictSearchRequest对象，keywords为必选项
    AMapDistrictSearchRequest *districtRequest = [[AMapDistrictSearchRequest alloc] init];
    districtRequest.keywords = disctrict;
    districtRequest.requireExtension = YES;
    
    //发起行政区划查询
    [_search AMapDistrictSearch:districtRequest];
}


//实现行政区划查询的回调函数
- (void)onDistrictSearchDone:(AMapDistrictSearchRequest *)request response:(AMapDistrictSearchResponse *)response
{
    //NSLog(@"response: %@", response);
    [self handleDistrictResponse:response];
}
- (void)handleDistrictResponse:(AMapDistrictSearchResponse *)response
{
    if (response == nil)
    {
        return;
    }
    //通过AMapDistrictSearchResponse对象处理搜索结果
    for (AMapDistrict *dist in response.districts)
    {
        MAPointAnnotation *poiAnnotation = [[MAPointAnnotation alloc] init];
        
        poiAnnotation.coordinate = CLLocationCoordinate2DMake(dist.center.latitude, dist.center.longitude);
        poiAnnotation.title      = dist.name;
        NSArray *weatherArray = [[self.weatherDict objectForKey:dist.name] copy];
        if (weatherArray && weatherArray.count >=3 ) {
            NSString *weatherStatus = [NSString stringWithFormat:@"%@ %@~%@℃",weatherArray[0],weatherArray[1],weatherArray[2]];
            poiAnnotation.subtitle   = weatherStatus;
        }
        
        [_mapView addAnnotation:poiAnnotation];
        
        if (dist.polylines.count > 0)
        {
            MAMapRect bounds = MAMapRectZero;
            
            for (NSString *polylineStr in dist.polylines)
            {
                MAPolygon *polygon = [CommonUtility polygonForCoordinateString:polylineStr];
                if (!polygon) {
                    continue;
                }
                
                polygon.strokeColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5];
                polygon.fillColor   = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5];
                
                [_mapView addOverlay:polygon];
                
                bounds = MAMapRectUnion(bounds, polygon.boundingMapRect);
            }
            
            [_mapView setVisibleMapRect:bounds animated:YES];
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
//- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id <MAOverlay>)overlay
//{
//    if ([overlay isKindOfClass:[MAPolygon class]])
//    {
//        MAPolygonView *polygonView = [[MAPolygonView alloc] initWithPolygon:overlay];
//        
//        polygonView.lineWidth = 5.f;
//        polygonView.strokeColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.8];
//        polygonView.fillColor = [UIColor colorWithRed:0.77 green:0.88 blue:0.94 alpha:0.8];
//        //polygonView.lineJoinType = kMALineJoinMiter;//连接类型
//        
//        return polygonView;
//    }
//    return nil;
//}


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
        
        poiAnnotationView.canShowCallout = YES;
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
