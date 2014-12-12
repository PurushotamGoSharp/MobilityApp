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
    UIButton *titleButton;
    UIImageView *downArrowImageView;
}
@property (weak, nonatomic) IBOutlet UIButton *navtitleBtnoutlet;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileViewHeightConstraint;

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
    self.profileViewHeightConstraint.constant = 0;
    
    titleButton = [[UIButton alloc] init];
    [titleButton addTarget:self action:@selector(navTitleBtnPressed:) forControlEvents:(UIControlEventTouchUpInside)];
    [titleButton setTitleColor:([UIColor whiteColor]) forState:(UIControlStateNormal)];
    //    [titleButton setImage:[UIImage imageNamed:@"perso_Small.png"] forState:UIControlStateNormal];
    titleButton.titleLabel.textColor = [UIColor whiteColor];
    [titleButton setTitle:@"" forState:(UIControlStateNormal)];
    titleButton.frame = CGRectMake(0, 0, 135, 40);
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    [titleView addSubview:titleButton];
    
    
    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"perso.png"]];
    titleImageView.frame = CGRectMake(0, 0, 32, 32);
    titleImageView.center = CGPointMake(20, 20);
    CALayer *maskLayer = [CALayer layer];
    maskLayer.frame = titleImageView.bounds;
    maskLayer.contents = (__bridge id)[UIImage imageNamed:@"circleMask.png"].CGImage;
    titleImageView.layer.mask = maskLayer;
    [titleView addSubview:titleImageView];
    
    
    downArrowImageView = [[UIImageView alloc] initWithImage:([UIImage imageNamed:@"DashBoardDropDownBarImage"])];
    downArrowImageView.frame = CGRectMake(0, 0, 36, 3);
    downArrowImageView.center = CGPointMake(titleView.center.x + 18, titleView.center.y + 18);
    [titleView addSubview:downArrowImageView];
    
    downArrowImageView.hidden = NO;
    
    self.navigationItem.titleView = titleView;


}
- (IBAction)navTitleBtnPressed:(id)sender
{
    

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
