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
#import "RaiseATicketViewController.h"

@interface TicketsListViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UIBarButtonItem *backButton;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewOutlet;
@property (weak, nonatomic) IBOutlet UITableView *filterTableView;
@property (weak, nonatomic) IBOutlet UIView *sliderView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filterSliderTrailingConst;

@property (strong ,nonatomic)UIRefreshControl *refreshControl;

@end

@implementation TicketsListViewController
{
    NSMutableArray *arrayOfData;
    BOOL filterIsShown;
    NSArray *arrayForStatus, *arrayOfNo;
    
    UIControl *hideFilterControl;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    arrayOfData = [[NSMutableArray alloc] init];
    [self setUpData];
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setTitle:@"< Back" forState:UIControlStateNormal];
    back.frame = CGRectMake(0, 0, 60, 40);
    [back setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [back  addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    backButton = [[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = backButton;

    
    arrayForStatus = @[@"New", @"Assigned", @"In Progress",@"Pending", @"Resolved",@"Closed",@"Cancelled"];
    arrayOfNo = @[@"2", @"1", @"1", @"3",@"1",@"1",@"1"];
    
    self.filterTableView.separatorColor = [self seperatorColours];
    
    filterIsShown = NO;
    self.filterSliderTrailingConst.constant = -self.filterTableView.frame.size.width;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [self subViewsColours];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self
                            action:@selector(pull)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableViewOutlet  addSubview:self.refreshControl];
}

-(void)backBtnAction
{
    [self.navigationController popViewControllerAnimated:YES];

}

-(void)pull
{
    
    [NSThread sleepForTimeInterval:1];
    [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.filterTableView.backgroundColor = [self subViewsColours];

}

- (void)reloadData
{
    // Reload table data
    [self.tableViewOutlet reloadData];
    
    // End the refreshing
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        [self.refreshControl endRefreshing];
    }

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableViewOutlet indexPathForSelectedRow];
    TicketDetailViewController *ticketDeteilVC = segue.destinationViewController;
    TicketModel *ticket = arrayOfData[indexPath.row];
    ticketDeteilVC.tickModel = ticket;
}
- (IBAction)filterButtonPressed:(UIBarButtonItem *)sender
{
    CGFloat constraintValue = 0.0;
    
    if (!hideFilterControl)
    {
        hideFilterControl = [[UIControl alloc] initWithFrame:self.view.frame];
        [hideFilterControl addTarget:self action:@selector(hideFilter:) forControlEvents:(UIControlEventTouchDown)];
        hideFilterControl.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    if (filterIsShown)
    {
        constraintValue = -self.filterTableView.frame.size.width;
        [hideFilterControl removeFromSuperview];
        hideFilterControl = nil;
    }else
    {
        [self.view addSubview:hideFilterControl];
        
//Adding constaint for hideview so that all sides are fixed to view edges so it will grow as view grows
        NSDictionary *viewsDict = NSDictionaryOfVariableBindings(hideFilterControl);
        NSArray *constaints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[hideFilterControl]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:viewsDict];
        [self.view addConstraints:constaints];
        
        constaints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[hideFilterControl]|"
                                                             options:0
                                                             metrics:nil
                                                               views:viewsDict];
        [self.view addConstraints:constaints];
        
        [self.view bringSubviewToFront:self.sliderView];
    }

    [UIView animateWithDuration:.3
                          delay:0
                        options:(UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         self.filterSliderTrailingConst.constant = constraintValue;
                         [self.view layoutIfNeeded];
                         
                     } completion:^(BOOL finished) {
                         
                         if (!filterIsShown)
                         {
                         }
                     }];
    
    filterIsShown = !filterIsShown;
}

- (void)hideFilter:(UIControl *)hideControl
{
    filterIsShown = NO;
    [UIView animateWithDuration:.3
                          delay:0
                        options:(UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         
                         self.filterSliderTrailingConst.constant = -self.filterTableView.frame.size.width;
                         [self.view layoutIfNeeded];
                         [hideFilterControl removeFromSuperview];

                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.tableViewOutlet])
    {
        return [arrayOfData count];
    }
    
    return [arrayForStatus count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if ([tableView isEqual:self.tableViewOutlet])
    {
        TicketsListCell *ticketCell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        ticketCell.ticketModel = arrayOfData[indexPath.row];
        cell = ticketCell;
        
    }else if ([tableView isEqual:self.filterTableView])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        UILabel *statusLabel = (UILabel *)[cell viewWithTag:101];
        statusLabel.text = arrayForStatus[indexPath.row];
        
        UILabel *countlabel = (UILabel *)[cell viewWithTag:102];
        countlabel.text = arrayOfNo[indexPath.row];
        

        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor colorWithRed:.7 green:0 blue:0 alpha:1];
        [cell setSelectedBackgroundView:bgColorView];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableViewOutlet])
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
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
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *cureentDate = [formatter stringFromDate:[NSDate date]];
    
    TicketModel *ticket = [[TicketModel alloc] init];
    ticket.ticketSubject = @"Identity Service";
    ticket.agentName = @"Jonathan";
    ticket.ticketNum = @"# 10345";
    ticket.currentStatus = @"New";
    ticket.date =cureentDate;
    ticket.colorCode = [UIColor redColor];
    ticket.timeStamp = @"1 m";
    ticket.details=@"Please install the VPN software on my laptop. Please enable it ASAP.";
    [arrayOfData addObject:ticket];

    ticket = [[TicketModel alloc] init];
    ticket.ticketSubject = @"Authentication";
    ticket.agentName = @"Jim";
    ticket.ticketNum = @"# 10445";
    ticket.currentStatus = @"New";
    ticket.date =cureentDate;

    ticket.colorCode = [UIColor colorWithRed:.37 green:.72 blue:.38 alpha:1];
    ticket.timeStamp = @"2 m";
    ticket.details = @"Work is affecting as not able to open any application. Please fix the issue ASAP as it is affecting the projects.";
    
    [arrayOfData addObject:ticket];

    ticket = [[TicketModel alloc] init];
    ticket.ticketSubject = @"Others";
    ticket.agentName = @"Irene";
    ticket.ticketNum = @"#87655";
    ticket.currentStatus = @"Pending";
    ticket.colorCode = [UIColor orangeColor];
    ticket.timeStamp = @"2 h";
    ticket.date =cureentDate;

    ticket.details = @" Please reset the leave Application password";
    [arrayOfData addObject:ticket];
    
    ticket = [[TicketModel alloc] init];
    ticket = [[TicketModel alloc] init];
    ticket.ticketSubject = @"Messaging";
    ticket.agentName = @"Christina";
    ticket.ticketNum = @"#75677";

    ticket.currentStatus = @"Assigned";
    ticket.colorCode = [UIColor yellowColor];
    ticket.timeStamp = @"6 h";
    ticket.date =cureentDate;
    ticket.details = @"Access Management";
    [arrayOfData addObject:ticket];

    ticket = [[TicketModel alloc] init];
    ticket.ticketSubject = @"Productivity Software";
    ticket.agentName = @"Monica";
    ticket.ticketNum = @"#65676";
    ticket.date =@"2014/12/21";
    ticket.currentStatus = @"In progress";
    ticket.colorCode = [UIColor redColor];
    ticket.timeStamp = @"1 d";
    ticket.details = @"It is restricting me from downloading any email attachment. Can you please grant me the access?";
    [arrayOfData addObject:ticket];
    
    
    ticket = [[TicketModel alloc] init];
    ticket.ticketSubject = @"Desktop";
    ticket.agentName = @"Richard";
    ticket.ticketNum = @"#55678";

    ticket.currentStatus = @"Cancelled";
    ticket.colorCode = [UIColor colorWithRed:.37 green:.72 blue:.38 alpha:1];
    ticket.timeStamp = @"3 d";
    ticket.details = @"Can you please grant external call facility from my office phone?";
     ticket.date =@"2014/12/19";
    
    [arrayOfData addObject:ticket];
    
    ticket = [[TicketModel alloc] init];
    ticket.ticketSubject = @"Collaboration Services";
    ticket.agentName = @"Anthony";
    ticket.ticketNum = @"#46786";
   ticket.currentStatus = @"Resolved";
    ticket.colorCode = [UIColor yellowColor];
    ticket.timeStamp = @"5 d";
    ticket.details = @"Need to reset my email password, as I am not able to log in to my email account.";
   [arrayOfData addObject:ticket];
    ticket.date =@"2014/12/17";
    
    
    
    
    ticket = [[TicketModel alloc] init];
    ticket.ticketSubject = @"Server";
    ticket.agentName = @"Bertie";
    ticket.ticketNum = @"#36766";
    ticket.currentStatus = @"Closed";
    ticket.colorCode = [UIColor orangeColor];
    ticket.timeStamp = @"7 d";
    ticket.date =@"2014/12/15";
    [arrayOfData addObject:ticket];
    
    ticket = [[TicketModel alloc] init];
    ticket.ticketSubject = @"SAP PE1";
    ticket.agentName = @"Saul";
    ticket.ticketNum = @"#26786";
    ticket.currentStatus = @"Resolved";
    ticket.colorCode = [UIColor colorWithRed:.37 green:.72 blue:.38 alpha:1];
    ticket.timeStamp = @"8 d";
    ticket.date =@"2014/12/14";
    [arrayOfData addObject:ticket];
    
    ticket = [[TicketModel alloc] init];
    ticket.ticketSubject = @"Mobile";
    ticket.agentName = @"Bertie";
    ticket.ticketNum = @"#16778";

    ticket.currentStatus = @"Closed";
    ticket.colorCode = [UIColor yellowColor];
    ticket.timeStamp = @"9 d";
    ticket.date =@"2014/12/13";
    [arrayOfData addObject:ticket];

}

@end
