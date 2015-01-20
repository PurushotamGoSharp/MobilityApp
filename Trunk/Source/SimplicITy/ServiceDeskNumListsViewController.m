//
//  ServiceDeskNumListsViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 19/01/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "ServiceDeskNumListsViewController.h"

@interface ServiceDeskNumListsViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation ServiceDeskNumListsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.country;
    
    NSLog(@"Selected Country details %@",self.serviceDeskDeteils);
}
- (IBAction)cancleBtnPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.serviceDeskDeteils count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    UILabel *name = (UILabel*)[cell viewWithTag:100];
    name.font = [self customFont:18 ofName:MuseoSans_700];
    UILabel *phoneNum = (UILabel*)[cell viewWithTag:200];
    phoneNum.font = [self customFont:14 ofName:MuseoSans_300];

    
//    phoneNum.text = self.serviceDeskDeteils;
    
    NSDictionary *dict = self.serviceDeskDeteils[indexPath.row];
    
    name.text = dict[@"Name"];
    phoneNum.text = dict[@"Number"];
    
    

    
    return cell;
}

#pragma mark UITableViewDelegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    NSDictionary *dict = self.serviceDeskDeteils[indexPath.row];
//    NSString *phoneNo = dict[@"Number"];
    
//    NSString *phoneNo = self.serviceDeskDeteils;
//    
//    phoneNo = [@"tel://" stringByAppendingString:phoneNo];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNo]];
    
    [self dismissViewControllerAnimated:YES completion:nil];


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
