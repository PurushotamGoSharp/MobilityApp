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
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)messageButtonPressed:(UIButton *)sender
{
    [self.tabBarController setSelectedIndex:3];
}

- (IBAction)initiateCallForITHelpDesk:(UIButton *)sender
{
    NSString *phoneNo = @"123456789";
    phoneNo = [@"tel://" stringByAppendingString:phoneNo];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNo]];
}

- (IBAction)settingIsPressed:(UIButton *)sender
{
    [self.tabBarController setSelectedIndex:4];
}

- (IBAction)toolsButtonIsPressed:(UIButton *)sender
{
    [self.tabBarController setSelectedIndex:1];
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
