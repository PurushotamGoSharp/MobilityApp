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
{
    BOOL navBtnIsOn;
}
@property (weak, nonatomic) IBOutlet UIButton *navtitleBtnoutlet;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileViewTopConstraint;

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
    
    self.navtitleBtnoutlet.selected = NO;
    
    self.profileViewTopConstraint.constant = -107;
    
    

}

- (IBAction)navTitleBtnPressed:(id)sender
{
    NSInteger constrainValue;
    if (!navBtnIsOn)
    {
        constrainValue = 1;
        navBtnIsOn = YES;
    }else
    {
        constrainValue = -107;
        navBtnIsOn = NO;
    }
    [UIView animateWithDuration:.5
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.profileViewTopConstraint.constant = constrainValue;
                         [self.view layoutIfNeeded];

                     } completion:^(BOOL finished) {
                         
                     }];
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)messageButtonPressed:(UIButton *)sender
{
    [self.tabBarController setSelectedIndex:2];
}
- (IBAction)raiseATicketPressed:(UIButton *)sender
{
    [self.tabBarController setSelectedIndex:1];
}
- (IBAction)tipsButtonPressed:(UIButton *)sender
{
    [self.tabBarController setSelectedIndex:3];
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
