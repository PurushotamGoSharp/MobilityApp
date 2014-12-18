//
//  TikcetCategoryViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/15/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "TikcetCategoryViewController.h"

@interface TikcetCategoryViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation TikcetCategoryViewController
{
    NSArray *arrayofData ,*arrayofTips;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    arrayofData = @[@"Provide VPN access",@"Internet is very slow",@"My leave application password been expired and unable to reset it ",@"VPN is not accessible outside work",@"Cannot download any file to my desktop",@"Unable to make any outside call from my desk phone",@"Unable to access my office email",@"I'm unable to connect my console to internet",@"Unable to track package",@"Do you ship perishables to Schmaltzburg?"];
    
    arrayofData = @[@"Provide VPN access",@"Internet is very slow",@"My leave application password been expired and unable to reset it ",@"VPN is not accessible outside work",@"Cannot download any file to my desktop",@"Unable to make any outside call from my desk phone",@"Unable to access my office email"];

    arrayofTips=@[@"Cannot do anything.Need IS help.So no tips",@"Please try to disconnect the internet and then reconnect it.",@"Please try to select the “Forget Password” link and enter your email address.",@" Please try to reinstall the VPN software.",@"Can you please close all the open browsers? Open a new browser and try downloading the file.",@"Please add the #9 before the dialling number for the external calls.",@" Please click on the “Forget Password” link and enter the email address to reset your password."];



}
- (IBAction)cancelBtnAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayofData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    UILabel *label = (UILabel *)[cell viewWithTag:100];
    label.text = arrayofData[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.delegate selectedTicket:arrayofData[indexPath.row]];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    
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
