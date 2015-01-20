//
//  DashBoardViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/3/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "DashBoardViewController.h"
#import "MessagesViewController.h"
#import "RaiseATicketViewController.h"
#import "TicketsListViewController.h"
#import "ServiceDeskNumListsViewController.h"
#import "Postman.h"
#import "LocationModel.h"
#import "DBManager.h"
#import "UserInfo.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface DashBoardViewController () <postmanDelegate,DBManagerDelegate>
{
    BOOL navBtnIsOn;
    UIButton *titleButton;
    UIImageView *downArrowImageView;
//    NSDictionary *serverConfig;
    UIView *titleView;
    UIImageView *titleImageView;
    NSMutableArray *locationdataArr ;
    LocationModel *selectedLocation;
    DBManager *dbManager;
    
    UserInfo *userInfo;
    
    Postman *postMan;
}
@property (weak, nonatomic) IBOutlet UIButton *navtitleBtnoutlet;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *profileViewOutlet;
@property (weak, nonatomic) IBOutlet UILabel *dashBoardOrder;
@property (weak, nonatomic) IBOutlet UILabel *dashBoardMessage;
@property (weak, nonatomic) IBOutlet UILabel *dashBoardCallHelpDesk;
@property (weak, nonatomic) IBOutlet UILabel *dashBoardTips;
@property (weak, nonatomic) IBOutlet UILabel *dashBoardSetting;
@property (weak, nonatomic) IBOutlet UILabel *dashBoardTicket;
@property (weak, nonatomic) IBOutlet UILabel *dashBoardPersonName;
@property (weak, nonatomic) IBOutlet UILabel *dashBoardPersonCode;
@property (weak, nonatomic) IBOutlet UILabel *dashMyTicketsLabel;
@property (weak, nonatomic) IBOutlet UILabel *dashMyOrdersLabel;
@property (weak, nonatomic) IBOutlet UILabel *dashWebClipLabel;
@property (weak, nonatomic) IBOutlet UILabel *dashBoardPersonAddress;
@property (weak, nonatomic) IBOutlet UILabel *emailID;
@property (weak, nonatomic) IBOutlet UILabel *nameOfUserLabel;

@end

@implementation DashBoardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navtitleBtnoutlet.selected = NO;
    
    self.profileViewTopConstraint.constant = -107;
    
    titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DashBoardNavBarPersonImage"]];
    titleImageView.frame = CGRectMake(0, 5, 32, 32);
//    titleImageView.center = CGPointMake(20, 20);
    
    titleButton = [[UIButton alloc] init];
    [titleButton addTarget:self action:@selector(navTitleBtnPressed:) forControlEvents:(UIControlEventTouchUpInside)];
    [titleButton setTitleColor:([UIColor whiteColor]) forState:(UIControlStateNormal)];
    //    [titleButton setImage:[UIImage imageNamed:@"perso_Small.png"] forState:UIControlStateNormal];
    titleButton.titleLabel.textColor = [UIColor whiteColor];
    [titleButton setTitle:@"Jim" forState:(UIControlStateNormal)];
    titleButton.titleLabel.font = [self customFont:20 ofName:MuseoSans_700];
    titleButton.frame = CGRectMake(titleImageView.frame.size.width+5, 0, 0, 0);
    [titleButton sizeToFit];
    
    CGFloat widthOfView = titleButton.frame.size.width + titleImageView.frame.origin.x +30;
    titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthOfView, 40)];
    [titleView addSubview:titleButton];
    [titleView addSubview:titleImageView];
    
    downArrowImageView = [[UIImageView alloc] initWithImage:([UIImage imageNamed:@"DashBoardDropDownBarImage"])];
    downArrowImageView.frame = CGRectMake(0, 0, 36, 3);
    downArrowImageView.center = CGPointMake(titleView.center.x + 18, titleView.center.y + 18);
    [titleView addSubview:downArrowImageView];
    
    downArrowImageView.hidden = NO;
    
    self.navigationItem.titleView = titleView;
    
    self.dashBoardMessage.font=[self customFont:14 ofName:MuseoSans_300];
    self.dashBoardCallHelpDesk.font=[self customFont:14 ofName:MuseoSans_300];
    self.dashBoardOrder.font=[self customFont:14 ofName:MuseoSans_300];
    self.dashBoardSetting.font=[self customFont:14 ofName:MuseoSans_300];
    self.dashBoardTicket.font=[self customFont:14 ofName:MuseoSans_300];
    self.dashBoardTips.font=[self customFont:14 ofName:MuseoSans_300];
    self.dashBoardPersonName.font=[self customFont:14 ofName:MuseoSans_300];
    self.dashBoardPersonAddress.font=[self customFont:14 ofName:MuseoSans_300];
    self.dashBoardPersonCode.font=[self customFont:14 ofName:MuseoSans_300];
    self.dashMyTicketsLabel.font=[self customFont:14 ofName:MuseoSans_300];
    self.dashMyOrdersLabel.font=[self customFont:14 ofName:MuseoSans_300];
    self.dashWebClipLabel.font=[self customFont:14 ofName:MuseoSans_300];
    
    userInfo = [UserInfo sharedUserInfo];
    selectedLocation = [[LocationModel alloc] init];

    if ([userInfo getServerConfig] != nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:userInfo.location forKey:@"SelectedLocationCode"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self getDataForCountryCode:userInfo.location];
        
        [[NSUserDefaults standardUserDefaults] setObject:selectedLocation.countryName forKey:@"SelectedLocationName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"IND" forKey:@"SelectedLocationCode"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self getDataForCountryCode:@"IND"];
        
        [[NSUserDefaults standardUserDefaults] setObject:selectedLocation.countryName forKey:@"SelectedLocationName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.profileViewOutlet.backgroundColor = [self subViewsColours];
    [self updateProfileView];
    
    postMan = [[Postman alloc] init];
    postMan.delegate = self;

    if ([AFNetworkReachabilityManager sharedManager].reachable)
    {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"country"])
        {
            [self tryToGetITServicePhoneNum];
        }
    }
}

- (void)updateProfileView
{
    if ([userInfo getServerConfig] != nil)
    {
        NSString *cropID = userInfo.cropID;
        NSString *firstName = userInfo.firstName;
        NSString *lastName = userInfo.lastName;
        NSString *location = userInfo.location;
        NSString *emailIDValue = userInfo.emailIDValue;

        NSString *nameOfPerson;
        
        if (cropID)
        {
            self.dashBoardPersonCode.text = cropID;
        }
        
        if (firstName)
        {
            [titleButton setTitle:firstName forState:(UIControlStateNormal)];
            [titleButton sizeToFit];
            
            CGFloat widthOfView = titleButton.frame.size.width + titleImageView.frame.origin.x +30;
            titleView.frame = CGRectMake(0, 0, widthOfView, 40);
            downArrowImageView.center = CGPointMake(titleView.center.x + 18, titleView.center.y + 18);
        }
        
        if (firstName || lastName)
        {
            if (firstName)
            {
                nameOfPerson = [firstName stringByAppendingString:[NSString stringWithFormat:@" %@",lastName]];
                
            }else if (lastName)
            {
                nameOfPerson = lastName;
            }
            
            self.nameOfUserLabel.text = nameOfPerson;
        }
        if (location)
        {
            self.dashBoardPersonAddress.text = location;
        }
        if (emailIDValue)
        {
            self.emailID.text = emailIDValue;
        }
    }
}

- (void)tryToGetITServicePhoneNum
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@",BASE_URL,@"Countries"];
    NSString *parameter =  @"{\"request\":{\"Name\":\"\"}}";
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [postMan post:URLString withParameters:parameter];
}

- (void)postman:(Postman *)postman gotSuccess:(NSData *)response forURL:(NSString *)urlString
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self parseResponseData:response];
    [self saveLocationdata:response forUrl:urlString];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"country"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)postman:(Postman *)postman gotFailure:(NSError *)error forURL:(NSString *)urlString
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)parseResponseData:(NSData *)response
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    NSArray *arr = json[@"aaData"][@"GenericSearchViewModels"];
    locationdataArr = [[NSMutableArray alloc] init];


    for (NSDictionary *aDict in arr)
    {
        if ([aDict[@"Status"]boolValue])
        {
            LocationModel *locationdata = [[LocationModel alloc] init];
            locationdata.code = aDict[@"Code"];
            locationdata.countryCode = aDict[@"CountryCode"];
            locationdata.countryName = aDict[@"Name"];
            NSString *JSONString = aDict[@"ServiceDeskNumber"];
            
            locationdata.serviceDeskNumber = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding]
                                                                             options:kNilOptions
                                                                               error:nil];
            [locationdataArr addObject:locationdata];
        }
    }
}

- (void)saveLocationdata:(NSData *)response forUrl:(NSString *)APILink
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate=self;
    }
    
    NSString *createQuery = @"create table if not exists location (countryCode text PRIMARY KEY, serviceDeskNumber text,countryName text, code text)";
    [dbManager createTableForQuery:createQuery];
    
    NSMutableString *stringFromData = [[NSMutableString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSRange rangeofString;
    rangeofString.location = 0;
    rangeofString.length = stringFromData.length;
    [stringFromData replaceOccurrencesOfString:@"'" withString:@"''" options:(NSCaseInsensitiveSearch) range:rangeofString];
    
    for (LocationModel *alocation in locationdataArr)
    {
        NSData *JSONData = [NSJSONSerialization dataWithJSONObject:alocation.serviceDeskNumber
                                                           options:kNilOptions
                                                             error:nil];
        NSString *serviceDeskNoJSON = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
        
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO  location (countryCode,serviceDeskNumber,countryName,code) values ('%@', '%@','%@', '%@')", alocation.countryCode, serviceDeskNoJSON, alocation.countryName, alocation.code];
        
//                NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO  location (countryCode,serviceDeskNumber,countryName,code) values ('%@', '%@','%@', '%@')", alocation.countryCode, alocation.serviceDeskNumber, alocation.countryName, alocation.code];
        
        [dbManager saveDataToDBForQuery:insertSQL];
    }
    
    
}

- (BOOL)getDataForCountryCode:(NSString *)countryCode
{
    
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate=self;
    }
    
        NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM location WHERE countryCode = '%@'", countryCode];
    
//    NSString *queryString = @"SELECT * FROM location WHERE countryCode = '%@'";
    
    
    if (![dbManager getDataForQuery:queryString])
    {
        if (![AFNetworkReachabilityManager sharedManager].reachable)
        {
            UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:@"Warning !" message:@"The device is not connected to internet. Please connect the device to sync data" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [noNetworkAlert show];
            
            return NO;
        }else
        {
            return NO;
        }
    }
    return YES;
}

- (void)DBManager:(DBManager *)manager gotSqliteStatment:(sqlite3_stmt *)statment
{
    locationdataArr = [[NSMutableArray alloc] init];
    
    if (sqlite3_step(statment) == SQLITE_ROW)
    {
        selectedLocation.countryCode = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 0)];
        
        NSString *JSONString = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 1)];
        selectedLocation.serviceDeskNumber = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding]
                                                                             options:kNilOptions
                                                                               error:nil];
//        selectedLocation.serviceDeskNumber = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 1)];

        
        selectedLocation.countryName = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 2)];
        selectedLocation.code = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 3)];
        [locationdataArr addObject:selectedLocation];
    }
}



- (void)navTitleBtnPressed:(id)sender
{
    
    NSInteger constrainValue;
    if (!navBtnIsOn)
    {
        constrainValue = 1;
        navBtnIsOn = YES;
    }else
    {
        constrainValue = -107;
        navBtnIsOn = NO;
    }
    [UIView animateWithDuration:.5
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.profileViewTopConstraint.constant = constrainValue;
                         [self.view layoutIfNeeded];

                     } completion:^(BOOL finished) {
                         
                     }];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)messageButtonPressed:(UIButton *)sender
{
    [self.tabBarController setSelectedIndex:2];
}
- (IBAction)raiseATicketPressed:(UIButton *)sender
{
    [self.tabBarController setSelectedIndex:1];
}
- (IBAction)tipsButtonPressed:(UIButton *)sender
{
    [self.tabBarController setSelectedIndex:3];
}

- (IBAction)myTicketsBtnPressed:(id)sender
{
//    [self.tabBarController setSelectedIndex:1];

}

- (IBAction)myOrderBtnPresed:(id)sender
{
    
}

- (IBAction)initiateCallForITHelpDesk:(UIButton *)sender
{
    NSString *countryCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedLocationCode"];
    
    if (![self getDataForCountryCode:countryCode])
    {
        if ([AFNetworkReachabilityManager sharedManager].reachable)
        {
            [self tryToGetITServicePhoneNum];
        }
        
        return;
    }
    
    NSLog(@"country %@",selectedLocation.serviceDeskNumber);

    
    if (selectedLocation.serviceDeskNumber.count > 1 ) {
        [self performSegueWithIdentifier:@"serviceDeskNum_Segue" sender:self];
    }else
    {
        NSDictionary *dict = [selectedLocation.serviceDeskNumber lastObject];
        NSString *phoneNo = dict[@"Number"];
        phoneNo = [@"tel://" stringByAppendingString:phoneNo];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNo]];
        
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"dashToOrder_segue"])
    {
        RaiseATicketViewController *raiseTicket = segue.destinationViewController;
        raiseTicket.orderDiffer = @"orderBtnPressed";
        
    }if ([segue.identifier isEqualToString:@"DashToMyOrdersSegue"])
    {
        TicketsListViewController *orderList = segue.destinationViewController;
        orderList.orderItemDifferForList = @"orderList";
    }
    
    if ([segue.identifier isEqualToString:@"serviceDeskNum_Segue"])
    {
        UINavigationController *navigation = segue.destinationViewController;
        
        ServiceDeskNumListsViewController *serviceDeskVC = navigation.viewControllers[0];
        NSLog(@"country %@",selectedLocation.countryName);
        NSLog(@"country %@",selectedLocation.serviceDeskNumber);
        serviceDeskVC.country = selectedLocation.countryName;
        serviceDeskVC.serviceDeskDeteils = selectedLocation.serviceDeskNumber;
        
    }
}


@end
