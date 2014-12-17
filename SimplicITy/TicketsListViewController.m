//
//  TicketsListViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/11/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "TicketsListViewController.h"
#import "TicketsListCell.h"
#import "TicketDetailViewController.h"
#import "TicketModel.h"

@interface TicketsListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewOutlet;
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableViewOutlet indexPathForSelectedRow];
    TicketDetailViewController *ticketDeteilVC = segue.destinationViewController;
    TicketModel *ticket = arrayOfData[indexPath.row];
    ticketDeteilVC.tickModel = ticket;
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
    ticket.ticketSubject = @"Provide VPN access";
    ticket.agentName = @"Jonathan";
    ticket.currentStatus = @"# 10, Overdue for 1 day";
    ticket.colorCode = [UIColor redColor];
    ticket.timeStamp = @"7 m";
    [arrayOfData addObject:ticket];
    

    
    
    ticket = [[TicketModel alloc] init];
    ticket.ticketSubject = @"Internet is very slow";
    ticket.agentName = @"Jim";
    ticket.currentStatus = @"#9, Overdue for 2 days";
    ticket.colorCode = [UIColor greenColor];
    ticket.timeStamp = @"45 m";
    [arrayOfData addObject:ticket];

    
    ticket = [[TicketModel alloc] init];
    ticket.ticketSubject = @"My leave application password been expired and unable to reset it ";
    ticket.agentName = @"Irene";
    ticket.currentStatus = @"#8, Overdue for 3 days";
    ticket.colorCode = [UIColor orangeColor];
    ticket.timeStamp = @"2 h";
    
    [arrayOfData addObject:ticket];
    ticket = [[TicketModel alloc] init];
    ticket = [[TicketModel alloc] init];
    ticket.ticketSubject = @"VPN is not accessible outside work";
    ticket.agentName = @"Christina";
    ticket.currentStatus = @"#7, Overdue by 3 days";
    ticket.colorCode = [UIColor yellowColor];
    ticket.timeStamp = @"6 h";
    [arrayOfData addObject:ticket];

    ticket = [[TicketModel alloc] init];
    ticket.ticketSubject = @"Cannot download any file to my desktop";
    ticket.agentName = @"Monica";
    ticket.currentStatus = @"#6, Waiting for the customer reply for 2 days";
    ticket.colorCode = [UIColor redColor];
    ticket.timeStamp = @"1 d";
    [arrayOfData addObject:ticket];
    
    ticket = [[TicketModel alloc] init];
    ticket.ticketSubject = @"Unable to make any outside call from my desk phone";
    ticket.agentName = @"Richard";
    ticket.currentStatus = @"#5, Overdue by 4 days";
    ticket.colorCode = [UIColor greenColor];
    ticket.timeStamp = @"3 d";
    [arrayOfData addObject:ticket];
    
    ticket = [[TicketModel alloc] init];
    ticket.ticketSubject = @"Unable to access my office email";
    ticket.agentName = @"Anthony";
    ticket.currentStatus = @"#4, Overdue by 2 days";
    ticket.colorCode = [UIColor yellowColor];
    ticket.timeStamp = @"5 d";
    [arrayOfData addObject:ticket];
    
    ticket = [[TicketModel alloc] init];
    ticket.ticketSubject = @"I'm unacle to connect my console to internet";
    ticket.agentName = @"Bertie";
    ticket.currentStatus = @"#3, Wating on Customer for 6 days";
    ticket.colorCode = [UIColor orangeColor];
    ticket.timeStamp = @"7 d";
    [arrayOfData addObject:ticket];
    
    ticket = [[TicketModel alloc] init];
    ticket.ticketSubject = @"Unable to track package";
    ticket.agentName = @"Saul";
    ticket.currentStatus = @"#2, Overdue by 6 days";
    ticket.colorCode = [UIColor greenColor];
    ticket.timeStamp = @"8 d";
    [arrayOfData addObject:ticket];
    
    ticket = [[TicketModel alloc] init];
    ticket.ticketSubject = @"Do you ship perishables to Schmaltzburg?";
    ticket.agentName = @"Bertie";
    ticket.currentStatus = @"#1, Overdue by 3 days";
    ticket.colorCode = [UIColor yellowColor];
    ticket.timeStamp = @"9 d";
    [arrayOfData addObject:ticket];

}

@end
