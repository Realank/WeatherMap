//
//  CutlineTableViewController.m
//  WeatherMap
//
//  Created by Realank on 15/8/21.
//  Copyright (c) 2015年 Realank. All rights reserved.
//

#import "CutlineTableViewController.h"
#import "CutlineTableViewCell.h"
#define CELL_HEIGHT 50.0


@interface CutlineTableViewController (){
    NSMutableDictionary *_weatherStatusDict;
    NSArray *_weatherIndexArray;
}

@end

@implementation CutlineTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"天气图例";
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"WeatherStatusMapping" ofType:@"plist"];
    _weatherStatusDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    _weatherIndexArray = [_weatherStatusDict.allKeys sortedArrayUsingComparator: ^(id obj1, id obj2) {
        
        
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
        
        
    }];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    NSUInteger row = indexPath.row;
    
    
    CutlineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (!cell) {
        NSLog(@"找不到cell");
    }

    NSArray *weatherStautsToColor = [_weatherStatusDict objectForKey:_weatherIndexArray[row]];
    cell.cutlineModel = weatherStautsToColor;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _weatherIndexArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
@end
