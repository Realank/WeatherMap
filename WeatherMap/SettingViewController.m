//
//  SettingViewController.m
//  WeatherMap
//
//  Created by Realank on 15/10/16.
//  Copyright © 2015年 Realank. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingData.h"
#import "PopUpBigViewForNotice.h"
#import "MapOutlineData.h"

@interface SettingViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *weatherTimeSeg;
@property (weak, nonatomic) IBOutlet UISegmentedControl *weatherContentSeg;
@property (weak, nonatomic) IBOutlet UISwitch *showSpinSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *crazyModeSwitch;

@property (weak, nonatomic) IBOutlet UILabel *cacheSizeLabel;

@end

@implementation SettingViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    SDWeatherTime time = [SettingData sharedInstance].weatherTime;
    switch (time) {
        case WEA_TODAY:
            self.weatherTimeSeg.selectedSegmentIndex = 0;
            break;
        case WEA_TOMOTTOW:
            self.weatherTimeSeg.selectedSegmentIndex = 1;
            break;
        case WEA_AFTERTOMORROW:
            self.weatherTimeSeg.selectedSegmentIndex = 2;
            break;
    }
    
    SDWeatherContent content = [SettingData sharedInstance].weatherContent;
    switch (content) {
        case WEA_RAIN:
            self.weatherContentSeg.selectedSegmentIndex = 0;
            break;
        case WEA_TEMPERATURE:
            self.weatherContentSeg.selectedSegmentIndex = 1;
            break;
        case WEA_WIND:
            self.weatherContentSeg.selectedSegmentIndex = 2;
            break;
    }
    
    BOOL showSpin = [SettingData sharedInstance].showSpin;
    self.showSpinSwitch.on = showSpin;
    
    BOOL crazyMode = [SettingData sharedInstance].crazyMode;
    self.crazyModeSwitch.on = crazyMode;
    
    self.cacheSizeLabel.text = [NSString stringWithFormat:@"%.1f M",[MapOutlineData cacheCitysSize]];
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
- (IBAction)changeCrazyMode:(UISwitch *)sender {
    [SettingData sharedInstance].crazyMode = sender.isOn;
}
- (IBAction)clickIntroduce:(UIButton *)sender {
    
    PopUpBigViewForNotice *view = [[PopUpBigViewForNotice alloc]initWithFrame:self.view.bounds];
    view.title = @"-欢迎使用天气地图-";
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"introduce" ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
    view.content = content;
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
}

- (IBAction)clearCache:(id)sender {
    [MapOutlineData delectCacheCitysFolder];
    self.cacheSizeLabel.text = [NSString stringWithFormat:@"%.1f M",[MapOutlineData cacheCitysSize]];
}


@end
