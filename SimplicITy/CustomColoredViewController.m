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

    
    switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"BackgroundTheme"]) {
        case 0:
        {
            self.view.backgroundColor = [UIColor colorWithRed:.7 green:.92 blue:.96 alpha:1];

        }
            break;
        case 1:
        {
            self.view.backgroundColor = [UIColor colorWithRed:.5 green:.55 blue:.55 alpha:1];
        }
            break;
        case 2:
        {
            self.view.backgroundColor = [UIColor colorWithRed:.52 green:.4 blue:.6 alpha:1];

        }
            break;
        case 3:
        {
            self.view.backgroundColor = [UIColor colorWithRed:1 green:.8 blue:.4 alpha:1];

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
