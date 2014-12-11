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

@interface MessagesViewController () <UITableViewDataSource,UITableViewDelegate>
{
    NSArray *arrOfTableData, *arrOfTimeLable, *arrOfSubjects, *arrOfBody, *arrOfimageName, *arrOfcurTime;
    NSMutableArray *arrOfModleData;
}
@property (weak, nonatomic) IBOutlet UITableView *tableViewOutlet;

@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    arrOfTableData = @[@"Web server will be down tomorrow", @"Updated dress code rules",@"Employee Awareness program is to be conducted on Dec 21"];
    arrOfTableData = @[@"UCBcommunique",@"Payroll HelpDesk",@"UCB helpdesk"];
    
    arrOfSubjects = @[@"This mail is being sent to all employees on behalf of ISMS Team",@"Greetings from UCB Payroll Help Desk",@"SVN Credentials"];
    
    arrOfBody = @[@"Dear all,This email is the second part of an Employee Awareness Program about Information Security in preparation for our ISO 27001 External Audit. Please read carefully some important Employee responsibilities and organization policies. The Ucb Security Policy, Confidentiality, Access and Physical security policies have been sent in yesterday’s email.",@"We are happy to inform you that UCB Payroll Help Desk is available online and here is useful information on how to access and utilize the facility",@"Hi, Please find your SVN Credentials below"];
    
        arrOfTimeLable = @[@"12h",@"3d",@"14d",@"17d"];
    arrOfcurTime = @[@"Thu, Dec 11, 2014",@"Mon Dec 8, 2014",@"Thu Nov 27, 2014"];
    
    arrOfimageName = @[@"MessageClosed.png"];
    
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

 -(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
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
    
    UILabel *timeTitleLable = (UILabel *)[cell viewWithTag:200];
    timeTitleLable.text = arrOfTimeLable[indexPath.row];
    
    UILabel *subjectTitleLable = (UILabel *)[cell viewWithTag:300];
    subjectTitleLable.text = arrOfSubjects[indexPath.row];
    
    UILabel *bodyTitleLable = (UILabel *)[cell viewWithTag:400];
    bodyTitleLable.text = arrOfBody[indexPath.row];
    
   
    UIImageView *mailImageView = (UIImageView *)[cell viewWithTag:500];

    if (indexPath.row == 0 ) {
        mailImageView.image = [UIImage imageNamed:arrOfimageName[indexPath.row]];
    }else
    {
        
    }


    return cell;
}

#pragma mark UITableViewDelegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
