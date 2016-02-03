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

@interface TipsSubCategoriesViewController () <UITableViewDataSource, UITableViewDelegate >
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TipsSubCategoriesViewController
{
    BOOL userTappedOnVC; //if user selects a question or cancels, vlaue will be set to yes;
    
    NSIndexPath *selectedIndexPath;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.parentCategory;
    
    NSLog(@"curent page Number %li",(long)self.curentpageNum);
    
   selectedIndexPath = [NSIndexPath indexPathForRow:self.curentpageNum inSection:0];
    [self.tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localize) name:MCLocalizationLanguageDidChangeNotification object:nil];
    [self localize];

}
-(void)localize
{
 [self.navigationItem.leftBarButtonItem setTitle:STRING_FOR_LANGUAGE(@"Cancel")];

}





- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    userTappedOnVC = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    if (!userTappedOnVC)
//    {
//        [self dismissViewControllerAnimated:NO completion:^{
//            
//            
//        }];
//    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    

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
    label.font = [self customFont:16 ofName:MuseoSans_700];
    label.highlightedTextColor = [UIColor whiteColor];
    [label sizeToFit];
    
    TipModel *tip = self.listOfTips[indexPath.row];
    label.text = tip.question;
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [self barColorForIndex:selectedIndexPath.row];
    [cell setSelectedBackgroundView:bgColorView];

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    userTappedOnVC = YES;
    
    [self.delegate tipsSub:self selectedIndex:indexPath.row];
    [self dismissViewControllerAnimated:YES completion:^{
        
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


//- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation {
//    
//    switch (orientation)
//    {
//        case UIInterfaceOrientationPortrait:
//        case UIInterfaceOrientationPortraitUpsideDown:
//        {
//            //load the portrait view
//        }
//            
//            break;
//        case UIInterfaceOrientationLandscapeLeft:
//        case UIInterfaceOrientationLandscapeRight:
//        {
//            //load the landscape view
//        }
//            break;
//        case UIInterfaceOrientationUnknown:break;
//    }
//    
//    [self.tableView reloadData];
//}

- (IBAction)cancel:(UIBarButtonItem *)sender
{
    userTappedOnVC = YES;
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        
    }];
}

@end
