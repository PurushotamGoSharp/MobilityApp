//
//  TicketsListViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/11/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "TicketsListViewController.h"
#import "TicketsListCell.h"
@interface TicketsListViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation TicketsListViewController
{
    NSMutableArray *arrayOfData;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    arrayOfData = [[NSMutableArray alloc] init];
    [self setUpData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayOfData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TicketsListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.ticketModel = arrayOfData[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setUpData
{
    TicketModel *ticket = [[TicketModel alloc] init];
    ticket.ticketSubject = @"I'm unacle to connect my console to internet";
    ticket.agentName = @"Bertie";
    ticket.currentStatus = @"#3, Wating on Customer for 6 days";
    ticket.colorCode = [UIColor redColor];
    ticket.timeStamp = @"7m";
    [arrayOfData addObject:ticket];
    
    ticket = [[TicketModel alloc] init];
    ticket.ticketSubject = @"Unable to track package";
    ticket.agentName = @"Saul";
    ticket.currentStatus = @"#2, Overdue by 6 days";
    ticket.colorCode = [UIColor greenColor];
    ticket.timeStamp = @"8d";
    [arrayOfData addObject:ticket];
    
    ticket = [[TicketModel alloc] init];
    ticket.ticketSubject = @"Do you ship perishables to Schmaltzburg?";
    ticket.agentName = @"Bertie";
    ticket.currentStatus = @"#1, Overdue by 3 days";
    ticket.colorCode = [UIColor yellowColor];
    ticket.timeStamp = @"9d";
    [arrayOfData addObject:ticket];
}

@end
