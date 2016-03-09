//
//  TicketDetailViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/16/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "TicketDetailViewController.h"
#import "DashBoardViewController.h"
#import "UserInfo.h"

@interface TicketDetailViewController () <UITableViewDataSource,UITableViewDelegate>
{
    NSArray *arrOfLable;
    UIBarButtonItem *backButton;
    NSDateFormatter *dateFormatter;
    NSString *ticketnumber;
     NSString *requester;
   NSString *personalImpact;
    NSString *agent;
    NSString *status;
    NSString *details;


}
@property (weak, nonatomic) IBOutlet UITableView *tableViewOutlet;

@end

@implementation TicketDetailViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arrOfLable = @[@"Requester",@"Personal Impact",@"Services",@"Agent",@"Status"];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a, dd MMM, yyyy"];
    
    if ([self.orderItemDifferForList isEqualToString:@"orderList"])
    {
        self.title = @"Order Details";
    }else
    {
        self.title = @"Ticket Details";
    }
    
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localize) name:MCLocalizationLanguageDidChangeNotification object:nil];
    [self localize];



}

-(void)localize
{
    self.title = STRING_FOR_LANGUAGE(@"Ticket.Details");
    ticketnumber = STRING_FOR_LANGUAGE(@"Ticket.Number");
    requester = STRING_FOR_LANGUAGE(@"Requester");
    personalImpact = STRING_FOR_LANGUAGE(@"Personal.Impact");
    agent = STRING_FOR_LANGUAGE(@"Agent");
    status = STRING_FOR_LANGUAGE(@"Status");
    details = STRING_FOR_LANGUAGE(@"Details");
    
    
    
}






- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    return 2;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 5;
    }
    
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,  tableView.bounds.size.width, 30)];
    
    UILabel *labelHeader = [[UILabel alloc] initWithFrame:CGRectMake (17,4,320,30)];
    labelHeader.font = [self customFont:16 ofName:MuseoSans_700];
    labelHeader.textColor = [UIColor blackColor];
    [headerView addSubview:labelHeader];
    
    
    if (section == 0)
    {
        
        
    }else if (section == 1)
    {
        //        if ([self.orderItemDifferForList isEqualToString:@"orderList"])
        //        {
        //            labelHeader.text = @"Item";
        //        }else
        //        {
        //            labelHeader.text = @"Service";
        //        }
        //
        //    }
        //    else
        //    {
        labelHeader.text = details;
    }
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellDetails" forIndexPath:indexPath];
    }else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    }
    
    UILabel *titleLable = (UILabel *)[cell viewWithTag:100];
    
    titleLable.font=[self customFont:16 ofName:MuseoSans_700];
    
    
    UILabel *circelColour = (UILabel *)[cell viewWithTag:102];
    UILabel *rightTable = (UILabel *)[cell viewWithTag:103];
    rightTable.font=[self customFont:16 ofName:MuseoSans_300];
    
    //    UILabel *discriptionLable = (UILabel *)[cell1 viewWithTag:104];
    
    rightTable.hidden = NO;
    circelColour.layer.cornerRadius = 10;
    titleLable.textColor = [UIColor blackColor];
    
    //    if (indexPath.section == 1)
    //    {
    //        titleLable.text = self.tickrtListModel.serviceName;
    //        rightTable.text = @"";
    //        titleLable.font=[self customFont:16 ofName:MuseoSans_300];
    //        titleLable.textColor = [UIColor lightGrayColor];
    //    }
    //    else
    if (indexPath.section == 1)
    {
        UILabel *titleTextView = (UILabel *)[cell viewWithTag:100];
        NSString *detail = self.tickrtListModel.details.length?self.tickrtListModel.details:self.tickrtListModel.serviceName;
        titleTextView.text = detail;
        titleTextView.textAlignment = NSTextAlignmentJustified;
        rightTable.hidden = YES;
        titleTextView.textColor = [UIColor lightGrayColor];
        titleTextView.font = [self customFont:16 ofName:MuseoSans_300];
        
    }
    else
    {
        switch (indexPath.row)
        {
                
            case 0:
                if ([self.orderItemDifferForList isEqualToString:@"orderList"])
                {
                    titleLable.text = @"Order Number";
                    
                }else
                {
                    titleLable.text = ticketnumber;
                }
                
                rightTable.text = self.tickrtListModel.incedentNumber;
                break;
                
            case 1:
                titleLable.text =requester;
                rightTable.text = [UserInfo sharedUserInfo].fullName?:@"Test User";;
                break;
                
            case 2:
                titleLable.text = personalImpact;
                
                rightTable.text = self.tickrtListModel.impact;
                //                rightTable.text = [self giveImpactForCOlor:self.tickrtListModel.requestImpact];
                //                linColour.backgroundColor = [self colorForImpact:self.tickrtListModel.requestImpact];
                //                circelColour.backgroundColor = [self colorForImpact:self.tickrtListModel.requestImpact];
                break;
                
            case 3:
                titleLable.text = agent;
                //                rightTable.text = self.tickModel.agentName;
                rightTable.text = self.tickrtListModel.agentname;
                break;
                
            case 4:
                titleLable.text = status;
                //                rightTable.text = self.tickModel.currentStatus;
                rightTable.text = self.tickrtListModel.status;
                break;
                
                //            case 5:
                //                titleLable.text = @"Date";
                //                //                rightTable.text = self.tickModel.date;
                ////                rightTable.text = [dateFormatter stringFromDate:self.tickrtListModel.requestDate];
                //                break;
                
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
    if (indexPath.section == 1)
    {
        CGFloat widthLabel = [UIScreen mainScreen].bounds.size.width - 20;
        CGSize maximumLabelSize = CGSizeMake(widthLabel, FLT_MAX);
        
        
        CGSize expectedLabelSize = [self.tickrtListModel.details boundingRectWithSize:maximumLabelSize
                                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                                           attributes:@{ NSFontAttributeName : [self customFont:16 ofName:MuseoSans_300] }
                                                                              context:nil].size;
        
        CGFloat heigthOFcell = expectedLabelSize.height + 20 + 20;
        
        heigthOFcell = MAX(44, heigthOFcell);
        
        return heigthOFcell;
    }
    
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 35;
    }
    return 0;
}

- (NSString *)giveImpactForCOlor:(NSInteger)colorCode
{
    switch (colorCode)
    {
        case 0:
            return @"Low";
            break;
            
        case 1:
            return @"Medium";
            break;
            
        case 2:
            return @"High";
            break;
            
        case 3:
            return @"Critical";
            break;
            
        default:
            break;
    }
    
    return nil;
}


- (UIColor *)colorForImpact:(NSInteger)imapact
{
    switch (imapact)
    {
        case 0:
            return [UIColor greenColor];
            break;
            
        case 1:
            return [UIColor yellowColor];
            break;
            
        case 2:
            return [UIColor orangeColor];
            break;
            
        case 3:
            return [UIColor redColor];
            break;
            
        default:
            break;
    }
    
    return nil;
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
