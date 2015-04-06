//
//  InviteAttendeesViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 06/04/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "InviteAttendeesViewController.h"
#import "UserInfo.h"

@interface InviteAttendeesViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation InviteAttendeesViewController
{
    __weak IBOutlet UIButton *sendInviteButton;
    NSArray *dataOfFirstSection;
    NSArray *dataOfThirdSection;
    
    NSString *dateForBooking;
    NSString *startDateString, *endDateString;
    NSDateFormatter *dateFormatter;
    
    NSString *userName;
    NSString *venue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Invite Attendees";

    
    dataOfFirstSection = @[@"Date",@"Start",@"End",@"Organizer",@"Venue"];
    dataOfThirdSection = @[@"",@"Marc",@"Bin",@"Antony",@"Sundar"];

    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"EEEE dd MMMM yyyy";
    dateForBooking = [dateFormatter stringFromDate:self.startDate];
    
    dateFormatter.dateFormat = @"hh.mm a";
    startDateString = [dateFormatter stringFromDate:self.startDate];
    endDateString = [dateFormatter stringFromDate:self.endDate];
    
    userName = [UserInfo sharedUserInfo].fullName;
    venue = self.selectedRoom.nameOfRoom;
    
    sendInviteButton.layer.cornerRadius = 5;
    sendInviteButton.titleLabel.font = [self customFont:16 ofName:MuseoSans_700];

    
    
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
    

    
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

        UILabel *leftLable = (UILabel*)[cell viewWithTag:100];
        UILabel *rightLable = (UILabel*)[cell viewWithTag:200];
        leftLable.text = dataOfFirstSection[indexPath.row];
        switch (indexPath.row)
        {
            case 0:
                rightLable.text = dateForBooking;
                break;
            case 1:
                rightLable.text = startDateString;
                break;
            case 2:
                rightLable.text = endDateString;
                break;
            case 3:
                rightLable.text = userName;
                break;
            case 4:
                rightLable.text = venue;
                break;
            default:
                break;
        }
        leftLable.font = [self customFont:16 ofName:MuseoSans_700];
        rightLable.font = [self customFont:16 ofName:MuseoSans_700];
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
            btn.hidden = NO;
            
        }else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell2" forIndexPath:indexPath];
            UILabel *rightLable = (UILabel*)[cell viewWithTag:100];
            rightLable.text = dataOfThirdSection[indexPath.row];
            rightLable.font = [self customFont:16 ofName:MuseoSans_700];
            
            UIImageView *imageView = (UIImageView*)[cell viewWithTag:200];
            
            if (indexPath.row == 1)
            {
                imageView.image = [UIImage imageNamed:@"Sel1"];
            }
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView =  [[UIView alloc] initWithFrame:(CGRectMake(0, 0, 150, 30))];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:(CGRectMake(18, 0, 150, 30))];
    
    headerLabel.font = [UIFont boldSystemFontOfSize:14];
    
    if (section == 0)
    {
        headerLabel.text = @"Meeting Details";
    }else if (section == 1)
    {
        headerLabel.text = @"Subject";
    }else if (section == 2)
    {
        headerLabel.text = @"Add attendees";
    }
    
    [headerView addSubview:headerLabel];
    
    return headerView;
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
