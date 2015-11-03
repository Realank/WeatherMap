//
//  LaunchViewController.m
//  WeatherMap
//
//  Created by Realank on 15/10/23.
//  Copyright © 2015年 Realank. All rights reserved.
//

#import "LaunchViewController.h"

@interface LaunchViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation LaunchViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CGPoint center = self.view.center;
    __weak __typeof(self) weakSelf = self;
    
    [NSThread sleepForTimeInterval:0.1];
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.titleLabel.center = CGPointMake(weakSelf.titleLabel.center.x, weakSelf.titleLabel.center.y+30);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.7 animations:^{
            weakSelf.titleLabel.center = CGPointMake(center.x, -30);
            //        self.view.backgroundColor = [UIColor whiteColor];
        } completion:^(BOOL finished) {
            [weakSelf performSegueWithIdentifier:@"pushToTabView" sender:self];
        }];
    }];
    
}


@end
