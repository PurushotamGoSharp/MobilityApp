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
#import "Postman.h"

@interface DashBoardViewController () <postmanDelegate>
{
    BOOL navBtnIsOn;
    UIButton *titleButton;
    UIImageView *downArrowImageView;
    NSDictionary *serverConfig;
    UIView *titleView;
    UIImageView *titleImageView;
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
@property (weak, nonatomic) IBOutlet UILabel *dashMyTicketsLabel;
@property (weak, nonatomic) IBOutlet UILabel *dashMyOrdersLabel;
@property (weak, nonatomic) IBOutlet UILabel *dashWebClipLabel;
@property (weak, nonatomic) IBOutlet UILabel *dashBoardPersonAddress;
@property (weak, nonatomic) IBOutlet UILabel *emailID;
@property (weak, nonatomic) IBOutlet UILabel *nameOfUserLabel;

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
    
    titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DashBoardNavBarPersonImage"]];
    titleImageView.frame = CGRectMake(0, 5, 32, 32);
//    titleImageView.center = CGPointMake(20, 20);
    
    titleButton = [[UIButton alloc] init];
    [titleButton addTarget:self action:@selector(navTitleBtnPressed:) forControlEvents:(UIControlEventTouchUpInside)];
    [titleButton setTitleColor:([UIColor whiteColor]) forState:(UIControlStateNormal)];
    //    [titleButton setImage:[UIImage imageNamed:@"perso_Small.png"] forState:UIControlStateNormal];
    titleButton.titleLabel.textColor = [UIColor whiteColor];
    [titleButton setTitle:@"Jim" forState:(UIControlStateNormal)];
    titleButton.titleLabel.font = [self customFont:20 ofName:MuseoSans_700];
    titleButton.frame = CGRectMake(titleImageView.frame.size.width+5, 0, 0, 0);
    [titleButton sizeToFit];
    
    CGFloat widthOfView = titleButton.frame.size.width + titleImageView.frame.origin.x +30;
    titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthOfView, 40)];
    [titleView addSubview:titleButton];
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
    self.dashMyTicketsLabel.font=[self customFont:14 ofName:MuseoSans_300];
    self.dashMyOrdersLabel.font=[self customFont:14 ofName:MuseoSans_300];
    self.dashWebClipLabel.font=[self customFont:14 ofName:MuseoSans_300];
    
    [self tryToGetITServicePhoneNum];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.profileViewOutlet.backgroundColor = [self subViewsColours];
    [self updateProfileView];
}



- (void)updateProfileView
{
    static NSString * const kConfigurationKey = @"com.apple.configuration.managed";
    serverConfig = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kConfigurationKey];
    
    if (serverConfig != nil)
    {
        NSString *cropID = serverConfig[@"corpID"];
        NSString *firstName = serverConfig[@"firstName"];
        NSString *lastName = serverConfig[@"lastName"];
        NSString *location = serverConfig[@"location"];
        NSString *emailIDValue = serverConfig[@"mail"];

        NSString *nameOfPerson;
        
        if (cropID)
        {
            self.dashBoardPersonCode.text = cropID;
        }
        
        if (firstName)
        {
            [titleButton setTitle:firstName forState:(UIControlStateNormal)];
            [titleButton sizeToFit];
            
            CGFloat widthOfView = titleButton.frame.size.width + titleImageView.frame.origin.x +30;
            titleView.frame = CGRectMake(0, 0, widthOfView, 40);
            downArrowImageView.center = CGPointMake(titleView.center.x + 18, titleView.center.y + 18);
        }
        
        if (firstName || lastName)
        {
            if (firstName)
            {
                nameOfPerson = [firstName stringByAppendingString:[NSString stringWithFormat:@" %@",lastName]];
                
            }else if (lastName)
            {
                nameOfPerson = lastName;
            }
            
            self.nameOfUserLabel.text = nameOfPerson;
        }
        if (location)
        {
            self.dashBoardPersonAddress.text = location;
        }
        if (emailIDValue)
        {
            self.emailID.text = emailIDValue;
        }
    }

}

-(void)tryToGetITServicePhoneNum
{
    Postman *postMan = [[Postman alloc] init];
    postMan.delegate = self;
    NSString *URLString = [NSString stringWithFormat:@"%@%@",BASE_URL,@"Countries"];
    NSString *parameter =  @"{\"request\":{\"Name\":\"\"}}";
    
    [postMan post:URLString withParameters:parameter];
    
}

-(void)postman:(Postman *)postman gotSuccess:(NSData *)response forURL:(NSString *)urlString
{
    
}

-(void)postman:(Postman *)postman gotFailure:(NSError *)error forURL:(NSString *)urlString
{
    
}

//-(void)

- (void)navTitleBtnPressed:(id)sender
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

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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

- (IBAction)myTicketsBtnPressed:(id)sender
{
//    [self.tabBarController setSelectedIndex:1];

}

- (IBAction)myOrderBtnPresed:(id)sender
{
    
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
