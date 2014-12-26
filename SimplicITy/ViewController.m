//
//  ViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/3/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *userNameContainer;
@property (weak, nonatomic) IBOutlet UIView *passwordContainer;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoOImageView;
@property (weak, nonatomic) IBOutlet UIView *conatinerForTxtAndBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginViewBottomConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoHeightConst;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextFldOutlet;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextFldOutlet;

@end

@implementation ViewController
{
    CGPoint centerOfContainer;
    CGFloat initialLoginViewBottomCons;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
//        for (NSString *family in [UIFont familyNames])
//        {
//            for (NSString *names in [UIFont fontNamesForFamilyName:family])
//            {
//                NSLog(@"%@ %@", family, names);
//            }
//        }
    
    self.signInButton.titleLabel.font = [UIFont fontWithName:@"MuseoSans-700" size:18];
    self.userNameTextFldOutlet.font = [UIFont fontWithName:@"MuseoSans-300" size:14];
    
    centerOfContainer = self.conatinerForTxtAndBtn.center;
    initialLoginViewBottomCons = self.loginViewBottomConst.constant;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setUpViewWithCornerRadius:self.userNameContainer];
    [self setUpViewWithCornerRadius:self.passwordContainer];
    [self setUpViewWithCornerRadius:self.signInButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UIDeviceOrientationDidChangeNotification
                                                 object:nil];
}

- (void)orientationChanged:(NSNotification *)notification
{
    [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation
{
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
    {
        
    }else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        
    }
}

- (void)setUpViewWithCornerRadius:(UIView *)view
{
    view.layer.cornerRadius = 3;
    view.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signInButtonPressed:(UIButton *)sender
{
    [self hideKeyboard:nil];
    [self performSegueWithIdentifier:@"signInToTabVCSegue" sender:nil];
}

- (IBAction)hideKeyboard:(UIControl *)sender
{
    [UIView animateWithDuration:.3
                     animations:^{
                         
                         self.logoOImageView.alpha = 1;
                         self.loginViewBottomConst.constant = initialLoginViewBottomCons;
                         self.loginViewBottomConst.priority = 998;
                         self.logoHeightConst.priority = 999;
                         [self.view layoutIfNeeded];
                         
                     } completion:^(BOOL finished) {
                         
                     }];
    
    [self.view endEditing:YES];
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    CGPoint toCenter = centerOfContainer;
    toCenter.y -= 120;
    if (self.loginViewBottomConst.constant == initialLoginViewBottomCons)
    {
        [UIView animateWithDuration:.3
                         animations:^{
                            self.logoOImageView.alpha = 0;
                             self.loginViewBottomConst.constant += 100;
                             self.loginViewBottomConst.priority = 999;
                             self.logoHeightConst.priority = 998;
                             [self.view layoutIfNeeded];
                             
                         } completion:^(BOOL finished) {
                             
                         }];
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITabBarController *tabBarController = segue.destinationViewController;
    UITabBar *tabBar = tabBarController.tabBar;
    NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:@"BackgroundTheme"];
    [self setTabImageForColorIndex:index onTabBar:tabBar];
}

- (void)setTabImageForColorIndex:(NSInteger)colorIndex onTabBar:(UITabBar *)tabBar;
{
    NSInteger imageIndex = colorIndex+1; //Image name say Commercial-01.png, staring index is 1.
    
    NSString *imageName0 = [NSString stringWithFormat:@"Dwelling-0%i.png", imageIndex];
    NSString *imageName1 = [NSString stringWithFormat:@"Commercial-0%i.png", imageIndex];
    NSString *imageName2 = [NSString stringWithFormat:@"Message-0%i.png", imageIndex];
    NSString *imageName3 = [NSString stringWithFormat:@"TipsIcon-0%i.png", imageIndex];
    NSString *imageName4 = [NSString stringWithFormat:@"Spanner-0%i.png", imageIndex];
    
    UITabBarItem *tabBarItem = tabBar.items[0];
    tabBarItem.image = [[UIImage imageNamed:imageName0] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    tabBarItem = tabBar.items[1];
    tabBarItem.image = [[UIImage imageNamed:imageName1] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    tabBarItem = tabBar.items[2];
    tabBarItem.image = [[UIImage imageNamed:imageName2] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    tabBarItem = tabBar.items[3];
    tabBarItem.image = [[UIImage imageNamed:imageName3] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    tabBarItem = tabBar.items[4];
    tabBarItem.image = [[UIImage imageNamed:imageName4] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

@end
