//
//  CutlineTableViewController.m
//  WeatherMap
//
//  Created by Realank on 15/8/21.
//  Copyright (c) 2015年 Realank. All rights reserved.
//

#import "CutlineTableViewController.h"
#import "CutlineTableViewCell.h"
#import "WeatherStatusMappingModel.h"
#import "SettingData.h"
#import "WindMappingModel.h"
#import "TemperatureColorModel.h"
#define CELL_HEIGHT 50.0

@interface CutlineTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *describeLabel;

@end

@implementation CutlineTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTitle) name:@"SettingWeatherContentChanged" object:nil];
    [self updateTitle];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(void)updateTitle {
    switch ([SettingData sharedInstance].weatherContent) {
        case WEA_RAIN:
        {
            self.describeLabel.text = @"天气";
            break;
        }
            
        case WEA_TEMPERATURE:
        {
            self.describeLabel.text = @"气温";
            break;
        }
            
        case WEA_WIND:
        {
            self.describeLabel.text = @"风力";
            break;
        }
    }

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    NSUInteger row = indexPath.row;
    
    
    CutlineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier2"];
    if (!cell) {
        DMapLog(@"找不到cell");
    }
    
    switch ([SettingData sharedInstance].weatherContent) {
        case WEA_RAIN:
        {
            NSString *keycode = [[[WeatherStatusMappingModel sharedInstance] sortedKeyCodes] objectAtIndex:row];
            
            NSArray *weatherStautsToColor = [NSArray arrayWithObjects:[[WeatherStatusMappingModel sharedInstance] stringForKeycode:keycode], [[[WeatherStatusMappingModel sharedInstance] colorForKeycode:keycode] colorWithAlphaComponent:0.6], nil];
            cell.cutlineModel = weatherStautsToColor;
            break;
        }
            
        case WEA_TEMPERATURE:
        {
            NSInteger tem = (indexPath.row - 10)*5;
            NSArray *weatherTempToColor = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld℃",(long)tem], [TemperatureColorModel colorForTemperature:tem], nil];
             cell.cutlineModel = weatherTempToColor;
            break;
        }
            
        case WEA_WIND:
        {
            NSString *keycode = [[[WindMappingModel sharedInstance] sortedKeyCodes] objectAtIndex:row];
            
            NSArray *weatherStautsToColor = [NSArray arrayWithObjects:[[WindMappingModel sharedInstance] windStrengthForKeycode:keycode], [[WindMappingModel sharedInstance] colorForWindStrengthKeycode:keycode], nil];
            cell.cutlineModel = weatherStautsToColor;
            break;
        }
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch ([SettingData sharedInstance].weatherContent) {
        case WEA_RAIN:
        {
            return [[WeatherStatusMappingModel sharedInstance] sortedKeyCodes].count;
        }
            
        case WEA_TEMPERATURE:
        {
            return 21;
        }
            
        case WEA_WIND:
        {
            return [[WindMappingModel sharedInstance] sortedKeyCodes].count;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
@end
