//
//  CommonUtility.m
//  SearchV3Demo
//
//  Created by songjian on 13-8-22.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "CommonUtility.h"
#import "LineDashPolyline.h"

@implementation CommonUtility

+ (NSArray *)shortCoordinatesArrByString:(NSString *)string withParseToken:(NSString *)token maxCount:(NSUInteger)maxCount minCount:(NSUInteger)minCount{
    NSMutableArray *arr = [NSMutableArray array];
    
    if (string.length <= 0) {
        return nil;
    }
    if (token == nil) {
        token = @",";
    }
    NSArray *components = [string componentsSeparatedByString:token];
    
    NSInteger componentCount = [components count];
    if (componentCount < minCount) {
        return nil;
    }

    NSInteger times = componentCount/maxCount;
    if (componentCount < maxCount) {
        times = 1;
        maxCount = componentCount;
    }

    for (int i = 0; i < maxCount; i++) {
        NSArray *coord = [[components objectAtIndex:times * i] componentsSeparatedByString:@","];
        if (coord.count != 2) {
            continue;
        }
        NSNumber *longitude = [NSNumber numberWithDouble:[coord[0] doubleValue]];
        [arr addObject:longitude];
        NSNumber *latitude = [NSNumber numberWithDouble:[coord[1] doubleValue]];
        [arr addObject:latitude];
    }
    
    NSArray *coord = [[components objectAtIndex:0] componentsSeparatedByString:@","];
    if (coord.count == 2) {
        NSNumber *longitude = [NSNumber numberWithDouble:[coord[0] doubleValue]];
        [arr addObject:longitude];
        NSNumber *latitude = [NSNumber numberWithDouble:[coord[1] doubleValue]];
        [arr addObject:latitude];
    }

    return [arr copy];

}


+ (CLLocationCoordinate2D *)coordinatesForArr:(NSArray *)arr
                                 coordinateCount:(NSUInteger *)coordinateCount
{
    if (arr == nil) {
        *coordinateCount = 0;
        return NULL;
    }

    NSInteger count = arr.count/2;
    
    if (coordinateCount != NULL) {
        *coordinateCount = count;
    }
    
    CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D*)malloc(count * sizeof(CLLocationCoordinate2D));
    
    for (int i = 0; i < count; i++) {
        NSNumber *longitude = arr[i*2];
        coordinates[i].longitude = [longitude doubleValue];
        NSNumber *latitude = arr[i*2+1];
        coordinates[i].latitude  = [latitude doubleValue];
    }
    
    return coordinates;
}

+ (MAPolygon *)polygonForCoordinateArr:(NSArray *)coordinatesArr
{
    if (coordinatesArr.count == 0)
    {
        return nil;
    }
    
    NSUInteger count = 0;
    
    CLLocationCoordinate2D *coordinates = [self coordinatesForArr:coordinatesArr coordinateCount:&count];
    if (!coordinates) {
        return nil;
    }
    
    MAPolygon *polygon = [MAPolygon polygonWithCoordinates:coordinates count:count];
    
    free(coordinates), coordinates = NULL;
    
    return polygon;
}

+ (MAPolyline *)polylineForCoordinateArr:(NSArray *)coordinatesArr
{
    if (coordinatesArr.count == 0)
    {
        return nil;
    }
    
    NSUInteger count = 0;
    CLLocationCoordinate2D *coordinates = [self coordinatesForArr:coordinatesArr coordinateCount:&count];
    
    if (!coordinates) {
        return nil;
    }
    MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coordinates count:count];
    
    free(coordinates), coordinates = NULL;
    
    return polyline;
}

+ (MAPolygon *)polygonForCoordinateString:(NSString *)coordinateString
{
    if (coordinateString.length == 0)
    {
        return nil;
    }
    
    NSUInteger count = 0;
    
    CLLocationCoordinate2D *coordinates = [self coordinatesForString:coordinateString
                                                     coordinateCount:&count
                                                          parseToken:@";"];
    if (!coordinates) {
        return nil;
    }
    
    MAPolygon *polygon = [MAPolygon polygonWithCoordinates:coordinates count:count];
    
    free(coordinates), coordinates = NULL;
    
    return polygon;
}

+ (MAPolyline *)polylineForCoordinateString:(NSString *)coordinateString
{
    if (coordinateString.length == 0)
    {
        return nil;
    }
    
    NSUInteger count = 0;
    
    CLLocationCoordinate2D *coordinates = [self coordinatesForString:coordinateString
                                                     coordinateCount:&count
                                                          parseToken:@";"];
    if (!coordinates) {
        return nil;
    }
    MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coordinates count:count];
    
    free(coordinates), coordinates = NULL;
    
    return polyline;
}

+ (CLLocationCoordinate2D *)coordinatesForString:(NSString *)string
                                 coordinateCount:(NSUInteger *)coordinateCount
                                      parseToken:(NSString *)token
{
    if (string == nil) {
        return NULL;
    }
    if (token == nil) {
        token = @",";
    }
    NSString *str = @"";
    if (![token isEqualToString:@","]) {
        str = [string stringByReplacingOccurrencesOfString:token withString:@","];
    }
    else {
        str = [NSString stringWithString:string];
    }
    NSArray *components = [str componentsSeparatedByString:@","];
    
    NSInteger componentCount = [components count];
    if (componentCount < 500) {
        *coordinateCount = 0;
        return NULL;
    }
    NSInteger count = 200;
    NSInteger times = componentCount/count/2*2;
    if (coordinateCount != NULL) {
        *coordinateCount = count+1;
    }
    CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D*)malloc((count+1) * sizeof(CLLocationCoordinate2D));
    
    for (int i = 0; i < count; i++) {
        coordinates[i].longitude = [[components objectAtIndex:times * i]     doubleValue];
        coordinates[i].latitude  = [[components objectAtIndex:times * i + 1] doubleValue];
    }
    coordinates[count].longitude = [[components objectAtIndex:0]     doubleValue];
    coordinates[count].latitude  = [[components objectAtIndex:1] doubleValue];
    
    return coordinates;
}


+ (MAPolyline *)polylineForStep:(AMapStep *)step
{
    if (step == nil)
    {
        return nil;
    }
    
    return [self polylineForCoordinateString:step.polyline];
}

+ (MAPolyline *)polylineForBusLine:(AMapBusLine *)busLine
{
    if (busLine == nil)
    {
        return nil;
    }
    
    return [self polylineForCoordinateString:busLine.polyline];
}

+(void)replenishPolylinesForWalkingWiht:(MAPolyline *)stepPolyline
                           LastPolyline:(MAPolyline *)lastPolyline
                              Polylines:(NSMutableArray *)polylines
                                Walking:(AMapWalking *)walking
{
    CLLocationCoordinate2D startCoor ;
    CLLocationCoordinate2D endCoor;
    
    CLLocationCoordinate2D points[2];
    
    [stepPolyline getCoordinates:&endCoor   range:NSMakeRange(0, 1)];
    [lastPolyline getCoordinates:&startCoor range:NSMakeRange(lastPolyline.pointCount -1, 1)];
    
    if (endCoor.latitude != startCoor.latitude || endCoor.longitude != startCoor.longitude)
    {
        points[0] = startCoor;
        points[1] = endCoor;
        
        MAPolyline *polyline = [MAPolyline polylineWithCoordinates:points count:2];
        LineDashPolyline *dathPolyline = [[LineDashPolyline alloc] initWithPolyline:polyline];
        dathPolyline.polyline = polyline;
        [polylines addObject:dathPolyline];
        
    }
    
}

+ (NSArray *)polylinesForWalking:(AMapWalking *)walking
{
    if (walking == nil || walking.steps.count == 0)
    {
        return nil;
    }
    
    NSMutableArray *polylines = [NSMutableArray array];
    
    [walking.steps enumerateObjectsUsingBlock:^(AMapStep *step, NSUInteger idx, BOOL *stop) {
        
        MAPolyline *stepPolyline = [self polylineForStep:step];
        
        
        if (stepPolyline != nil)
        {
            [polylines addObject:stepPolyline];
            if (idx > 0)
            {
                [self replenishPolylinesForWalkingWiht:stepPolyline LastPolyline:[self polylineForStep:[walking.steps objectAtIndex:idx - 1]] Polylines:polylines Walking:walking];
            }
        }
        
    }];
    
    return polylines;
}

+ (void)replenishPolylinesForSegment:(NSArray *)walkingPolylines
                     busLinePolyline:(MAPolyline *)busLinePolyline
                             Segment:(AMapSegment *)segment
                           polylines:(NSMutableArray *)polylines
{
    if (walkingPolylines.count != 0)
    {
        AMapGeoPoint *walkingEndPoint = segment.walking.destination ;
        
        if (busLinePolyline)
        {
            CLLocationCoordinate2D startCoor;
            CLLocationCoordinate2D endCoor ;
            [busLinePolyline getCoordinates:&startCoor range:NSMakeRange(0, 1)];
            [busLinePolyline getCoordinates:&endCoor range:NSMakeRange(busLinePolyline.pointCount-1, 1)];
            
            if (startCoor.latitude != walkingEndPoint.latitude || startCoor.longitude != walkingEndPoint.longitude)
            {
                CLLocationCoordinate2D points[2];
                points[0] = CLLocationCoordinate2DMake(walkingEndPoint.latitude, walkingEndPoint.longitude);
                points[1] = startCoor ;
                
                MAPolyline *polyline = [MAPolyline polylineWithCoordinates:points count:2];
                LineDashPolyline *dathPolyline = [[LineDashPolyline alloc] initWithPolyline:polyline];
                dathPolyline.polyline = polyline;
                [polylines addObject:dathPolyline];
            }
        }
    }
    
}

+ (NSArray *)polylinesForSegment:(AMapSegment *)segment
{
    if (segment == nil)
    {
        return nil;
    }
    
    NSMutableArray *polylines = [NSMutableArray array];
    
    NSArray *walkingPolylines = [self polylinesForWalking:segment.walking];
    if (walkingPolylines.count != 0)
    {
        [polylines addObjectsFromArray:walkingPolylines];
    }
    
    MAPolyline *busLinePolyline = [self polylineForBusLine:[segment.buslines firstObject]];
    if (busLinePolyline != nil)
    {
        [polylines addObject:busLinePolyline];
    }
    [self replenishPolylinesForSegment:walkingPolylines busLinePolyline:busLinePolyline Segment:segment polylines:polylines];
    
    return polylines;
}

+ (void)replenishPolylinesForPathWith:(MAPolyline *)stepPolyline
                         lastPolyline:(MAPolyline *)lastPolyline
                            Polylines:(NSMutableArray *)polylines
{
    CLLocationCoordinate2D startCoor ;
    CLLocationCoordinate2D endCoor;
    
    [stepPolyline getCoordinates:&endCoor range:NSMakeRange(0, 1)];
    
    [lastPolyline getCoordinates:&startCoor range:NSMakeRange(lastPolyline.pointCount -1, 1)];
    
    
    if ((endCoor.latitude != startCoor.latitude || endCoor.longitude != startCoor.longitude ))
    {
        CLLocationCoordinate2D points[2];
        points[0] = startCoor;
        points[1] = endCoor;
        
        MAPolyline *polyline = [MAPolyline polylineWithCoordinates:points count:2];
        LineDashPolyline *dathPolyline = [[LineDashPolyline alloc] initWithPolyline:polyline];
        dathPolyline.polyline = polyline;
        [polylines addObject:dathPolyline];
    }
}

+ (NSArray *)polylinesForPath:(AMapPath *)path
{
    if (path == nil || path.steps.count == 0)
    {
        return nil;
    }
    
    NSMutableArray *polylines = [NSMutableArray array];
    
    [path.steps enumerateObjectsUsingBlock:^(AMapStep *step, NSUInteger idx, BOOL *stop) {
        
        MAPolyline *stepPolyline = [self polylineForStep:step];
        
        if (stepPolyline != nil)
        {
            [polylines addObject:stepPolyline];
            
            if (idx > 0 )
            {
                [self replenishPolylinesForPathWith:stepPolyline lastPolyline:[self polylineForStep:[path.steps objectAtIndex:idx-1]]  Polylines:polylines];
            }
        }
    }];
    
    return polylines;
}

+ (void)replenishPolylinesForTransit:(AMapSegment *)lastSegment
                      CurrentSegment:(AMapSegment * )segment
                           Polylines:(NSMutableArray *)polylines
{
    if (lastSegment)
    {
        CLLocationCoordinate2D startCoor;
        CLLocationCoordinate2D endCoor;
        
        MAPolyline *busLinePolyline = [self polylineForBusLine:[(lastSegment).buslines firstObject]];
        if (busLinePolyline != nil)
        {
            [busLinePolyline getCoordinates:&startCoor range:NSMakeRange(busLinePolyline.pointCount-1, 1)];
        }
        else
        {
            if ((lastSegment).walking && [(lastSegment).walking.steps count] != 0)
            {
                startCoor.latitude  = (lastSegment).walking.destination.latitude;
                startCoor.longitude = (lastSegment).walking.destination.longitude;
            }
            else
            {
                return;
            }
        }
        
        if ((segment).walking && [(segment).walking.steps count] != 0)
        {
            AMapStep *step = [(segment).walking.steps objectAtIndex:0];
            MAPolyline *stepPolyline = [self polylineForStep:step];
            
            [stepPolyline getCoordinates:&endCoor range:NSMakeRange(0 , 1)];
        }
        else
        {
            
            MAPolyline *busLinePolyline = [self polylineForBusLine:[(segment).buslines firstObject]];
            if (busLinePolyline != nil)
            {
                [busLinePolyline getCoordinates:&endCoor range:NSMakeRange(0 , 1)];
            }
            else
            {
                return;
            }
        }
        
        CLLocationCoordinate2D points[2];
        points[0] = startCoor;
        points[1] = endCoor ;
        
        MAPolyline *polyline = [MAPolyline polylineWithCoordinates:points count:2];
        LineDashPolyline *dathPolyline = [[LineDashPolyline alloc] initWithPolyline:polyline];
        dathPolyline.polyline = polyline;
        [polylines addObject:dathPolyline];
    }
}

+ (NSArray *)polylinesForTransit:(AMapTransit *)transit
{
    if (transit == nil || transit.segments.count == 0)
    {
        return nil;
    }
    
    NSMutableArray *polylines = [NSMutableArray array];
    
    [transit.segments enumerateObjectsUsingBlock:^(AMapSegment *segment, NSUInteger idx, BOOL *stop) {
        
        NSArray *segmentPolylines = [self polylinesForSegment:segment];
        
        if (segmentPolylines.count != 0)
        {
            [polylines addObjectsFromArray:segmentPolylines];
        }
        if (idx >0)
        {
            [self replenishPolylinesForTransit:[transit.segments objectAtIndex:idx-1] CurrentSegment:segment Polylines:polylines];
            
        }
    }];
    
    return polylines;
}

+ (MAMapRect)unionMapRect1:(MAMapRect)mapRect1 mapRect2:(MAMapRect)mapRect2
{
    CGRect rect1 = CGRectMake(mapRect1.origin.x, mapRect1.origin.y, mapRect1.size.width, mapRect1.size.height);
    CGRect rect2 = CGRectMake(mapRect2.origin.x, mapRect2.origin.y, mapRect2.size.width, mapRect2.size.height);
    
    CGRect unionRect = CGRectUnion(rect1, rect2);
    
    return MAMapRectMake(unionRect.origin.x, unionRect.origin.y, unionRect.size.width, unionRect.size.height);
}

+ (MAMapRect)mapRectUnion:(MAMapRect *)mapRects count:(NSUInteger)count
{
    if (mapRects == NULL || count == 0)
    {
        DMapLog(@"%s: 无效的参数.", __func__);
        return MAMapRectZero;
    }
    
    MAMapRect unionMapRect = mapRects[0];
    
    for (int i = 1; i < count; i++)
    {
        unionMapRect = [self unionMapRect1:unionMapRect mapRect2:mapRects[i]];
    }
    
    return unionMapRect;
}

+ (MAMapRect)mapRectForOverlays:(NSArray *)overlays
{
    if (overlays.count == 0)
    {
        DMapLog(@"%s: 无效的参数.", __func__);
        return MAMapRectZero;
    }
    
    MAMapRect mapRect;
    
    MAMapRect *buffer = (MAMapRect*)malloc(overlays.count * sizeof(MAMapRect));
    
    [overlays enumerateObjectsUsingBlock:^(id<MAOverlay> obj, NSUInteger idx, BOOL *stop) {
        buffer[idx] = [obj boundingMapRect];
    }];
    
    mapRect = [self mapRectUnion:buffer count:overlays.count];
    
    free(buffer), buffer = NULL;
    
    return mapRect;
}

+ (MAMapRect)minMapRectForMapPoints:(MAMapPoint *)mapPoints count:(NSUInteger)count
{
    if (mapPoints == NULL || count <= 1)
    {
        DMapLog(@"%s: 无效的参数.", __func__);
        return MAMapRectZero;
    }
    
    CGFloat minX = mapPoints[0].x, minY = mapPoints[0].y;
    CGFloat maxX = minX, maxY = minY;
    
    /* Traverse and find the min, max. */
    for (int i = 1; i < count; i++)
    {
        MAMapPoint point = mapPoints[i];
        
        if (point.x < minX)
        {
            minX = point.x;
        }
        
        if (point.x > maxX)
        {
            maxX = point.x;
        }
        
        if (point.y < minY)
        {
            minY = point.y;
        }
        
        if (point.y > maxY)
        {
            maxY = point.y;
        }
    }
    
    /* Construct outside min rectangle. */
    return MAMapRectMake(minX, minY, fabs(maxX - minX), fabs(maxY - minY));
}

+ (MAMapRect)minMapRectForAnnotations:(NSArray *)annotations
{
    if (annotations.count <= 1)
    {
        DMapLog(@"%s: 无效的参数.", __func__);
        return MAMapRectZero;
    }
    
    MAMapPoint *mapPoints = (MAMapPoint*)malloc(annotations.count * sizeof(MAMapPoint));
    
    [annotations enumerateObjectsUsingBlock:^(id<MAAnnotation> obj, NSUInteger idx, BOOL *stop) {
        mapPoints[idx] = MAMapPointForCoordinate([obj coordinate]);
    }];
    
    MAMapRect minMapRect = [self minMapRectForMapPoints:mapPoints count:annotations.count];
    
    free(mapPoints), mapPoints = NULL;
    
    return minMapRect;
}

@end
