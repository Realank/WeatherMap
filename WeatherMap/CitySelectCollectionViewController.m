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

@interface CitySelectCollectionViewController ()

@property (nonatomic, strong) CityListModel *cityListModel;

@end

@implementation CitySelectCollectionViewController

static NSString * const selectedReuseIdentifier = @"selectCell";
static NSString * const unselectedReuseIdentifier = @"unselectCell";
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cityListModel = [CityListModel sharedInstance];
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerNib:[UINib nibWithNibName:@"ProvinceUnselectedCollectionViewCell" bundle:nil]forCellWithReuseIdentifier:unselectedReuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:@"ProvinceSelectedCollectionViewCell" bundle:nil]forCellWithReuseIdentifier:selectedReuseIdentifier];

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
    
    NSString *provinceName = self.cityListModel.provincesNameArray[indexPath.item];
    [self.cityListModel changeProvinceSelectStatus:provinceName];
    NSLog(@"select: %@",provinceName);
    [collectionView reloadData];
    

}


@end
