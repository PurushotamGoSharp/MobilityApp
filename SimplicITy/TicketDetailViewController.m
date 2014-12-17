//
//  TicketDetailViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/16/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "TicketDetailViewController.h"

@interface TicketDetailViewController () <UITableViewDataSource,UITableViewDelegate>
{
    NSArray *arrOfLable;
}

@end

@implementation TicketDetailViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arrOfLable = @[@"Requester",@"Impact",@"Category",@"Agent",@"Status"];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    UILabel *titleLable = (UILabel *)[cell viewWithTag:100];
    
    
    UILabel *linColour = (UILabel *)[cell viewWithTag:101];
    UILabel *circelColour = (UILabel *)[cell viewWithTag:102];
    UILabel *rightTable = (UILabel *)[cell viewWithTag:103];
    
    circelColour.layer.cornerRadius = 10;

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

            titleLable.text = self.tickModel.ticketSubject;
            rightTable.text = @"";

        }
            break;
        
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
