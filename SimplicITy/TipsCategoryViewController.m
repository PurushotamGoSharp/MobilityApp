//
//  TipsCategoryViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/4/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "TipsCategoryViewController.h"
#import "TipsSubCategoriesViewController.h"
@interface TipsCategoryViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TipsCategoryViewController
{
    NSArray *categoriesArray;
    NSDictionary *subCategory;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    categoriesArray = @[@"LYNC", @"AD Password", @"ITMS",@"Travel",@"Meeting Room",@"Wireless Password"];
    
    subCategory = @{@"LYNC":
                    @[@"Instant Messaging", @"Voice Over IP", @"Voice conferencing"],
                    @"AD Password": @[@"Web Conferencing",@"Video Conferencing"],
                    @"ITMS":@[@"Financial Accounting (FI)",@"Controlling (CO)",@"Investment Management (IM)"],
                    @"Travel":@[@"Configuration Management",@"Change Management",@"Release Management",@"Incident Management"],
                    @"Meeting Room":@[@"Workspace Management",@"Mobile Security",@"Mobile Device Management",@"Mobile Application Management",@"Mobile Content Management",@"Mobile Email Management"],
                    
                    
                    };
    
    self.navigationController.navigationBarHidden = NO;
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
    return [categoriesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell" forIndexPath:indexPath];
    
    UILabel *label = (UILabel *)[cell viewWithTag:100];
    label.text = categoriesArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TipsCatToSubcatSegue"])
    {
        TipsSubCategoriesViewController *tipsSubVC = (TipsSubCategoriesViewController *)segue.destinationViewController;
        tipsSubVC.parentCategory = categoriesArray[[self.tableView indexPathForSelectedRow].row];
        tipsSubVC.subCategoriesData = subCategory[tipsSubVC.parentCategory];
    }
}

@end
