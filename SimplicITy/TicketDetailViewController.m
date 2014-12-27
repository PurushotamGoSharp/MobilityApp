//
//  TicketDetailViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/16/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "TicketDetailViewController.h"
#import "DashBoardViewController.h"

@interface TicketDetailViewController () <UITableViewDataSource,UITableViewDelegate>
{
    NSArray *arrOfLable;
    UIBarButtonItem *backButton;
}

@end

@implementation TicketDetailViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arrOfLable = @[@"Requester",@"Impact",@"Services",@"Agent",@"Status"];
    
    
//    self.navigationController.navigationItem.hidesBackButton = YES;
    
//    [self.navigationItem setHidesBackButton:YES animated:YES];


    
//    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
//    [back setTitle:@"< Back" forState:UIControlStateNormal];
//    back.frame = CGRectMake(0, 0, 60, 40);
//    [back setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
//    [back  addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
//    backButton = [[UIBarButtonItem alloc] initWithCustomView:back];
//    self.navigationItem.leftBarButtonItem = backButton;

    
    
}

//-(void)backBtnAction
//{
//    
//    DashBoardViewController *raiseTicketVC = [[DashBoardViewController alloc] init];
//    [self.navigationController popToViewController:raiseTicketVC animated:YES];
//    
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 5;

    }else if (section == 1)
    {
        return 1;
    }
    else
    {
        return 1;
    }

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if (section == 0) {
        return @"";
        
    }else if (section == 1)
    {
        return @"Services";
    }
    else{
        return @"Details";
    }
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = nil;
    
    if (indexPath.section == 2)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellDetails" forIndexPath:indexPath];
    }else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    }

    UILabel *titleLable = (UILabel *)[cell viewWithTag:100];
    
    titleLable.font=[self customFont:16 ofName:MuseoSans_700];
    
    
    UILabel *linColour = (UILabel *)[cell viewWithTag:101];
    UILabel *circelColour = (UILabel *)[cell viewWithTag:102];
    UILabel *rightTable = (UILabel *)[cell viewWithTag:103];
    rightTable.font=[self customFont:16 ofName:MuseoSans_300];

//    UILabel *discriptionLable = (UILabel *)[cell1 viewWithTag:104];

    rightTable.hidden = NO;
    circelColour.layer.cornerRadius = 10;
    titleLable.textColor = [UIColor blackColor];
    
    if (indexPath.section == 1) {
        titleLable.text = self.tickModel.ticketSubject;
        rightTable.text = @"";
        titleLable.font=[self customFont:16 ofName:MuseoSans_300];
        titleLable.textColor = [UIColor lightGrayColor];
    }
    else if (indexPath.section == 2)
    {
        titleLable.text = self.tickModel.details;
        rightTable.hidden = YES;
        titleLable.textColor = [UIColor lightGrayColor];
        titleLable.font=[self customFont:16 ofName:MuseoSans_300];
    }
    else
    {
        switch (indexPath.row)
        {
            case 0:
            {
                titleLable.text = @"Requester";
                rightTable.text = @"Jean-Pierre";
                
            }
                
                break;
                
            case 1:
            {
                titleLable.text = @"Impact";
                rightTable.text = [self giveImpactForCOlor:self.tickModel.colorCode];
                linColour.backgroundColor = self.tickModel.colorCode;
                circelColour.backgroundColor = self.tickModel.colorCode;
                
            }
                break;
            case 2:
            {
                titleLable.text = @"Agent";
                rightTable.text = self.tickModel.agentName;
                
            }
                break;
            case 3:
            {
                titleLable.text = @"Status";
                rightTable.text = self.tickModel.currentStatus;
                
            }
                break;
            case 4:
            {
                
                titleLable.text = @"Date";
                rightTable.text = self.tickModel.date;
                
            }
                break;
            case 5:
            {
                
                titleLable.text = self.tickModel.ticketSubject;
                rightTable.text = @"";
            }
                break;
                
            default:
                break;
        }
    }

        return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2)
    {
        return 100;
    }
    
    return 44;
}

- (NSString *)giveImpactForCOlor:(UIColor *)colorCode
{
    
    if ([colorCode isEqual:[UIColor redColor]])
    {
        return @"Critical";
    }
    if ([colorCode isEqual:[UIColor orangeColor]])
    {
        return @"High";
    }
    if ([colorCode isEqual:[UIColor yellowColor]])
    {
        return @"Medium";
    }
        return @"Low";

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
