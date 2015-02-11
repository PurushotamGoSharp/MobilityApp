//
//  RaiseATicketViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/4/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "RaiseATicketViewController.h"
#import "PlaceHolderTextView.h"
#import "TikcetCategoryViewController.h"
#import "TicketsListViewController.h"
#import "CategoryModel.h"
#import "Postman.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <sqlite3.h>
#import "DBManager.h"
#import "RequestModel.h"
#import "UserInfo.h"
#import "SendRequestsManager.h"

#define ORDER_PARAMETER @"{\"request\":{\"CategoryTypeCode\":\"ORDER\"}}"
#define TICKET_PARAMETER @"{\"request\":{\"CategoryTypeCode\":\"TICKET\"}}"

#define ALERT_FOR_ORDER_SAVED_IN_ONLINE @"Your Order has been successfully placed"
#define ALERT_FOR_TICKET_SAVED_IN_ONLINE @"Your Ticket has been successfully raised"

#define ALERT_FOR_ORDER_SAVED_IN_OFFLINE @"The device is not connected to internet, order will be placed automatically when connection is restored"
#define ALERT_FOR_TICKET_SAVED_IN_OFFLINE @"The device is not connected to internet, ticket will be raised automatically when connection is restored"


#define ALERT_FOR_SELECT_ITEM_VALIDATION @"Item is required.\n"
#define ALERT_FOR_SELECT_SERVICE_VALIDATION @"Service is required.\n"
#define ALERT_FOR_SELECT_DETAIL_VALIDATION @"Details is required."

#define NAV_BAR_TITLE_FOR_RAISE_TICKET @"Raise Ticket"
#define NAV_BAR_TITLE_FOR_ORDER @"Place Order"

#define PLACEHOLDE_TEXT_FOR_SELECT_ITEM @"Select an item"
#define PLACEHOLDE_TEXT_FOR_SELECT_SERVICE @"Select a service"
#define PLACEHOLDER_TEXT_FOR_DETAIL_TICKET @"Describe your request here"
#define PLACEHOLDER_TEXT_FOR_DETAIL_ORDER @"Please describe the details of what you are ordering. If this is for hardware then enter the model number.  For software enter the name of the software and the version number. If there are any questions the Mobility team will contact you so we ensure the proper Item is ordered"


@interface RaiseATicketViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, TicketCategoryDelegate,postmanDelegate, DBManagerDelegate, UIAlertViewDelegate>
{
    CGPoint initialOffsetOfSCrollView;
    UIEdgeInsets initialScollViewInset;
    UIBarButtonItem *backButton;
    Postman *postMan;
    NSArray *categoriesArr;
    DBManager *dbManager;
    CategoryModel *selectedCategory;
    
    UISlider *sliderOutlet;
    
    BOOL serviceIsSelected;
    BOOL saveButtonIsPressed;
    
    NSDateFormatter *dateFormatter;
    RequestModel *currentRequest;
    BOOL haveRasiedRequest;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet PlaceHolderTextView *textView;
@property (weak, nonatomic) IBOutlet UITableView *tableViewOutlet;
@property (weak, nonatomic) IBOutlet UILabel *selectedCategorylabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *listBarBtnOutlet;
@property (weak, nonatomic) IBOutlet UILabel *CategoryTitleOutlet;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *tickBtnoutlet;
@property (weak, nonatomic) IBOutlet UILabel *detailLbl;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailsBottomMaxConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomConst;
@property (weak, nonatomic) IBOutlet UIView *textviewContentView;

@end

@implementation RaiseATicketViewController
{
    UILabel *low;
    UILabel *medium;
    UILabel *high;
    UILabel *critical;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.CategoryTitleOutlet.font = [self customFont:16 ofName:MuseoSans_700];
    self.selectedCategorylabel.font = [self customFont:16 ofName:MuseoSans_300];
    self.detailLbl.font = [self customFont:16 ofName:MuseoSans_700];
    
    self.textView.font = [self customFont:16 ofName:MuseoSans_300];
    
    self.navigationItem.leftBarButtonItems = @[];
    
    postMan = [[Postman alloc] init];
    postMan.delegate = self;
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setImage:[UIImage imageNamed:@"back_Arrow"] forState:UIControlStateNormal];
    [back setTitle:@"Home" forState:UIControlStateNormal];
    back.titleLabel.font = [self customFont:16 ofName:MuseoSans_700];
    back.imageEdgeInsets = UIEdgeInsetsMake(0, -45, 0, 0);
    back.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
    back.frame = CGRectMake(0, 0,80, 30);
    [back setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    
    [back  addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    backButton = [[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UITableViewCell *impactCell = [self.tableViewOutlet cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
    low = (UILabel *)[impactCell viewWithTag:10];
    medium = (UILabel *)[impactCell viewWithTag:20];
    high = (UILabel *)[impactCell viewWithTag:30];
    critical = (UILabel *)[impactCell viewWithTag:40];
    
    low.font=[self customFont:14 ofName:MuseoSans_300];
    medium.font=[self customFont:14 ofName:MuseoSans_300];
    high.font=[self customFont:14 ofName:MuseoSans_300];
    critical.font=[self customFont:14 ofName:MuseoSans_300];

    if ([self.orderDiffer isEqualToString:FLOW_FOR_ORDER])
    {
        [self.listBarBtnOutlet setImage:[UIImage imageNamed:@"OrderListtBarIcon"]];
        self.title = NAV_BAR_TITLE_FOR_ORDER;
        
        self.CategoryTitleOutlet.text = @"Items";
        self.selectedCategorylabel.text = PLACEHOLDE_TEXT_FOR_SELECT_ITEM;
        self.textView.placeholder = PLACEHOLDER_TEXT_FOR_DETAIL_ORDER;
    }
    else
    {
        UIView *titleView = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, 115, 40))];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:(CGRectMake(0, 0, 115, 40))];
        
        self.textView.placeholder = PLACEHOLDER_TEXT_FOR_DETAIL_TICKET;

        titleLabel.text = NAV_BAR_TITLE_FOR_RAISE_TICKET;
        titleLabel.font = [self customFont:20 ofName:MuseoSans_700];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        [titleView addSubview:titleLabel];
        
        self.navigationItem.titleView = titleView;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([AFNetworkReachabilityManager sharedManager].reachable)
    {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"category"])
        {
            [self tryToUpdateCategories];
        }else
        {
            [self getData];
        }
    }else
    {
        [self getData];
    }
    
    if (![self.orderDiffer isEqualToString:FLOW_FOR_ORDER])
    {
        self.navigationItem.rightBarButtonItems = @[self.tickBtnoutlet];
        
    }else
    {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    initialOffsetOfSCrollView = self.scrollView.contentOffset;
    initialScollViewInset = self.scrollView.contentInset;

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(successfulSync)
                                                 name:REQUEST_SYNC_NOTIFICATION_KEY
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(failureSync)
                                                 name:REQUEST_SYNC_FAILURE_NOTIFICATION_KEY
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self hideKeyboard:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:REQUEST_SYNC_NOTIFICATION_KEY
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:REQUEST_SYNC_FAILURE_NOTIFICATION_KEY
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)successfulSync
{
    if (haveRasiedRequest)
    {
        NSString *alertMessage;
        
        if ([self.orderDiffer isEqualToString:FLOW_FOR_ORDER])
        {
            alertMessage = ALERT_FOR_ORDER_SAVED_IN_ONLINE;
        }
        else
        {
            alertMessage = ALERT_FOR_TICKET_SAVED_IN_ONLINE;
        }
        
        UIAlertView *saveAlestView = [[UIAlertView alloc] initWithTitle:@"Confirmation"
                                                                message:alertMessage
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
        
        saveAlestView.delegate= self;
        [saveAlestView show];
        haveRasiedRequest = NO;
    }
}

- (void)failureSync
{
    if (haveRasiedRequest)
    {
        UIAlertView *errorAlestView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                 message:@"Error occurred while contacting to server"
                                                                delegate:self
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
        [errorAlestView show];
        haveRasiedRequest = NO;
    }
    


}

- (void)tryToUpdateCategories
{
    [self postWithParameter:ORDER_PARAMETER];
    [self postWithParameter:TICKET_PARAMETER];
}

- (void)postWithParameter:(NSString *)parameterString
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *URLString = SEARCH_CATEGORY_API;
    
    [postMan post:URLString withParameters:parameterString];
}

- (void)resetForms
{
    self.selectedCategorylabel.textColor = [UIColor lightGrayColor];
    sliderOutlet.value = 0;
    [sliderOutlet setThumbImage:[self imageForSLiderThumb:0] forState:(UIControlStateNormal)];
    
    UITableViewCell *impactCell = [self.tableViewOutlet cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UILabel  *lowest = (UILabel *)[impactCell viewWithTag:10];
    [self setBlackColorFor:lowest];
    
    self.textView.text = @"";
    if ([self.orderDiffer isEqualToString:FLOW_FOR_ORDER])
    {
        self.selectedCategorylabel.text = PLACEHOLDE_TEXT_FOR_SELECT_ITEM;
        
    }else
    {
        self.selectedCategorylabel.text = PLACEHOLDE_TEXT_FOR_SELECT_SERVICE;
    }
    
    selectedCategory = nil;
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
    [self hideKeyboard:nil];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
//    if (self.scrollView.contentOffset.y >= 100)
//    {
//        self.detailsBottomMaxConst.constant = 70;
//        [self.view layoutIfNeeded];
//        
//        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
//        
//    }
}



- (void)backBtnAction
{
    [self resetForms];
    [self.navigationController popViewControllerAnimated:YES];

    
//    if ([self.orderDiffer isEqualToString:FLOW_FOR_ORDER])
//    {
//    }else
//    {
//        [self.tabBarController setSelectedIndex:0];
//    }
}

- (void)listBtnAction
{
    //    TicketsListViewController *ticketList = [[TicketsListViewController alloc] init];
    //    [self.navigationController pushViewController:ticketList animated:YES];
}

- (IBAction)saveBtnPressed:(id)sender
{
    if (![self validateEntriesMade])
    {
        return;
    }
    
    saveButtonIsPressed = YES;
    
    currentRequest = [self requestForCurrentValues];
    [self saveEntriesLocallyForRequest:currentRequest];
    
    if ([AFNetworkReachabilityManager sharedManager].isReachable)
    {
        haveRasiedRequest = YES;
        [[SendRequestsManager sharedManager] authenticateServer];
        [[SendRequestsManager sharedManager] sendRequestSyncronouslyForRequest:currentRequest blockUI:YES];
        
//        NSString *alertMessage;
//        
//        if ([self.orderDiffer isEqualToString:FLOW_FOR_ORDER])
//        {
//            alertMessage = ALERT_FOR_ORDER_SAVED_IN_ONLINE;
//        }
//        else
//        {
//            alertMessage = ALERT_FOR_TICKET_SAVED_IN_ONLINE;
//        }
//        
//        UIAlertView *saveAlestView = [[UIAlertView alloc] initWithTitle:@"Confirmation"
//                                                                message:alertMessage
//                                                               delegate:self
//                                                      cancelButtonTitle:@"OK"
//                                                      otherButtonTitles:nil];
//        
//        saveAlestView.delegate= self;
//        [saveAlestView show];

    }else
    {
        NSString *alertMessage;
        
        if ([self.orderDiffer isEqualToString:FLOW_FOR_ORDER])
        {
            alertMessage = ALERT_FOR_ORDER_SAVED_IN_OFFLINE;
        }
        else
        {
            alertMessage = ALERT_FOR_TICKET_SAVED_IN_OFFLINE;
        }
        
        UIAlertView *saveAlestView = [[UIAlertView alloc] initWithTitle:@"Confirmation"
                                                                message:alertMessage
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
        
        saveAlestView.delegate= self;
        [saveAlestView show];

    }
    
    saveButtonIsPressed = NO;
}

- (BOOL)validateEntriesMade
{
    BOOL valid = YES;
    
    NSMutableArray *alertMessages = [[NSMutableArray alloc] init];
    
    if (selectedCategory == nil)
    {
        if ([self.orderDiffer isEqualToString:FLOW_FOR_ORDER])
        {
            [alertMessages addObject:ALERT_FOR_SELECT_ITEM_VALIDATION];
        }else
        {
            [alertMessages addObject:ALERT_FOR_SELECT_SERVICE_VALIDATION];
        }
        
        valid = NO;
    }
    
    if (self.textView.text.length == 0)
    {
        [alertMessages addObject:ALERT_FOR_SELECT_DETAIL_VALIDATION];
        valid = NO;
    }
    
    if (!valid)
    {
        NSString *alertMessage = [alertMessages componentsJoinedByString:@" "];
        
        UIAlertView *invalidAlert = [[UIAlertView alloc] initWithTitle:WARNING_TEXT
                                                               message:alertMessage
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
        [invalidAlert show];
        
    }else if (self.textView.text.length == 0)
    {
        
    }

    
    return valid;
}

- (RequestModel *)requestForCurrentValues
{
    RequestModel *request = [[RequestModel alloc] init];
    request.requestType = [self.orderDiffer isEqualToString:FLOW_FOR_ORDER] ? @"ORDER" : @"TICKET";
    request.requestImpact = roundf(sliderOutlet.value);
    request.requestServiceCode = selectedCategory.categoryCode;
    request.requestServiceName = selectedCategory.categoryName;
    
    NSRange rangeOfDetails;
    rangeOfDetails.length = self.textView.text.length;
    rangeOfDetails.location = 0;
    
    NSMutableString *mutableDetails = [self.textView.text mutableCopy];
    [mutableDetails replaceOccurrencesOfString:@"'"
                                    withString:@"''"
                                       options:NSCaseInsensitiveSearch
                                         range:rangeOfDetails];
    
    request.requestDetails = mutableDetails;
    request.requestSyncFlag = 0;
    
    request.requestDate = [NSDate date];
    
    return request;
}

- (void)saveEntriesLocallyForRequest:(RequestModel *)request
{
    if (request == nil)
    {
        NSLog(@"failed to save request");
        return;
    }
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate = self;
    }
    
    NSString *createQuery;
    NSString *insertSQL;
    
//    if (!dateFormatter)
//    {
//        dateFormatter = [[NSDateFormatter alloc] init];
//    }
//    
//    [dateFormatter setDateFormat:@"hh:mm a, dd MMM, yyyy"];
//    NSString *dateInString = [dateFormatter stringFromDate:request.requestDate];
    
    if ([request.requestType isEqualToString:@"TICKET"])
    {
        createQuery = @"CREATE TABLE IF NOT EXISTS raisedTickets (loaclID INTEGER PRIMARY KEY, impact INTEGER, serviceCode text, serviceName text, details text, date text, syncFlag INTEGER, incidentNumber text)";
        
        insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO  raisedTickets (impact, serviceCode, serviceName, details, syncFlag) values (%li, '%@', '%@', '%@', %li)",(long)request.requestImpact, request.requestServiceCode, request.requestServiceName, request.requestDetails, (long)request.requestSyncFlag];
    }else
    {
        createQuery = @"CREATE TABLE IF NOT EXISTS raisedOrders (loaclID INTEGER PRIMARY KEY, impact INTEGER, serviceCode text, serviceName text, details text, date text,syncFlag INTEGER, incidentNumber text)";
        
        insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO  raisedOrders (impact, serviceCode, serviceName, details, syncFlag) values (%li, '%@', '%@', '%@', %li)",(long)request.requestImpact, request.requestServiceCode,request.requestServiceName,  request.requestDetails, (long)request.requestSyncFlag];
    }
    
    [dbManager createTableForQuery:createQuery];
    [dbManager saveDataToDBForQuery:insertSQL];
    
    return;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    //    [self.tabBarController setSelectedIndex:0];
    //    if ([self.orderDiffer isEqualToString:FLOW_FOR_ORDER])
    //    {
    //        [self performSegueWithIdentifier:@"SplashToLoginVC_Segue" sender:nil];
    //
    //
    //    }else
    //    {
    //        [self performSegueWithIdentifier:@"DashToMyTicketsASegue" sender:nil];
    //
    //
    //    }
    
    [self resetForms];

    [self performSegueWithIdentifier:@"myTicketList_segue" sender:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)hideKeyboard:(UIControl *)sender
{
    [self.view endEditing:YES];
//
//    if (self.scrollView.contentOffset.y >= 100)
//    {
//        self.detailsBottomMaxConst.constant = 70;
//        [self.view layoutIfNeeded];
//
//        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
//
//    }
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:.3
                     animations:^{
                         
                         self.scrollViewBottomConst.constant = kbSize.height - 56;
                         [self.view layoutIfNeeded];

                     }
                     completion:^(BOOL finished) {
                         
                         [self.scrollView scrollRectToVisible:self.textviewContentView.frame animated:YES];

                     }];
    
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self.scrollViewBottomConst.constant = 0;
    [self.view layoutIfNeeded];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
//    if (self.scrollView.contentOffset.y <= 0)
//    {
//        initialOffsetOfSCrollView = self.scrollView.contentOffset;
//        initialScollViewInset = self.scrollView.contentInset;
//    }
//    
//    //    [self.scrollView setContentInset:(UIEdgeInsetsMake(100, 0, 0, 0))];
////    [self.scrollView setContentOffset:(CGPointMake(0, 150)) animated:YES];
////    self.detailsBottomMaxConst.constant = 220;
////    [self.view layoutIfNeeded];
//    
//    
//    
//    UIInterfaceOrientation orientaition = [[UIApplication sharedApplication] statusBarOrientation];
//    if (orientaition == UIInterfaceOrientationPortrait || orientaition == UIDeviceOrientationPortraitUpsideDown)
//    {
//        self.self.detailsBottomMaxConst.constant = 220;
//        [self.scrollView setContentOffset:(CGPointMake(0, 150)) animated:YES];
//        [self.view layoutIfNeeded];
//
//        
//    }else if (orientaition == UIDeviceOrientationLandscapeRight || orientaition == UIDeviceOrientationLandscapeLeft)
//    {
//       
//        self.self.detailsBottomMaxConst.constant = 280;
//        [self.scrollView setContentOffset:(CGPointMake(0, 220)) animated:YES];
//        [self.view layoutIfNeeded];
//    }
//    


}

- (IBAction)imapctValueChanged:(UISlider *)sender
{
    sender.value = roundf(sender.value);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if ( indexPath.row == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SliderCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        sliderOutlet = (UISlider *)[cell viewWithTag:300];
        [sliderOutlet setThumbImage:[self imageForSLiderThumb:roundf(sliderOutlet.value)] forState:(UIControlStateNormal)];
        [sliderOutlet setThumbImage:[UIImage imageNamed:@"grayCircle"] forState:(UIControlStateHighlighted)];
        [sliderOutlet addTarget:self action:@selector(sliderValueChanged:) forControlEvents:(UIControlEventValueChanged)];
        
        low = (UILabel *)[cell viewWithTag:10];
        medium = (UILabel *)[cell viewWithTag:20];
        high = (UILabel *)[cell viewWithTag:30];
        critical = (UILabel *)[cell viewWithTag:40];
        
        low.font=[self customFont:14 ofName:MuseoSans_300];
        medium.font=[self customFont:14 ofName:MuseoSans_300];
        high.font=[self customFont:14 ofName:MuseoSans_300];
        critical.font=[self customFont:14 ofName:MuseoSans_300];
        
        return cell;
    }else
    {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    }
    
    if (![self.orderDiffer isEqualToString:FLOW_FOR_ORDER] && (indexPath.row == 1))
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    UILabel *header = (UILabel *)[cell viewWithTag:100];
    UILabel *lable = (UILabel *)[cell viewWithTag:101];
    
    header.font=[self customFont:16 ofName:MuseoSans_700];
    lable.font=[self customFont:16 ofName:MuseoSans_300];
    
    UIView *colourForline = (UIView *)[cell viewWithTag:102];
    UIView *colourForRect = (UIView *)[cell viewWithTag:103];
    
    colourForRect.layer.cornerRadius = 10;
    
    if (indexPath.row == 0)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        header.text = @"Requester";
        lable.text = [UserInfo sharedUserInfo].fullName?:@"Test User";
    }else
    {
        header.text = @"Impact";
        lable.text = @"Low";
        colourForline.backgroundColor = [UIColor colorWithRed:.37 green:.72 blue:.38 alpha:1];
        colourForRect.backgroundColor = [UIColor colorWithRed:.37 green:.72 blue:.38 alpha:1];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1 && [self.orderDiffer isEqualToString:FLOW_FOR_ORDER])
    {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        return;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1 )
    {
        return 200;
    }
    return 44;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SelectAcategorySegue"])
    {
        UINavigationController *navController = segue.destinationViewController;
        TikcetCategoryViewController *ticketCategoryVC = navController.viewControllers[0];
        ticketCategoryVC.delegate = self;
        
        if ([self.orderDiffer isEqualToString:FLOW_FOR_ORDER])
        {
            ticketCategoryVC.orderItemDiffer = @"orderList";
        }
        
        ticketCategoryVC.categoryArray = categoriesArr;
        ticketCategoryVC.selectedCategory = selectedCategory;
    }
    
    if ([segue.identifier isEqualToString:@"myTicketList_segue"])
    {
        TicketsListViewController *ticketList = segue.destinationViewController;
        if ([self.orderDiffer isEqualToString:FLOW_FOR_ORDER])
        {
            ticketList.orderItemDifferForList = @"orderList";
        }
        ticketList.fromRasieRequsetVC = YES;
    }
}

- (void)selectedCategory:(CategoryModel *)category
{
    selectedCategory = category;
    self.selectedCategorylabel.text = category.categoryName;
    self.selectedCategorylabel.textColor = [UIColor blackColor];
}

- (void)sliderValueChanged:(UISlider *)slider
{

   
    slider.value = roundf(slider.value);
    
    [slider setThumbImage:[self imageForSLiderThumb:roundf(slider.value)] forState:(UIControlStateNormal)];
    
    if (slider.value == 3 )
    {
        [slider setTintColor:([UIColor redColor])];
        [slider setMinimumTrackTintColor:([UIColor redColor])];
        
        [self setBlackColorFor:critical];
        
    }else if (slider.value == 2)
    {
        [slider setTintColor:([UIColor orangeColor])];
        [slider setMinimumTrackTintColor:([UIColor orangeColor])];
        
        [self setBlackColorFor:high];
        
    }else if (slider.value == 1)
    {
        [slider setTintColor:([UIColor yellowColor])];
        [slider setMinimumTrackTintColor:([UIColor yellowColor])];
        
        [self setBlackColorFor:medium];
        
    } if (slider.value ==0)
    {
        [slider setTintColor:([UIColor greenColor])];
        [slider setMinimumTrackTintColor:([UIColor greenColor])];
        
        [self setBlackColorFor:low];
    }
}

- (void)setBlackColorFor:(UILabel *)blackLabel
{
    
    low.textColor = [UIColor lightGrayColor];
    medium.textColor = [UIColor lightGrayColor];
    high.textColor = [UIColor lightGrayColor];
    critical.textColor = [UIColor lightGrayColor];
    
    blackLabel.textColor = [UIColor blackColor];
}

- (UIImage *)imageForSLiderThumb:(NSInteger)value
{
    switch (value)
    {
        case 0:
            return [UIImage imageNamed:@"greenCirlce"];
            break;
            
        case 1:
            return [UIImage imageNamed:@"YellowCircle"];
            break;
            
        case 2:
            return [UIImage imageNamed:@"OrangeCircle"];
            break;
            
        case 3:
            return [UIImage imageNamed:@"RedCircle"];
            break;
            
        default:
            break;
    }
    return nil;
}

#pragma mark
#pragma mark: postmanDelegate
- (void)postman:(Postman *)postman gotSuccess:(NSData *)response forURL:(NSString *)urlString
{
    NSArray *responseArray = [self parseResponseData:response];
    CategoryModel *category = [responseArray lastObject];
    
    if (category)
    {
        if ([category.categoryType isEqualToString:@"Order"])
        {
            [self saveResponse:response forParameter:ORDER_PARAMETER];
            
            if ([self.orderDiffer isEqualToString:FLOW_FOR_ORDER])
            {
                categoriesArr = responseArray;
            }
        }else
        {
            [self saveResponse:response forParameter:TICKET_PARAMETER];
            
            if (![self.orderDiffer isEqualToString:FLOW_FOR_ORDER])
            {
                categoriesArr = responseArray;
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"category"];
    }
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (NSArray *)parseResponseData:(NSData *)response
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    NSArray *arr = json[@"aaData"][@"GenericSearchViewModels"];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    NSLog(@"%@",arr);
    for (NSDictionary *aDict in arr)
    {
        if ([aDict[@"Status"] boolValue])
        {
            CategoryModel *category = [[CategoryModel alloc] init];
            category.categoryName = aDict[@"Name"];
            category.categoryCode = aDict[@"Code"];
            category.categoryType = aDict[@"CategoryType"];
            [tempArray addObject:category];
        }
    }
    
    return tempArray;
}

- (void)postman:(Postman *)postman gotFailure:(NSError *)error forURL:(NSString *)urlString
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)saveResponse:(NSData *)response forParameter:(NSString *)parameter
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate = self;
    }
    
    NSString *createQuery = @"create table if not exists categoryTable (API text PRIMARY KEY, data text)";
    [dbManager createTableForQuery:createQuery];
    
    NSMutableString *stringFromData = [[NSMutableString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSRange rangeofString;
    rangeofString.location = 0;
    rangeofString.length = stringFromData.length;
    [stringFromData replaceOccurrencesOfString:@"'" withString:@"''" options:(NSCaseInsensitiveSearch) range:rangeofString];
    
    NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO  categoryTable (API,data) values ('%@', '%@')", parameter,stringFromData];
    
    [dbManager saveDataToDBForQuery:insertSQL];
}

- (void)getData
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate=self;
    }
    
    NSString *queryString;
    
    if ([self.orderDiffer isEqualToString:FLOW_FOR_ORDER])
    {
        queryString = [NSString stringWithFormat:@"SELECT * FROM categoryTable WHERE API = '%@'", ORDER_PARAMETER];
    }else
    {
        queryString = [NSString stringWithFormat:@"SELECT * FROM categoryTable WHERE API = '%@'", TICKET_PARAMETER];
    }
    
    if (![dbManager getDataForQuery:queryString])
    {
        if (![AFNetworkReachabilityManager sharedManager].reachable)
        {
            UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:WARNING_TEXT message:INTERNET_IS_REQUIRED_TO_SYNC_DATA delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [noNetworkAlert show];
        }
        
        [self tryToUpdateCategories];
    }
}

- (void)DBManager:(DBManager *)manager gotSqliteStatment:(sqlite3_stmt *)statment
{
    if (sqlite3_step(statment) == SQLITE_ROW)
    {
        NSString *string = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 1)];
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        
        categoriesArr = [self parseResponseData:data];
    }
}

- (void)DBMAnager:(DBManager *)manager savedSuccessfullyWithID:(NSInteger)lastID
{
    if (saveButtonIsPressed)
    {
        currentRequest.requestLocalID = lastID;
    }
    
    NSLog(@"Last ID %li",(long)lastID);
}

@end
