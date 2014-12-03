//
//  DashBoardViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/3/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "DashBoardViewController.h"
#import "MessagesViewController.h"

@interface DashBoardViewController ()

@end

@implementation DashBoardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:.13 green:.31 blue:.46 alpha:1]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)messageButtonPressed:(UIButton *)sender
{
    
    for (UIViewController *vc in self.tabBarController.viewControllers)
    {
        if ([vc isKindOfClass:[MessagesViewController class]])
        {
            [self.tabBarController setSelectedViewController:vc];
        }
    }
}
- (IBAction)initiateCallForITHelpDesk:(UIButton *)sender
{
    NSString *phoneNo = @"123456789";
    phoneNo = [@"tel://" stringByAppendingString:phoneNo];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNo]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
