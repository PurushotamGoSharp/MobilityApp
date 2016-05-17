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
#import "SliderTableViewCell.h"
#import "RoomManager.h"

#define ORDER_PARAMETER @"{\"request\":{\"CategoryTypeCode\":\"ORDER\"}}"
#define TICKET_PARAMETER @"{\"request\":{\"CategoryTypeCode\":\"TICKET\"}}"

#define ALERT_FOR_ORDER_SAVED_IN_ONLINE @"Your Order has been successfully placed"


//#define ALERT_FOR_TICKET_SAVED_IN_ONLINE @"Your Ticket has been successfully raised"

#define ALERT_FOR_ORDER_SAVED_IN_OFFLINE @"The device is not connected to internet, order will be placed automatically when connection is restored"




//#define ALERT_FOR_TICKET_SAVED_IN_OFFLINE @"The device is not connected to internet, ticket will be raised automatically when connection is restored"


#define ALERT_FOR_SELECT_ITEM_VALIDATION @"Item is required.\n"
#define ALERT_FOR_SELECT_SERVICE_VALIDATION @"Service is required.\n"
#define ALERT_FOR_SELECT_DETAIL_VALIDATION @"Details is required."

#define NAV_BAR_TITLE_FOR_RAISE_TICKET @"IT SOS"
#define NAV_BAR_TITLE_FOR_ORDER @"Place Order"

#define PLACEHOLDE_TEXT_FOR_SELECT_ITEM @"Select an item"
#define PLACEHOLDE_TEXT_FOR_SELECT_SERVICE STRING_FOR_LANGUAGE(@"Select.Service")
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
    
    RoomManager *roomManager;
    
    UITextView *activeField;

    
    
    // localization
    NSString *Labservicerequired;
    NSString *Labdetailsisrequired;
    NSString *LabselectService;
    NSString *LabRequester;
    NSString *LabPersonalImpact;
    NSString *LabLow;
    NSString *LabMedium;
    NSString *LabCriticle;
    NSString *LabHigh;
    NSString *Services;
    NSString *LabselectServices;
    NSString *home;
    NSString *ok;
    NSString *Details;
    NSString *requestDescribe;
    NSString *Warrning;



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
@property (weak, nonatomic) IBOutlet UITextView *ImportantNotetextView;

@end

@implementation RaiseATicketViewController
{
    UILabel *low;
    UILabel *medium;
    UILabel *high;
    UILabel *critical;
    UILabel *titleLabel;
    UIButton *back;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    self.navigationItem.leftBarButtonItems = @[];
    postMan = [[Postman alloc] init];
    postMan.delegate = self;
    
    back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setImage:[UIImage imageNamed:@"back_Arrow"] forState:UIControlStateNormal];
    [back setTitle:@"Home" forState:UIControlStateNormal];

    back.titleLabel.font = [self customFont:16 ofName:MuseoSans_700];
//    back.imageEdgeInsets = UIEdgeInsetsMake(0, -45, 0, 0);
//    back.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
//    back.frame = CGRectMake(0, 0,80, 30);
    [back setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    
    [back  addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    backButton = [[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = backButton;

    UIView *titleView = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, 75, 40))];
    titleLabel = [[UILabel alloc] initWithFrame:(CGRectMake(0, 10, 75, 40))];
        
    titleLabel.font = [self customFont:20 ofName:MuseoSans_700];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    [titleView addSubview:titleLabel];
    
    self.navigationItem.titleView = titleView;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localize) name:MCLocalizationLanguageDidChangeNotification object:nil];
    [self localize];
    
//   self.textView.placeholder = PLACEHOLDER_TEXT_FOR_DETAIL_TICKET;
//
//    self.textView.text= requestDescribe ;

}

//Important Notes
//
//Please provide as much information as possible about your issue(s) in the Details section above.  Other than a description, ensure you provide:
//· Indicate how you want to be contacted in the Details (Mobile Phone, Office Phone, Lync, etc)
//· Your preferred contact phone number
//· The date/time you wish to be contacted



-(void)localize
{
//    self.ImportantNotetextView.text = STRING_FOR_LANGUAGE(@"Lab_Notes_Details");
    
    
    
    NSString * test = STRING_FOR_LANGUAGE(@"Important.Notes");
    NSString * testtwo = STRING_FOR_LANGUAGE(@"Issues.Details");
    NSString * testthree = STRING_FOR_LANGUAGE(@"Contact.Details");
    NSString * testfour = STRING_FOR_LANGUAGE(@"Contact.Number");
    NSString * testfive = STRING_FOR_LANGUAGE(@"Date.Contact");
   
    self.ImportantNotetextView.text=[NSString stringWithFormat:@"%@ \n\n %@\n%@\n. %@\n. %@",test,testtwo,testthree,testfour,testfive];
    self.ImportantNotetextView.textColor=[self colorWithHexString:@"FFA0A0"];
    [[self ImportantNotetextView] setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
    
    
    titleLabel.text = STRING_FOR_LANGUAGE(@"IT.SOS");
    [titleLabel sizeToFit];
    Labservicerequired = STRING_FOR_LANGUAGE(@"Service.Required");
    Labdetailsisrequired = STRING_FOR_LANGUAGE(@"Details.Required");
    [back setTitle:STRING_FOR_LANGUAGE(@"Home") forState:UIControlStateNormal];
    LabRequester=STRING_FOR_LANGUAGE(@"Requester");
    LabPersonalImpact=STRING_FOR_LANGUAGE(@"Personal.Impact");
    LabLow=STRING_FOR_LANGUAGE(@"Low");
    LabMedium=STRING_FOR_LANGUAGE(@"Medium");
    LabCriticle=STRING_FOR_LANGUAGE(@"Critical");
    LabHigh=STRING_FOR_LANGUAGE(@"High");
    Services=STRING_FOR_LANGUAGE(@"Service");
    Details = STRING_FOR_LANGUAGE(@"Details");
    LabselectServices=STRING_FOR_LANGUAGE(@"Select.Service");
    home=STRING_FOR_LANGUAGE(@"Home");
    ok=STRING_FOR_LANGUAGE(@"Ok");
    Warrning = STRING_FOR_LANGUAGE(@"Warning");
    [back sizeToFit];
}
// hex colour

-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
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
    
    [self registerForKeyboardNotifications];
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
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];}


- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //    if ([activeField isEqual:enterUserNameTextField])
    //    {
    //        kbSize.height = self.tableView.frame.size.height - 80;
    //    }
    //
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.tableViewOutlet.contentInset = contentInsets;
    self.tableViewOutlet.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = [self.tableViewOutlet rectForRowAtIndexPath:([NSIndexPath indexPathForRow:0 inSection:2])];
    [self.tableViewOutlet scrollRectToVisible:aRect animated:YES];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.tableViewOutlet.contentInset = contentInsets;
    self.tableViewOutlet.scrollIndicatorInsets = contentInsets;
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
        
        
        UIAlertView *saveAlestView = [[UIAlertView alloc] initWithTitle:STRING_FOR_LANGUAGE(@" Confirmation")
                                                                message:alertMessage
                                                               delegate:self
                                                      cancelButtonTitle:OK_FOR_ALERT
                                                      otherButtonTitles:nil];
        
        saveAlestView.delegate = self;
        [saveAlestView show];
        haveRasiedRequest = NO;
    }
}

- (void)failureSync
{
    if (haveRasiedRequest)
    {
        UIAlertView *errorAlestView = [[UIAlertView alloc] initWithTitle:ERROR_FOR_ALERT
                                                                 message:STRING_FOR_LANGUAGE(@"Server.Error")
                                                                delegate:self
                                                       cancelButtonTitle:OK_FOR_ALERT
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
//    [sliderOutlet setThumbImage:[self imageForSLiderThumb:0] forState:(UIControlStateNormal)];
    
    SliderTableViewCell *impactCell = (SliderTableViewCell *) [self.tableViewOutlet cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [impactCell updateSliderForValue:0];
    UILabel  *lowest = (UILabel *)[impactCell viewWithTag:10];
    [impactCell setBlackColorFor:lowest];
    
    self.textView.text = @"";
    
    self.selectedCategorylabel.text = PLACEHOLDE_TEXT_FOR_SELECT_SERVICE;
    
    selectedCategory = nil;
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
    [self hideKeyboard:nil];
}

- (void)backBtnAction
{
    [self resetForms];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)listBtnAction
{
    //    TicketsListViewController *ticketList = [[TicketsListViewController alloc] init];
    //    [self.navigationController pushViewController:ticketList animated:YES];
}

- (IBAction)saveBtnPressed:(id)sender
{
    [self hideKeyboard:nil];
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
        
        UIAlertView *saveAlestView = [[UIAlertView alloc] initWithTitle:STRING_FOR_LANGUAGE(@" Confirmation")
                                                                message:alertMessage
                                                               delegate:self
                                                      cancelButtonTitle:OK_FOR_ALERT
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
            [alertMessages addObject:Labservicerequired];
        }
        
        valid = NO;
    }
    
    if (self.textView.text.length == 0)
    {
        [alertMessages addObject:Labdetailsisrequired];
        valid = NO;
    }
    
    if (!valid)
    {
        NSString *alertMessage = [alertMessages componentsJoinedByString:@" "];
        
        UIAlertView *invalidAlert = [[UIAlertView alloc] initWithTitle:Warrning
                                                               message:alertMessage
                                                              delegate:nil
                                                     cancelButtonTitle:ok
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
}

//- (void)keyboardWasShown:(NSNotification*)aNotification
//{
//    NSDictionary* info = [aNotification userInfo];
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    
//    [UIView animateWithDuration:.3
//                     animations:^{
//                         
//                         self.scrollViewBottomConst.constant = kbSize.height - 56;
//                         [self.view layoutIfNeeded];
//
//                     }
//                     completion:^(BOOL finished) {
//                         
//                         NSLog(@"======== %@",NSStringFromCGSize(self.textView.frame.size));
//
//
//                     }];
//    
//}


- (void)textViewDidBeginEditing:(UITextView *)textView
{
    activeField = textView;
    activeField.textColor=[UIColor blackColor];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    activeField = textView;
    return YES;
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    activeField = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 1)
        {
            SliderTableViewCell *sliderCell = (SliderTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"SliderCell" forIndexPath:indexPath];
            sliderCell.selectionStyle = UITableViewCellSelectionStyleNone;
            sliderCell.imapactLabel.text=LabPersonalImpact;
            sliderCell.lowLabel.text= LabLow;
            sliderCell.highLabel.text=LabHigh;
            sliderCell.mediumLabel.text=LabMedium;
            sliderCell.criticalLabel.text=LabCriticle;
            [sliderCell updateSliderForValue:roundf(sliderCell.impactSlider.value)];
            sliderOutlet = sliderCell.impactSlider;
            return sliderCell;
        }else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            UILabel *header = (UILabel *)[cell viewWithTag:100];
            UILabel *lable = (UILabel *)[cell viewWithTag:101];
            header.font=[self customFont:16 ofName:MuseoSans_700];
            lable.font=[self customFont:16 ofName:MuseoSans_300];
            header.text = LabRequester;
            lable.text = [UserInfo sharedUserInfo].fullName;

            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }else if (indexPath.section == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SelectServiceCell" forIndexPath:indexPath];
        UILabel *selectedLabel = (UILabel *)[cell viewWithTag:100];
        selectedLabel.text= LabselectServices;
        selectedLabel.font = [self customFont:16 ofName:MuseoSans_300];
        self.selectedCategorylabel = selectedLabel;
    }else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"DetailsCell" forIndexPath:indexPath];
        
        self.textView = (PlaceHolderTextView *)[cell viewWithTag:100];
        
        self.textView.font = [self customFont:16 ofName:MuseoSans_300];
        
        self.textView.textColor=[self colorWithHexString:@"AAAAAA"];
        
        self.textView.placeholder = STRING_FOR_LANGUAGE(@"Describe.Request");
        self.textView.delegate = self;
       
    }
    return cell;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if (indexPath.row == 1 && [self.orderDiffer isEqualToString:FLOW_FOR_ORDER])
    {
        
        return;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 1 )
        {
            return 74;
        }
    }
    
    if (indexPath.section == 2)
    {
        return 150;
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 0;
    }
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView =  [[UIView alloc] initWithFrame:(CGRectMake(0, 0, 150, 30))];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:(CGRectMake(18, 5, 150, 30))];
    headerView.backgroundColor = self.view.backgroundColor;
    
    headerLabel.font = [self customFont:16 ofName:MuseoSans_700];
;
    
    if (section == 1)
    {
        headerLabel.text = Services;
        
    }else if (section == 2)
    {
        headerLabel.text = Details;
    
    }
    
    [headerView addSubview:headerLabel];
    
    return headerView;
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
    }else if ([segue.identifier isEqualToString:@"myTicketList_segue"])
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
    
    NSSortDescriptor *srtDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"categoryName" ascending:YES];
    [tempArray sortUsingDescriptors:@[srtDescriptor]];
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
    
//    [dbManager dropTable:@"categoryTable"];
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
            UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:WARNING_TEXT message:INTERNET_IS_REQUIRED_TO_SYNC_DATA delegate:nil cancelButtonTitle:OK_FOR_ALERT otherButtonTitles: nil];
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
