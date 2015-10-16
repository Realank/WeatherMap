//
//  SettingViewController.m
//  WeatherMap
//
//  Created by Realank on 15/10/16.
//  Copyright © 2015年 Realank. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingData.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)changeWeatherTime:(UISegmentedControl *)sender {
    SDWeatherTime time;
    switch (sender.selectedSegmentIndex) {
        case 0:
            time = WEA_TODAY;
            break;
        case 1:
            time = WEA_TOMOTTOW;
            break;
        case 2:
            time = WEA_AFTERTOMORROW;
            break;
        default:
            time = WEA_TOMOTTOW;
            break;
    }
    [SettingData sharedInstance].weatherTime = time;
}
- (IBAction)changeWeatherContent:(UISegmentedControl *)sender {
    SDWeatherContent content;
    switch (sender.selectedSegmentIndex) {
        case 0:
            content = WEA_RAIN;
            break;
        case 1:
            content = WEA_TEMPERATURE;
            break;
        case 2:
            content = WEA_WIND;
            break;
        default:
            content = WEA_RAIN;
            break;
    }
    [SettingData sharedInstance].weatherContent = content;
}
- (IBAction)changeSpin:(UISwitch *)sender {
    
    [SettingData sharedInstance].showSpin = sender.isOn;
}

@end
