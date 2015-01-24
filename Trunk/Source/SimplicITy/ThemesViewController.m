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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancleBarBtn;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarBtn;
@end

@implementation ThemesViewController
{
    NSInteger selectedRow;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arrOfThemesData = @[@"Blue Ocean",@"Orange Hue",@"Pink Rose",@"Green Glow"];
    
    selectedRow = [[NSUserDefaults standardUserDefaults] integerForKey:@"BackgroundTheme"];
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:selectedRow inSection:0];
    [self.tableViewOutlet selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:(UITableViewScrollPositionNone)];

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
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [self colorForIndex:selectedRow],NSFontAttributeName : [UIFont fontWithName:@"MuseoSans-300" size:12]} forState:(UIControlStateNormal)];

    [[UINavigationBar appearance] setBarTintColor:[self barColorForIndex:selectedRow]];
    [self.delegate selectedThemeIs:arrOfThemesData[selectedRow]];
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (UIColor *)colorForIndex:(NSInteger)colorIndex
{
    switch (colorIndex)
    {
        case 0:
            return [UIColor colorWithRed:.1 green:.16 blue:.2 alpha:1];
            break;
            
        case 1:
            return [UIColor colorWithRed:.4 green:.11 blue:.2 alpha:1];
            break;
            
        case 2:
            return [UIColor colorWithRed:.15 green:.18 blue:.09 alpha:1];
            break;
            
        case 3:
            return [UIColor colorWithRed:.35 green:.2 blue:.13 alpha:1];
            break;
            
        default:
            break;
    }
    
    return nil;
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
    titleLable.font=[self customFont:16 ofName:MuseoSans_700];
    
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
