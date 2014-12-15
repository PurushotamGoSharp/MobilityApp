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
    NSArray *arrayofData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arrayofData = @[@"My PC is broken",@"I want to reset my password",@"I can not access my application"];

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
