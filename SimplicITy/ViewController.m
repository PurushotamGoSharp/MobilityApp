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

@end

@implementation ViewController
{
    CGPoint centerOfContainer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    centerOfContainer = self.conatinerForTxtAndBtn.center;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setUpViewWithCornerRadius:self.userNameContainer];
    [self setUpViewWithCornerRadius:self.passwordContainer];
    [self setUpViewWithCornerRadius:self.signInButton];
    
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
    [self performSegueWithIdentifier:@"siginInToTabSegue" sender:nil];
}

- (IBAction)hideKeyboard:(UIControl *)sender
{
    [UIView animateWithDuration:.3
                     animations:^{
                         
                         self.logoOImageView.alpha = 1;
                         self.conatinerForTxtAndBtn.center = centerOfContainer;
                         
                     } completion:^(BOOL finished) {
                         
                     }];
    
    [self.view endEditing:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    CGPoint toCenter = centerOfContainer;
    toCenter.y -= 120;
    
    [UIView animateWithDuration:.3
                     animations:^{
                         self.logoOImageView.alpha = 0;
                         self.conatinerForTxtAndBtn.center = toCenter;
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{

}

@end
