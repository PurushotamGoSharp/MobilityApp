//
//  ADExpirationViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/19/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "ADExpirationViewController.h"

@interface ADExpirationViewController ()
@property (weak, nonatomic) IBOutlet UILabel *passwordToolLabel;

@end

@implementation ADExpirationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Password Expiry";
    self.passwordToolLabel.font = [self customFont:16 ofName:MuseoSans_300];
}

- (IBAction)paswordSelfServiceBtnPressed:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://mdm2.ucb.com/psynch/docs/en-us/indexf.html"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController popViewControllerAnimated:YES];
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
