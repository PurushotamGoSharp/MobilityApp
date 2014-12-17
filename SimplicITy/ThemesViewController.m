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

@end

@implementation ThemesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arrOfThemesData = @[@"Blue",@"Orange Yellow",@"French Lilac",@"Eton Blue"];
}
- (IBAction)cancelBtnPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];

}
- (IBAction)doneBtnPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];

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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
           [[ NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"BackgroundTheme"];
            [[NSUserDefaults standardUserDefaults] synchronize];

        }
            break;
        case 1:
        {
            [[ NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"BackgroundTheme"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
            break;
        case 2:
        {
            [[ NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"BackgroundTheme"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
            break;
        case 3:
        {
            [[ NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"BackgroundTheme"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
            break;
            
        default:
            break;
    }
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
