//
//  DashBoardViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/3/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "DashBoardViewController.h"
#import "MessagesViewController.h"
#import "RaiseATicketViewController.h"
#import "TicketsListViewController.h"

@interface DashBoardViewController ()
{
    BOOL navBtnIsOn;
    UIButton *titleButton;
    UIImageView *downArrowImageView;
}
@property (weak, nonatomic) IBOutlet UIButton *navtitleBtnoutlet;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *profileViewOutlet;
@property (weak, nonatomic) IBOutlet UILabel *dashBoardOrder;
@property (weak, nonatomic) IBOutlet UILabel *dashBoardMessage;
@property (weak, nonatomic) IBOutlet UILabel *dashBoardCallHelpDesk;
@property (weak, nonatomic) IBOutlet UILabel *dashBoardTips;
@property (weak, nonatomic) IBOutlet UILabel *dashBoardSetting;
@property (weak, nonatomic) IBOutlet UILabel *dashBoardTicket;
@property (weak, nonatomic) IBOutlet UILabel *dashBoardPersonName;
@property (weak, nonatomic) IBOutlet UILabel *dashBoardPersonCode;


@property (weak, nonatomic) IBOutlet UILabel *dashBoardPersonAddress;








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
    
    titleButton = [[UIButton alloc] init];
    [titleButton addTarget:self action:@selector(navTitleBtnPressed:) forControlEvents:(UIControlEventTouchUpInside)];
    [titleButton setTitleColor:([UIColor whiteColor]) forState:(UIControlStateNormal)];
    //    [titleButton setImage:[UIImage imageNamed:@"perso_Small.png"] forState:UIControlStateNormal];
    titleButton.titleLabel.textColor = [UIColor whiteColor];
    [titleButton setTitle:@" Jean-Pierre" forState:(UIControlStateNormal)];
    titleButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    titleButton.titleLabel.font = [self customFont:20 ofName:MuseoSans_700];
    titleButton.frame = CGRectMake(0, 0, 170, 40);
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    [titleView addSubview:titleButton];
    
    
    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DashBoardNavBarPersonImage"]];
    titleImageView.frame = CGRectMake(0, 0, 32, 32);
    titleImageView.center = CGPointMake(20, 20);
    [titleView addSubview:titleImageView];
    
    
    downArrowImageView = [[UIImageView alloc] initWithImage:([UIImage imageNamed:@"DashBoardDropDownBarImage"])];
    downArrowImageView.frame = CGRectMake(0, 0, 36, 3);
    downArrowImageView.center = CGPointMake(titleView.center.x + 18, titleView.center.y + 18);
    [titleView addSubview:downArrowImageView];
    
    downArrowImageView.hidden = NO;
    
    self.navigationItem.titleView = titleView;
    
    
    self.dashBoardMessage.font=[self customFont:14 ofName:MuseoSans_300];
    self.dashBoardCallHelpDesk.font=[self customFont:14 ofName:MuseoSans_300];
    self.dashBoardOrder.font=[self customFont:14 ofName:MuseoSans_300];
    self.dashBoardSetting.font=[self customFont:14 ofName:MuseoSans_300];
    self.dashBoardTicket.font=[self customFont:14 ofName:MuseoSans_300];
    self.dashBoardTips.font=[self customFont:14 ofName:MuseoSans_300];
    self.dashBoardPersonName.font=[self customFont:14 ofName:MuseoSans_300];
    self.dashBoardPersonAddress.font=[self customFont:14 ofName:MuseoSans_300];
    self.dashBoardPersonCode.font=[self customFont:14 ofName:MuseoSans_300];




}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)navTitleBtnPressed:(id)sender
{
    self.profileViewOutlet.backgroundColor = [self subViewsColours];
    
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
    NSString *phoneNo = @"9880425945";
    phoneNo = [@"tel://" stringByAppendingString:phoneNo];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNo]];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"dashToOrder_segue"])
    {
        RaiseATicketViewController *raiseTicket = segue.destinationViewController;
        raiseTicket.orderDiffer = @"orderBtnPressed";
        
    }if ([segue.identifier isEqualToString:@"DashToMyOrdersSegue"])
    {
        TicketsListViewController *orderList = segue.destinationViewController;
        orderList.orderItemDifferForList = @"orderList";
    }
}


@end
