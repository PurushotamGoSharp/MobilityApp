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
#import "RaiseATicketViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "DBManager.h"
#import "RequestModel.h"
#import "Postman.h"

#import "SendRequestsManager.h"
#import "TicketListModel.h"
#import "UserInfo.h"




@interface TicketsListViewController () <UITableViewDataSource, UITableViewDelegate, DBManagerDelegate, TicketListsDelegate>
{
    UIBarButtonItem *backButton;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewOutlet;
@property (weak, nonatomic) IBOutlet UITableView *filterTableView;
@property (weak, nonatomic) IBOutlet UIView *sliderView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *filterBtnOutlet;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filterSliderTrailingConst;

@property (strong ,nonatomic)UIRefreshControl *refreshControl;


@end

@implementation TicketsListViewController
{
    NSMutableArray *arrayOfData, *arrOfTicketLists;
    BOOL filterIsShown;
    NSArray *arrayForStatus, *arrayOfNo;
    
    UIControl *hideFilterControl;
    DBManager *dbManager;
    NSInteger selectedRow;
    Postman  *postMan;
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
   
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localize) name:MCLocalizationLanguageDidChangeNotification object:nil];
    [self localize];

    
    
    arrayOfData = [[NSMutableArray alloc] init];
    self.filterBtnOutlet.imageInsets = UIEdgeInsetsMake(0, 0, 0, 8);
    
    if ([self.orderItemDifferForList isEqualToString:@"orderList"])
    {
        self.title = @"My Orders";
        //        [self setUpDataForOrder];
        
    }else
    {
        //        [self setUpData];
    }
    [self getData];
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setImage:[UIImage imageNamed:@"back_Arrow"] forState:UIControlStateNormal];
    
    
    
    if (self.fromRasieRequsetVC)
    {
        [back setTitle:STRING_FOR_LANGUAGE(@"Back.Survey") forState:UIControlStateNormal];
    }else
    {
        [back setTitle:STRING_FOR_LANGUAGE(@"Home") forState:UIControlStateNormal];
    }
    back.titleLabel.font = [self customFont:16 ofName:MuseoSans_700];
//    back.imageEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
//    back.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
//    back.frame = CGRectMake(0, 0,80, 30);
    [back sizeToFit];
    [back setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    
    [back  addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    backButton = [[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = backButton;
    
    arrayForStatus = @[@"New", @"Assigned", @"In Progress",@"Pending", @"Resolved",@"Closed",@"Cancelled"];
    
    self.filterTableView.separatorColor = [UIColor whiteColor];
    
    filterIsShown = NO;
    self.filterSliderTrailingConst.constant = -self.filterTableView.frame.size.width;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [self subViewsColours];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self
                            action:@selector(pull)
                  forControlEvents:UIControlEventValueChanged];
    
    [self.tableViewOutlet  addSubview:self.refreshControl];
    
    [self tryToLoadListOfTickets];

    
}
-(void)localize
{
    self.title = STRING_FOR_LANGUAGE(@"My.tickets");



}





-(void)tryToLoadListOfTickets
{
    SendRequestsManager *requestManager = [[SendRequestsManager alloc] init];
    requestManager.delegate = self;
    
//    NSDictionary *userInfoDict = [[UserInfo sharedUserInfo] getServerConfig];
//    NSString *firstName = userInfoDict [@"firstName"];
//    NSString *lastName = userInfoDict [@"lastName"];
    
    //    NSString *email = userInfoDict [@"mail"];
    
    NSString *email = [UserInfo sharedUserInfo].emailIDValue;

    NSString *UrL = [NSString stringWithFormat:@"%@email/%@/open/1",URL_TO_GET_LISTOF_TICKETS,email];

    
//    NSString *UrL = [NSString stringWithFormat:@"%@firstName/%@/lastName/%@",URL_TO_GET_LISTOF_TICKETS,firstName,lastName];
    
    [requestManager getListOfTickets:UrL];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)ticketLists:(SendRequestsManager *)ticketList gotSucess:(NSData *)response
{
    [self parseTicketListResponse:response];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)ticketListsFailed:(SendRequestsManager *)ticketList
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

-(void)parseTicketListResponse:(NSData*)responseData
{
    NSDictionary *JSONDict =[NSJSONSerialization JSONObjectWithData:responseData
                                                            options:kNilOptions
                                                              error:nil];
    NSArray *arr = JSONDict[@"tickets"];
    
    arrOfTicketLists = [[NSMutableArray alloc] init];
    
    for (NSDictionary *aDict in arr)
    {
        TicketListModel *aModel = [TicketListModel alloc];
        aModel.serviceName = aDict[@"Summary"];
        aModel.agentname = aDict[@"Assignee"];
        NSString *urgencyString = aDict[@"Urgency"];
        NSArray *components = [urgencyString componentsSeparatedByString:@"-"];
        aModel.impact = [components lastObject];
        aModel.incedentNumber = aDict[@"Incident_Number"];
        aModel.status = aDict[@"Status"];
        aModel.details = aDict[@"Notes"];
        
        [arrOfTicketLists addObject:aModel];
    }
    
    
    [self.tableViewOutlet reloadData];
    
}

- (void)backBtnAction
{
    [self .navigationController popViewControllerAnimated:YES];
}

- (void)pull
{
    [NSThread sleepForTimeInterval:1];
    [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.filterTableView.backgroundColor = [self subViewsColours];
    self.refreshControl.backgroundColor = [self subViewsColours];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData)
                                                 name:REQUEST_SYNC_NOTIFICATION_KEY
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:REQUEST_SYNC_NOTIFICATION_KEY
                                                  object:nil];
}

- (void)reloadData
{
    [self getData];
    
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



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableViewOutlet indexPathForSelectedRow];
    TicketDetailViewController *ticketDeteilVC = segue.destinationViewController;
    //    ticketDeteilVC.requestModel = arrayOfData[indexPath.row];
    
    //    NSUInteger row = [indexPath row];
    //    NSUInteger count = [arrayOfData count];
    //    ticketDeteilVC.requestModel = arrayOfData[count-row-1];
    
    ticketDeteilVC.tickrtListModel = arrOfTicketLists[indexPath.row];
    
    if ([self.orderItemDifferForList isEqualToString:@"orderList"])
    {
        ticketDeteilVC.orderItemDifferForList = @"orderList";
    }
}

- (IBAction)filterButtonPressed:(UIBarButtonItem *)sender
{
    CGFloat constraintValue = 0.0;
    [self.filterTableView reloadData];
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.tableViewOutlet])
    {
        return [arrOfTicketLists count];
    }
    
    return [arrayForStatus count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if ([tableView isEqual:self.tableViewOutlet])
    {
        TicketsListCell *ticketCell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        //        ticketCell.requestModel = arrayOfData[indexPath.row];
        
        //        NSUInteger row = [indexPath row];
        //        NSUInteger count = [arrayOfData count];
        //        ticketCell.requestModel = arrayOfData[count-row-1];
        
        ticketCell.ticketListModel = arrOfTicketLists[indexPath.row];
        
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [self barColorForIndex:selectedRow];
        [ticketCell setSelectedBackgroundView:bgColorView];
        
        cell = ticketCell;
        
    }
    else if ([tableView isEqual:self.filterTableView])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
        UIImageView *whiteCircleImage = (UIImageView*)[cell viewWithTag:100];
        whiteCircleImage.image = [UIImage imageNamed:@"WhiteCircle"];
        
        UILabel *statusLabel = (UILabel *)[cell viewWithTag:101];
        statusLabel.text = arrayForStatus[indexPath.row];
        
        statusLabel.font=[self customFont:16 ofName:MuseoSans_700];
        statusLabel.highlightedTextColor = [UIColor whiteColor];
        
        UILabel *countlabel = (UILabel *)[cell viewWithTag:102];
        
        if (indexPath.row == 0 &&  [arrayOfData count] > 0)
        {
            countlabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)[arrayOfData count]];
            
        }else
            countlabel.text = @"";
        
        if ([countlabel.text isEqualToString:@""])
        {
            countlabel.hidden = YES;
            whiteCircleImage.hidden = YES;
        }else
        {
            countlabel.hidden = NO;
            whiteCircleImage.hidden = NO;
        }
        
        countlabel.font=[self customFont:16 ofName:MuseoSans_700];
        //        countlabel.highlightedTextColor = [UIColor whiteColor];
        
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [self barColorForIndex:kNilOptions];
        [cell setSelectedBackgroundView:bgColorView];
    }
    
    cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableViewOutlet])
    {
        selectedRow=indexPath.row;
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

- (void)getData
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate=self;
    }
    
    NSString *queryString;
    
    if ([self.orderItemDifferForList isEqualToString:@"orderList"])
    {
        queryString = @"SELECT * FROM raisedOrders";
    }else
    {
        queryString = @"SELECT * FROM raisedTickets";
    }
    
    [dbManager getDataForQuery:queryString];
    
    [self.tableViewOutlet reloadData];
    
}

- (void)DBManager:(DBManager *)manager gotSqliteStatment:(sqlite3_stmt *)statment
{
    [arrayOfData removeAllObjects];
    NSDateFormatter *converter = [[NSDateFormatter alloc] init];
    //    [converter setDateFormat:@"hh:mm a, dd MMM, yyyy"];
    
    [converter setDateFormat:@"yyyy MM dd HH mm ss"];
    
    while (sqlite3_step(statment) == SQLITE_ROW)
    {
        RequestModel *request = [[RequestModel alloc] init];
        
        request.requestImpact = sqlite3_column_int(statment, 1);
        request.requestServiceCode = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 2)];
        request.requestServiceName = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 3)];
        request.requestDetails = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 4)];
        
        const char *date = (const char *)sqlite3_column_text(statment, 5);
        if (date != NULL)
        {
            NSString *dateInString = [NSString stringWithUTF8String:date];
            request.requestDate = [converter dateFromString:dateInString];
        }
        
        const char *incidentNo = (const char *)sqlite3_column_text(statment, 7);
        if (incidentNo != NULL)
        {
            request.requestIncidentNo = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 7)];
        }
        [arrayOfData addObject:request];
    }
    
}

@end
