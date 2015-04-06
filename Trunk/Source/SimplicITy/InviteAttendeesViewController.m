//
//  InviteAttendeesViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 06/04/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "InviteAttendeesViewController.h"

@interface InviteAttendeesViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation InviteAttendeesViewController
{
    NSArray *dataOfFirstSection;
    NSArray *dataOfThirdSection;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    dataOfFirstSection = @[@"Start",@"End",@"Organizer",@"Venue"];
    dataOfFirstSection = @[@"",@"Mark",@"Bin",@"Antont",@"Sundar"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (section == 0)
    {
        return [dataOfFirstSection count];
    }else if (section == 1)
    {
        return 1;
    }else
    {
        return [dataOfThirdSection count];
    }
    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

        UILabel *rightLable = (UILabel*)[cell viewWithTag:100];
        UILabel *leftLable = (UILabel*)[cell viewWithTag:200];
        
        rightLable.font = [self customFont:16 ofName:MuseoSans_700];
        leftLable.font = [self customFont:16 ofName:MuseoSans_700];
    }else if (indexPath.section == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];

        UITextField *txtField = (UITextField*)[cell viewWithTag:100];
        UIButton *btn = (UIButton *)[cell viewWithTag:200];
        btn.hidden = YES;
    }else
    {
        if (indexPath.row == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];
            UITextField *txtField = (UITextField*)[cell viewWithTag:100];
            txtField.placeholder = @"Enter Email";
            UIButton *btn = (UIButton *)[cell viewWithTag:200];
            btn.hidden = YES;
            
        }else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell2" forIndexPath:indexPath];
            UILabel *rightLable = (UILabel*)[cell viewWithTag:100];
            rightLable.text = dataOfThirdSection[indexPath.row];
            rightLable.font = [self customFont:16 ofName:MuseoSans_700];
        }
    }
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
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
