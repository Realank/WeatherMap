//
//  CitySelectCollectionViewController.m
//  WeatherMap
//
//  Created by Realank on 15/10/14.
//  Copyright © 2015年 Realank. All rights reserved.
//

#import "CitySelectCollectionViewController.h"
#import "CityListModel.h"

@interface CitySelectCollectionViewController ()

@property (nonatomic, strong) CityListModel *cityListModel;

@end

@implementation CitySelectCollectionViewController

static NSString * const reuseIdentifier = @"CollectionCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cityListModel = [CityListModel sharedInstance];
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
}



#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.cityListModel.provincesNameArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSString *provinceName = self.cityListModel.provincesNameArray[indexPath.item];
    ProvinceInfo *provinceModel= [self.cityListModel.provinceDict objectForKey:provinceName];
    
    UIColor *color = [UIColor grayColor];
    if ([self.cityListModel isInSelectedProvinces:provinceName]) {
        color = [UIColor blueColor];
    }
    
    cell.layer.cornerRadius = 6;
    cell.clipsToBounds = YES;
    cell.layer.borderWidth = 1;
    cell.layer.borderColor = color.CGColor;
    
    CGSize cellSize = cell.contentView.bounds.size;
    
    UILabel *shortCutLable = (UILabel *)[cell.contentView viewWithTag:1000];
    if (!shortCutLable) {
        shortCutLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, cellSize.width, cellSize.height * 0.8)];
        shortCutLable.tag = 1000;
        shortCutLable.textAlignment = NSTextAlignmentCenter;
        shortCutLable.font = [UIFont boldSystemFontOfSize:40];
        shortCutLable.textColor = [UIColor whiteColor];
        [cell.contentView addSubview:shortCutLable];
    }
    shortCutLable.text = provinceModel.shortCut;
    shortCutLable.backgroundColor = color;
    
    UILabel *fullNameLabel = (UILabel *)[cell.contentView viewWithTag:1001];
    if (!fullNameLabel) {
        fullNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, cellSize.height * 0.8, cellSize.width, cellSize.height * 0.2)];
        fullNameLabel.tag = 1001;
        fullNameLabel.textAlignment = NSTextAlignmentCenter;
        fullNameLabel.font = [UIFont systemFontOfSize:15];
        fullNameLabel.layer.borderWidth = 1;
        [cell.contentView addSubview:fullNameLabel];
    }
    fullNameLabel.text = provinceName;
    fullNameLabel.textColor = color;
    fullNameLabel.layer.borderColor = color.CGColor;
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *provinceName = self.cityListModel.provincesNameArray[indexPath.item];
    [self.cityListModel changeProvinceSelectStatus:provinceName];
    NSLog(@"select: %@",provinceName);
    [collectionView reloadData];
    

}


@end
