//
//  TipsSubCategoriesViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/10/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "TipsSubCategoriesViewController.h"
#import "TipDetailsViewController.h"
#import "TipModel.h"
#import <sqlite3.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "DBManager.h"

@interface TipsSubCategoriesViewController () <UITableViewDataSource, UITableViewDelegate, postmanDelegate, DBManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TipsSubCategoriesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.parentCategory;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listOfTips count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    UILabel *label = (UILabel *) [cell viewWithTag:100];
    
    TipModel *tip = self.listOfTips[indexPath.row];
    label.text = tip.question;

    label.font = [self customFont:16 ofName:MuseoSans_700];
    [label sizeToFit];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [self.delegate tipsSub:self selectedIndex:indexPath.row];
        
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TipModel *tip = self.listOfTips[indexPath.row];
    NSDictionary *attributes = @{NSFontAttributeName: [self customFont:16 ofName:MuseoSans_700]};
    
    CGFloat maxWidthAllowed = self.view.frame.size.width - 16 - 33;
    
//    if ([[UIApplication sharedApplication] statusBarOrientation] != UIInterfaceOrientationPortrait)
//    {
//        maxWidthAllowed = self.view.frame.size.height - 16 - 33;
//    }
    
    CGRect expectedSizeOfLabel = [tip.question boundingRectWithSize:(CGSizeMake(maxWidthAllowed, 10000))
                                                            options:(NSStringDrawingUsesLineFragmentOrigin)
                                                         attributes:attributes
                                                            context:nil];
    
    CGFloat expectedHeightOfCell = expectedSizeOfLabel.size.height + 24;

    return expectedHeightOfCell;
}


- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation {
    
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            //load the portrait view
        }
            
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            //load the landscape view
        }
            break;
        case UIInterfaceOrientationUnknown:break;
    }
    
    [self.tableView reloadData];
}

@end
