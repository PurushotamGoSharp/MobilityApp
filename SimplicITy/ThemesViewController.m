//
//  ThemesViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 17/12/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "ThemesViewController.h"

@interface ThemesViewController () <UITableViewDataSource,UITableViewDelegate>
{
    NSArray *arrOfThemesData;
}
@property (weak, nonatomic) IBOutlet UITableView *tableViewOutlet;

@end

@implementation ThemesViewController
{
    NSInteger selectedRow;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arrOfThemesData = @[@"Blue Ocean",@"Orange Hue",@"Red Rose",@"Green Glow"];
    
    selectedRow = [[NSUserDefaults standardUserDefaults] integerForKey:@"BackgroundTheme"];

}
- (IBAction)cancelBtnPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)doneBtnPressed:(id)sender
{
    [[ NSUserDefaults standardUserDefaults] setInteger:selectedRow forKey:@"BackgroundTheme"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[UITabBar appearance] setBarTintColor:[self barColorForIndex:selectedRow]];
    [[UINavigationBar appearance] setBarTintColor:[self barColorForIndex:selectedRow]];
    [self.delegate selectedThemeIs:arrOfThemesData[selectedRow]];
    [self dismissViewControllerAnimated:YES completion:nil];

}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark UITableViewDataSource methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrOfThemesData count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    UILabel *titleLable= (UILabel *)[cell viewWithTag:100];
    titleLable.text = arrOfThemesData[indexPath.row];
    titleLable.highlightedTextColor = [UIColor whiteColor];
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [self barColorForIndex:selectedRow];
    [cell setSelectedBackgroundView:bgColorView];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRow = indexPath.row;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
