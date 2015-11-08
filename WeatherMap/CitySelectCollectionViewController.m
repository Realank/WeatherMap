//
//  CitySelectCollectionViewController.m
//  WeatherMap
//
//  Created by Realank on 15/10/14.
//  Copyright © 2015年 Realank. All rights reserved.
//

#import "CitySelectCollectionViewController.h"
#import "CityListModel.h"
#import "ProvinceUnselectedCollectionViewCell.h"
#import "ProvinceSelectedCollectionViewCell.h"
#import "SettingData.h"

#define kCellItemSize 75

@interface CitySelectCollectionViewController ()

@property (nonatomic, strong) CityListModel *cityListModel;

@end

@implementation CitySelectCollectionViewController

static NSString * const selectedReuseIdentifier = @"selectCell";
static NSString * const unselectedReuseIdentifier = @"unselectCell";
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //setup the cell space
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kCellItemSize, kCellItemSize);
    NSInteger space = (self.view.bounds.size.width - 4*kCellItemSize)/8;
    space = space > 5 ? space : 5;
    layout.minimumLineSpacing = 15;
    layout.minimumInteritemSpacing = space;
    layout.sectionInset = UIEdgeInsetsMake(10, space, 10, space);
    self.collectionView.collectionViewLayout = layout;
    
    self.cityListModel = [CityListModel sharedInstance];
    
    // Register cell classes
    [self.collectionView registerNib:[UINib nibWithNibName:@"ProvinceUnselectedCollectionViewCell" bundle:nil]forCellWithReuseIdentifier:unselectedReuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:@"ProvinceSelectedCollectionViewCell" bundle:nil]forCellWithReuseIdentifier:selectedReuseIdentifier];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[CityListModel sharedInstance] syncProvinceSelectionStatusInROM];
}



#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.cityListModel.provincesNameArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *provinceName = self.cityListModel.provincesNameArray[indexPath.item];
    ProvinceInfo *provinceModel= [self.cityListModel.provinceDict objectForKey:provinceName];
    
    if ([self.cityListModel isInSelectedProvinces:provinceName]) {
        ProvinceSelectedCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:selectedReuseIdentifier forIndexPath:indexPath];
        [cell setTitle:provinceModel.shortCut andName:provinceName];
        return cell;
    } else {
        ProvinceUnselectedCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:unselectedReuseIdentifier forIndexPath:indexPath];
        
        [cell setTitle:provinceModel.shortCut andName:provinceName];
        return cell;
    }
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DLog(@"didSelectItemAtIndexPath start");
    NSString *provinceName = self.cityListModel.provincesNameArray[indexPath.item];
    if (![self.cityListModel changeProvinceSelectStatus:provinceName]) {
        BOOL crazyMode = [SettingData sharedInstance].crazyMode;
        if (crazyMode) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"您当前是疯狂模式" message:@"您可以选择多于5个城市，但是数据过多，会造成地图载入缓慢和应用卡顿" delegate:nil  cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"您只能选择至多5个省份，若要选择更多省份，请在设置中开启疯狂模式" delegate:nil  cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
        
    }
    DMapLog(@"select: %@",provinceName);
    DLog(@"didSelectItemAtIndexPath 2");
    [collectionView reloadData];
    //[collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    DLog(@"didSelectItemAtIndexPath 3");
    
    

}

- (IBAction)clearAllSelection:(id)sender {
    
    [self.cityListModel clearAllSelection];
    [self.collectionView reloadData];
}

@end
