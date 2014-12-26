//
//  MessagesViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 03/12/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "MessagesViewController.h"
#import "MessageDetailViewController.h"
#import "messageModle.h"
#import "DashBoardViewController.h"

@interface MessagesViewController () <UITableViewDataSource,UITableViewDelegate>
{
    NSArray *arrOfTableData, *arrOfTimeLable, *arrOfSubjects, *arrOfBody, *arrOfimageName, *arrOfcurTime;
    NSMutableArray *arrOfModleData; UIBarButtonItem *backButton;
    

   





}
@property (weak, nonatomic) IBOutlet UITableView *tableViewOutlet;
@property (strong ,nonatomic)UIRefreshControl *refreshControl;


@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    arrOfTableData = @[@"Web server will be down tomorrow", @"Updated dress code rules",@"Employee Awareness program is to be conducted on Dec 21"];
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setImage:[UIImage imageNamed:@"back_Arrow"] forState:UIControlStateNormal];
    [back setTitle:@"Back" forState:UIControlStateNormal];
    
    back.frame = CGRectMake(0, 0,70, 40);
    [back setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    back.titleLabel.font = [self customFont:20 ofName:MuseoSans_700];
    [back  addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    backButton = [[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = backButton;
 
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [self subViewsColours];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self
                            action:@selector(pull)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableViewOutlet  addSubview:self.refreshControl];

    
    
    
    
    arrOfTableData = @[@"Infra",@"Payroll",@" Helpdesk",@"HR policy: ",@"HR: Holiday Celebration: ",@"IS: Maintenance Activity"];
    
    arrOfSubjects = @[@"This mail is being sent to all employees on behalf of ISMS Team",@"Greetings from UCB Payroll Help Desk",@"SVN Credentials",@"Employee Awareness: “Official Dress Code”",@"Merry Christmas & A Happy New Year 2015!!!",@"IS Maintenance Activity on 26.07.2014"];
    
    arrOfcurTime = @[@"Thu, Dec 11, 2014",@"Mon Dec 8, 2014",@"Thu Nov 27, 2014",@"Mon Nov 17, 2014",@"Fri Dec 12, 2014",@"Fri Jul 25, 2014"];

    
    arrOfBody = @[@"Dear all, \nThis email is the second part of an Employee Awareness Program about Information Security in preparation for our ISO 27001 External Audit. Please read carefully some important Employee responsibilities and organization policies. The Ucb Security Policy, Confidentiality, Access and Physical security policies have been sent in yesterday’s email.",@"We are happy to inform you that UCB Payroll Help Desk is available online and here is useful information on how to access and utilize the facility",@"Hi,\n Please find your SVN Credentials below",@"Dear All,\nThis is to inform all the employees that the policy on “Official Dress Code” under Dress Code is being revised effective on Mon December 01, 2014.Dress code for external customer meetings will be Business Formals (to create the winning impression!!!). Business Formals will include - salwar suits and sarees, western formal skirts / trousers for ladies. Full/ half sleeved light-coloured shirts with tie and (jacket / coat optional) formal trousers for gentlemen. Footwear must be formal leather-shoes for men.Monday and Tuesday are considered as Business days and dress code will be Business formals. Business formals will include salwar suits and western skirts / trousers for ladies. Full/ half sleeved shirts tucked in and trousers for gentlemen. For men footwear must be formal shoes.",@"Dear All,\nMay this Christmas and New Year sparkle and shine. May all your wishes and dreams come true and may you feel this happiness all year round.So let’s get into Christmassy mood!!!Events:Cubical decoration – theme Christmas!Fun filled gamesSecret Santa Lucky Draw Venue: VM Cafeteria 4th floor Date & Time: 23rd Dec, 2014 @ 3PM Dress Code: Red & White\n\nThanks.\nHuman Resource",@"Dear All,\nThis is to inform you that there will be a fluctuation in the network connectivity due to maintenance activity on 26.07.2014 from 10:30 AM to 04:00 PM Services affected: Network, Network Shared Folders, Internet and VOIP services you to schedule your activities accordingly. Please contact helpdesk for any queries.\n\nThanks\n IS Team"];
    
    
    
    arrOfTimeLable = @[@"12 h",@"3 d",@"14 d",@"17 d",@"20 d",@"21 d",@"20 d"];
    
    arrOfimageName = @[@"MessageClosed"];
    
    arrOfModleData = [[NSMutableArray alloc] init];
    
    for (int i =0; i< arrOfTableData.count; i++)
    {
        messageModle *aMessage = [[messageModle alloc] init];
        aMessage.name = arrOfTableData[i];
        aMessage.subject = arrOfSubjects[i];
        aMessage.body = arrOfBody[i];
        aMessage.time = arrOfcurTime[i];
        [arrOfModleData addObject:aMessage];
    }
    
}

-(void)backBtnAction
{
    [self.tabBarController setSelectedIndex:0];

}

-(void)pull
{

    [NSThread sleepForTimeInterval:1];
    [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
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
//    if ([segue.identifier isEqualToString:@"message_segue"])
//    {
//        NSIndexPath *indexPath = [self.tableViewOutlet indexPathForSelectedRow];
//        MessageDetailViewController *messageDeteilVC = segue.destinationViewController;
//        messageModle *message = arrOfModleData[indexPath.row];
//        messageDeteilVC.mesgModel = message;
//    }

    NSIndexPath *indexPath = [self.tableViewOutlet indexPathForSelectedRow];
    MessageDetailViewController *messageDeteilVC = segue.destinationViewController;
    messageModle *message = arrOfModleData[indexPath.row];
    messageDeteilVC.mesgModel = message;

}

#pragma mark UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrOfTableData count];
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    UILabel *titleLable = (UILabel *)[cell viewWithTag:100];
    titleLable.text = arrOfTableData[indexPath.row];
    titleLable.font=[self customFont:18 ofName:MuseoSans_700];
    
    
    
    UILabel *timeTitleLable = (UILabel *)[cell viewWithTag:200];
    timeTitleLable.text = arrOfTimeLable[indexPath.row];
    
    UILabel *subjectTitleLable = (UILabel *)[cell viewWithTag:300];
    subjectTitleLable.text = arrOfSubjects[indexPath.row];
    subjectTitleLable.font= [self customFont:20 ofName:MuseoSans_300];
    
    
    
    
    UILabel *bodyTitleLable = (UILabel *)[cell viewWithTag:400];
    bodyTitleLable.text = arrOfBody[indexPath.row];
    bodyTitleLable.font=[self customFont:14 ofName:MuseoSans_300];
   
    
    
    UIImageView *mailImageView = (UIImageView *)[cell viewWithTag:500];

    if (indexPath.row == 0 || indexPath.row == 1) {
        mailImageView.image = [UIImage imageNamed:arrOfimageName[0]];
    }else
    {
        
    }


    return cell;
}

#pragma mark UITableViewDelegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
//    if ([segue.identifier isEqualToString:@"message_segue"])

    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    if (indexPath.row == 0)
//    {
//        [self performSegueWithIdentifier:@"message_segue" sender:nil];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
