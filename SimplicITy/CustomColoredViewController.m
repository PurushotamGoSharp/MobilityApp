//
//  CustomColoredViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/11/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "CustomColoredViewController.h"

@interface CustomColoredViewController ()

@end

@implementation CustomColoredViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    
    switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"BackgroundTheme"])
    {
        case 0:
            self.view.backgroundColor = [UIColor colorWithRed:.7 green:.92 blue:.96 alpha:1];
            break;
            
        case 1:
            self.view.backgroundColor = [UIColor colorWithRed:.96 green:.67 blue:.53 alpha:1];
            break;
            
        case 2:
            self.view.backgroundColor = [UIColor colorWithRed:.86 green:.43 blue:.58 alpha:1];
            break;
            
        case 3:
            self.view.backgroundColor = [UIColor colorWithRed:.73 green:.82 blue:.58 alpha:1];
            break;
        default:
            break;
    }
}

- (NSString *)stingForColorTheme
{
    switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"BackgroundTheme"]) {
        case 0:
            return @"Blue";

            break;
        case 1:
            return @"Tonys Pink";
            break;
        case 2:
            return @"Pale Voilet Red";
            break;
        case 3:
            return @"Sprout";
            break;
        default:
            break;
    }
    
    return nil;
}

- (UIColor *)barColorForIndex:(NSInteger)index
{
    switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"BackgroundTheme"]) {
        case 0:
            return [UIColor colorWithRed:.13 green:.31 blue:.46 alpha:1];
            
            break;
        case 1:
            return [UIColor colorWithRed:.9 green:.45 blue:.23 alpha:1];
            break;
        case 2:
            return [UIColor colorWithRed:.76 green:.06 blue:.29 alpha:1];
            break;
        case 3:
            return [UIColor colorWithRed:.55 green:.7 blue:.31 alpha:1];
            break;
        default:
            break;
    }
    
    return nil;
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
