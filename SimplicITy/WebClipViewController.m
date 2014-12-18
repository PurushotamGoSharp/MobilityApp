//
//  WebClipViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/4/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "WebClipViewController.h"

@interface WebClipViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSArray *tableViewData, *arrayOfImages;
}

@end

@implementation WebClipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    tableViewData = @[@"Reset Lync Password",@"Reset SAP Password"];
    arrayOfImages = @[@"LyncWebClipIcon", @"SAPWebClipIcon"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [tableViewData count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    UILabel *titlelable = (UILabel *)[cell viewWithTag:100];
    titlelable.text = tableViewData[indexPath.row];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:101];
    imageView.image = [UIImage imageNamed:arrayOfImages[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://products.office.com/en/lync/"]];
    }else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.sap.com/index.html"]];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
