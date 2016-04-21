//
//  RoomCheckerViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 3/26/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "RoomFinderViewController.h"
#import "RoomManager.h"
#import "CLWeeklyCalendarViewSourceCode/CLWeeklyCalendarView.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "RoomModel.h"
#import "AppDelegate.h"
#import "InviteAttendeesViewController.h"
#import "PasswordManager.h"
#import "FreeSlotsViewController.h"
#import "NSDate+CL.h"

#define HEIGHT_OF_CL_CALENDAR 79
#define MIN_TIME_SLOT_FOR_SEARCH 15*60

//#define ALERT_MSG_SET_OFFICE_LOCATION @"Please go to Settings and choose Office Location"
//#define ALERT_MSG_SELECT_FUTURE_TIME @"Please select a future Time Slot"
//#define ALERT_MSG_TRY_LATER @"Error occured. Please try again after some time"
//#define ALERT_MSG_MINIMUM_TIME_SLOT @"Please select a Time Slot of minimum 15 minutes"
//#define ALERT_MSG_AUTHORIZED_BOOKING @"If you are not authorized to book this Private Room your Meeting Request will be declined.  Do you wish to continue?"




@interface RoomFinderViewController () <UITableViewDataSource, UITableViewDelegate, RoomManagerDelegate, CLWeeklyCalendarViewDelegate, UIAlertViewDelegate, PasswordManagerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *startTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *endTimeButton;
@property (weak, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endDatePicker;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *availableRoomsView;
@property (weak, nonatomic) IBOutlet UIView *containerForCalendar;
@property (weak, nonatomic) IBOutlet UILabel *selectedDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeHolderLabel;
@property (weak, nonatomic) IBOutlet UIButton *serachRoomsButton;
@property (weak, nonatomic) IBOutlet UIImageView *bannerImageView;

@property (nonatomic, strong) CLWeeklyCalendarView *calendarView;
@property (weak, nonatomic) IBOutlet UILabel *availabelmeetingRoomLab;

@end

@implementation RoomFinderViewController
{
    NSDateFormatter *dateFormatter, *localeDateFormatter;
    RoomManager *roomManager;
    
    NSMutableArray *roomsAvailable;
    NSArray *emailIDsOfRoomsToCheck, *roomsToCheckModelArray;
    NSDate *startDate, *endDate;
    
    NSString *selectedLocationEmailID;
    UIBarButtonItem *backButton;
    
    PasswordManager *passwordManager;
    
    NSString *currentlyExcutingMethod;
    
    NSInteger selectedindex;
    
    UIAlertView *officeLocationAlert;
    UIAlertView *tryAgainAlert;
    UIButton *back;
    NSString *selectedLanguageCode;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    dateFormatter = [[NSDateFormatter alloc] initWithSafeLocale];
    dateFormatter.dateFormat = @"hh:mm a";
    localeDateFormatter = [[NSDateFormatter alloc] init];
    
    roomManager = [[RoomManager alloc] init];
    [roomManager startRecognize];
//    roomsToCheck = @[@"boardroom@vmex.com", @"trainingroom@vmex.com", @"discussionroom@vmex.com", @"room1@vmex.com"];
    
    self.containerForCalendar.layer.masksToBounds = YES;
    self.serachRoomsButton.layer.cornerRadius = 5;
    
     back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setImage:[UIImage imageNamed:@"back_Arrow"] forState:UIControlStateNormal];
    back.titleLabel.font = [self customFont:16 ofName:MuseoSans_700];
//    back.imageEdgeInsets = UIEdgeInsetsMake(0, -45, 0, 0);
//    back.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
//    back.frame = CGRectMake(0, 0,80, 30);
    [back setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    
    [back  addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    backButton = [[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = backButton;
    
    passwordManager = [[PasswordManager alloc] init];
    passwordManager.delegate = self;
    [self getAllRoomsOfCurrentLocation];
    
    [self setbuttonForSwitchMode];
    self.serachRoomsButton.hidden = NO;
    
    [self.endTimeButton setTitle:STRING_FOR_LANGUAGE(@"End.Time") forState:(UIControlStateNormal)];
    endDate = nil;
    [self.startTimeButton setTitle:STRING_FOR_LANGUAGE(@"Start.Time") forState:(UIControlStateNormal)];
    startDate = nil;
}

- (void)backBtnAction
{
    [self.navigationController popViewControllerAnimated:YES];
    //    self.writeReviewTxtView.text = @"";
    //    [self hideWriteReviewTextView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    roomManager.delegate = self;
    [self setTheme];

//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localize) name:MCLocalizationLanguageDidChangeNotification object:nil];
    [self localize];
    selectedLanguageCode = [MCLocalization sharedInstance].language;
}
-(void)localize
{
    self.title = STRING_FOR_LANGUAGE(@"Book.Room");
    [back setTitle:STRING_FOR_LANGUAGE(@"Home") forState:UIControlStateNormal];
    [back sizeToFit];
//    [self.endTimeButton setTitle:STRING_FOR_LANGUAGE(@"End.Time") forState:(UIControlStateNormal)];
//    endDate = nil;
//    [self.startTimeButton setTitle:STRING_FOR_LANGUAGE(@"Start.Time") forState:(UIControlStateNormal)];
//    startDate = nil;
    
    [self.serachRoomsButton setTitle:STRING_FOR_LANGUAGE(@"Meeting.Rooms") forState:(UIControlStateNormal)];
    self.placeHolderLabel.text=STRING_FOR_LANGUAGE(@"Meeting.Time");

    self.availabelmeetingRoomLab.text = STRING_FOR_LANGUAGE(@"Available.MeetingRoom");
}

- (void)viewDidLayoutSubviews
{
    [self calendarView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setTheme
{
    NSInteger selectedThemeIndex = [[NSUserDefaults standardUserDefaults] integerForKey:BACKGROUND_THEME_VALUE];
    NSString *endSelectedimageName = [NSString stringWithFormat:@"endtTimeSelected_%li", (long)selectedThemeIndex];
    NSString *endnotSelectedimageName = [NSString stringWithFormat:@"endTimeNotSelected_%li", (long)selectedThemeIndex];

    [self.endTimeButton setBackgroundImage:[UIImage imageNamed:endSelectedimageName] forState:(UIControlStateHighlighted)];
    [self.endTimeButton setBackgroundImage:[UIImage imageNamed:endSelectedimageName] forState:(UIControlStateSelected)];
    [self.endTimeButton setBackgroundImage:[UIImage imageNamed:endnotSelectedimageName] forState:UIControlStateNormal];

    NSString *startSelectedimageName = [NSString stringWithFormat:@"startTimeSelected_%li", (long)selectedThemeIndex];
    NSString *startnotSelectedimageName = [NSString stringWithFormat:@"startTimeNotSelected_%li", (long)selectedThemeIndex];
    
    [self.startTimeButton setBackgroundImage:[UIImage imageNamed:startSelectedimageName] forState:(UIControlStateHighlighted)];
    [self.startTimeButton setBackgroundImage:[UIImage imageNamed:startSelectedimageName] forState:(UIControlStateSelected)];
    [self.startTimeButton setBackgroundImage:[UIImage imageNamed:startnotSelectedimageName] forState:UIControlStateNormal];

    NSString *selectedDateBannerName = [NSString stringWithFormat:@"selectedDateBanner_%li", (long)selectedThemeIndex];
    self.bannerImageView.image = [UIImage imageNamed:selectedDateBannerName];
    
    UIColor *color;
    
    switch ([[NSUserDefaults standardUserDefaults] integerForKey:BACKGROUND_THEME_VALUE])
    {
        case 0:
            color = [UIColor colorWithRed:.22 green:.6 blue:.79 alpha:1];
            break;
            
        case 1:
            color = [UIColor colorWithRed:.4 green:.6 blue:.23 alpha:1];
            break;
            
        case 2:
            color = [UIColor colorWithRed:.99 green:.4 blue:.24 alpha:1];
            break;
            
        case 3:
            color = [UIColor colorWithRed:.79 green:.21 blue:.4 alpha:1];
            break;
            
        default:
            break;
    }
    self.serachRoomsButton.backgroundColor = color;
}

- (void)getAllRoomsOfCurrentLocation
{
//    if (![AFNetworkReachabilityManager sharedManager].isReachable)
//    {
//        
//        return;
//    }
    selectedLocationEmailID = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_OFFICE_MAILID];
    
    if (selectedLocationEmailID)
    {
        currentlyExcutingMethod = @"getAllRoomsOfCurrentLocation";

        if ([passwordManager passwordForUser] != nil)
        {
            [roomManager getRoomsForRoomList:selectedLocationEmailID];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }else
        {
            [passwordManager showAlertWithDefaultMessage];
        }
    
    }else
    {
        officeLocationAlert = [[UIAlertView alloc] initWithTitle:STRING_FOR_LANGUAGE(@"Location.Required")
                                                            message:ALERT_MSG_SET_OFFICE_LOCATION
                                                           delegate:self
                                                  cancelButtonTitle:OK_FOR_ALERT
                                                  otherButtonTitles:nil];
        [officeLocationAlert show];
    }
}

- (CLWeeklyCalendarView *)calendarView
{
    if(!_calendarView)
    {
        _calendarView = [[CLWeeklyCalendarView alloc] initWithFrame:CGRectMake(0, 0, self.containerForCalendar.bounds.size.width, HEIGHT_OF_CL_CALENDAR)];
        _calendarView.delegate = self;
        
        [self.containerForCalendar addSubview:self.calendarView];
    }
    
    return _calendarView;
}

- (void)showSearchButton
{
    if (startDate == nil | endDate == nil)
    {
        return;
    }
    [self setButtonForSearchingFreeRoom];
    self.serachRoomsButton.hidden = NO;
}

- (BOOL)isDateToday:(NSDate *)dateToTest
{
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *components = [calender components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *todayDate = [calender dateFromComponents:components];
    
    components = [calender components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:dateToTest];
    NSDate *date = [calender dateFromComponents:components];
    
    if ([todayDate isEqualToDate:date])
    {
        return YES;
    }
    
    return NO;
}

- (IBAction)setStartTime:(UIButton *)sender
{
    [self setSelectedAsStart];
    self.availableRoomsView.hidden = YES;

    NSTimeInterval differenceFromCurrentDate = [startDate timeIntervalSinceDate:[NSDate date]];
    
    if (differenceFromCurrentDate < 0)
    {
        startDate = [self dateByGettingTimefrom:[NSDate date] withDateFrom:self.calendarView.selectedDate];
    }
    
    startDate = startDate?:[self dateByGettingTimefrom:[NSDate date] withDateFrom:self.calendarView.selectedDate];
    [self.startDatePicker setDate:startDate animated:YES];
    
    self.startDatePicker.minimumDate = [self isDateToday:startDate]?[self dateByGettingTimefrom:[NSDate date] withDateFrom:self.calendarView.selectedDate]:nil;
    
    dateFormatter.dateFormat = @"hh:mm a";
    NSString *dateInString = [dateFormatter stringFromDate:startDate];
    [self.startTimeButton setTitle:dateInString forState:(UIControlStateNormal)];

}

- (IBAction)setEndTime:(UIButton *)sender
{
    if (startDate == nil)
    {
        return;
    }
    [self setSelectedAsEnd];
    self.availableRoomsView.hidden = YES;
    NSDate *minDate = [startDate?:[NSDate date] dateByAddingTimeInterval:MIN_TIME_SLOT_FOR_SEARCH];
    [self.endDatePicker setMinimumDate:minDate];
    
//if START_DATE is nil, we will set END_DATE as currentDate+Min_TIME+SLOT
    endDate = endDate?:[self dateByGettingTimefrom:minDate withDateFrom:self.calendarView.selectedDate];
    [self.endDatePicker setDate:endDate animated:YES];
    
    dateFormatter.dateFormat = @"hh:mm a";
    NSString *dateInString = [dateFormatter stringFromDate:endDate];
    [self.endTimeButton setTitle:dateInString forState:(UIControlStateNormal)];
    
    [self showSearchButton];
}

- (void)setSelectedAsStart
{
    self.startTimeButton.selected = YES;
    self.startDatePicker.hidden = NO;
    self.endDatePicker.hidden = YES;
    self.endTimeButton.selected = NO;
    
    [self.endTimeButton setTitle:STRING_FOR_LANGUAGE(@"End.Time") forState:(UIControlStateNormal)];
    endDate = nil;
    self.serachRoomsButton.hidden = YES;

    self.placeHolderLabel.hidden = YES;
}

- (void)setSelectedAsEnd
{
    self.startTimeButton.selected = NO;
    self.startDatePicker.hidden = YES;
    self.endDatePicker.hidden = NO;
    self.endTimeButton.selected = YES;
    
    self.placeHolderLabel.hidden = YES;
}

- (BOOL)timeWindowIsValid
{
    NSTimeInterval timeIntervel = [startDate timeIntervalSinceDate:endDate];
    
//If START_DATE is EARLIER than END_DATE, return value will be NEGATIVE
    if (timeIntervel <= -MIN_TIME_SLOT_FOR_SEARCH)
    {
        return YES;
    }
    return NO;
}


- (IBAction)findAvailableRooms:(id)sender
{
    currentlyExcutingMethod = @"findAvailableRooms:";
    if ([sender tag] == 100)
    {
        [self performSegueWithIdentifier:@"RoomFinderToFreeSlotsSegue" sender:nil];
        return;
    }
    
//Start time can be 5 mins less than current time. Because we are round time to multiple of 5 mins (less than current time). So intervel can be till 300 seconds to be valid.
    
    NSTimeInterval intervel = [[NSDate date] timeIntervalSinceDate:startDate];
    if (intervel > 300)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_FOR_ALERT
                                                            message:ALERT_MSG_SELECT_FUTURE_TIME
                                                           delegate:self
                                                  cancelButtonTitle:OK_FOR_ALERT
                                                  otherButtonTitles: nil];
        [alertView show];
        
        [self resetView];
        
        return;
    }
    
    NSString *ewsRequestURL = [[NSUserDefaults standardUserDefaults] objectForKey:EWS_REQUSET_URL_KEY];
    
    if (ewsRequestURL == nil)
    {
        AppDelegate *appDel = [UIApplication sharedApplication].delegate;
        [appDel getEWSRequestURL];
        
        if (!tryAgainAlert)
        {
            tryAgainAlert = [[UIAlertView alloc] initWithTitle:ERROR_FOR_ALERT
                                                       message:ALERT_MSG_TRY_LATER
                                                      delegate:self
                                             cancelButtonTitle:OK_FOR_ALERT
                                             otherButtonTitles: nil];

        }
        [tryAgainAlert show];
    }
    
    if (![self timeWindowIsValid])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:WARNING_TEXT
                                                            message:ALERT_MSG_MINIMUM_TIME_SLOT
                                                           delegate:self
                                                  cancelButtonTitle:OK_FOR_ALERT
                                                  otherButtonTitles:nil];
        [alertView show];
        NSLog(@"Time window is less than MIN Value");
        return;
    }
    
    if (emailIDsOfRoomsToCheck.count == 0 | emailIDsOfRoomsToCheck == nil)
    {
        if (!tryAgainAlert)
        {
            tryAgainAlert = [[UIAlertView alloc] initWithTitle:ERROR_FOR_ALERT
                                                       message:ALERT_MSG_TRY_LATER
                                                      delegate:self
                                             cancelButtonTitle:OK_FOR_ALERT
                                             otherButtonTitles: nil];
            
        }
        [tryAgainAlert show];
        
        return;
    }
    
    self.placeHolderLabel.hidden = YES;

    [self resetView];
    
    //When you are booking a room for two consicutive time slots, [eg)12:00 to 12:30 and second Time slots is 12:30 to 1:00.] second time slot will not be valid as at 12:30 room is already booked. So to avoid this, what we can do is START TIME will always have AN ADDITIONAL SECOND ADDED. [eg) 12:00:01 to 12:30:00 and second time will be 12:30:01 to 1:00:00],
    startDate = [startDate dateByAddingTimeInterval:1];
    [roomManager availablityOfRooms:emailIDsOfRoomsToCheck forStart:startDate toEnd:endDate];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    startDate = [startDate dateByAddingTimeInterval:-1];

}

- (IBAction)datePickerValueChanged:(UIDatePicker *)sender
{
    UIButton *selectedButton;
    
    if ([sender isEqual:self.startDatePicker])
    {
        selectedButton = self.startTimeButton;
        startDate = [self dateByGettingTimefrom:sender.date withDateFrom:self.calendarView.selectedDate];
        NSLog(@"Start date = %@", startDate);
        
    }else if ([sender isEqual:self.endDatePicker])
    {
        selectedButton = self.endTimeButton;
        endDate = [self dateByGettingTimefrom:sender.date withDateFrom:self.calendarView.selectedDate];
        NSLog(@"End date = %@", endDate);
    }
    
    dateFormatter.dateFormat = @"hh:mm a";
    NSString *dateInString = [dateFormatter stringFromDate:sender.date];
    [selectedButton setTitle:dateInString forState:(UIControlStateNormal)];
    
    [self showSearchButton];
}

- (void)resetView
{
    self.startDatePicker.hidden = YES;
    self.endDatePicker.hidden = YES;
    self.startTimeButton.selected = NO;
    self.endTimeButton.selected = NO;
    self.availableRoomsView.hidden = YES;
}

- (void)resetToInitialState
{
    [self resetView];
    
    [self.endTimeButton setTitle:STRING_FOR_LANGUAGE(@"End.Time") forState:(UIControlStateNormal)];
    endDate = nil;
    
    [self.startTimeButton setTitle:STRING_FOR_LANGUAGE(@"Start.Time") forState:(UIControlStateNormal)];
    startDate = nil;
    
    self.calendarView.selectedDate = [NSDate date];
    [self.calendarView redrawToDate:[NSDate date]];
    
    [self setbuttonForSwitchMode];
    self.serachRoomsButton.hidden = NO;
}

- (IBAction)hidePickers:(UIView *)sender
{
    self.startDatePicker.hidden = YES;
    self.endDatePicker.hidden = YES;
    self.startTimeButton.selected = NO;
    self.endTimeButton.selected = NO;
}

- (RoomModel *)roomForEmailID:(NSString *)emailID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"emailIDOfRoom = %@", emailID];
    NSArray *filterdArray = [roomsToCheckModelArray filteredArrayUsingPredicate:predicate];
    
    if (filterdArray.count > 0)
    {
        return [filterdArray firstObject];
    }
    
    return nil;
}

- (void)refershAvailableRooms
{
    [self findAvailableRooms:nil];
}

- (BOOL)checkForPrivteRoom:(RoomModel *)room
{
    return ([room.nameOfRoom rangeOfString:@" Priv "].location == NSNotFound);
}

- (void)setbuttonForSwitchMode
{
    self.serachRoomsButton.tag = 100;
    [self.serachRoomsButton setTitle:STRING_FOR_LANGUAGE(@"Meeting.Rooms") forState:(UIControlStateNormal)];
}

- (void)setButtonForSearchingFreeRoom
{
    self.serachRoomsButton.tag = 111;
    [self.serachRoomsButton setTitle:STRING_FOR_LANGUAGE(@"Search.Room") forState:(UIControlStateNormal)];
}

- (void)dealloc
{
    NSLog(@"Deallocing RoonViewController");
    [roomManager stopRecognize];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [roomsAvailable count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell viewWithTag:100];
    RoomModel *model = roomsAvailable[indexPath.row];
    label.text = model.nameOfRoom;
    UIImageView *beaconIndicatorImageView = (UIImageView *)[cell viewWithTag:555];
    
    if (model.RSSIValue > NSIntegerMin & model.RSSIValue != 0)
    {
        beaconIndicatorImageView.image = [UIImage imageNamed:@"ibeacon-green"];
    }else
    {
        beaconIndicatorImageView.image = nil;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedindex = indexPath.row;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self checkForPrivteRoom:roomsAvailable[indexPath.row]])
    {
        [self performSegueWithIdentifier:@"romeFinderToInvite_segue" sender:nil];
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:WARNING_TEXT
                                                        message:ALERT_MSG_AUTHORIZED_BOOKING
                                                       delegate:self
                                              cancelButtonTitle:STRING_FOR_LANGUAGE(@"No")
                                              otherButtonTitles:STRING_FOR_LANGUAGE(@"Yes"), nil];
        [alert show];
    }
}


#pragma mark - RoomManagerDelegate
- (void)roomManager:(RoomManager *)manager updatedRSSIValueForRooms:(NSMutableArray *)updatedRooms
{
    roomsToCheckModelArray = updatedRooms;
    
    if (roomsAvailable.count > 0)
    {
        NSSortDescriptor *sortForRSSI = [NSSortDescriptor sortDescriptorWithKey:@"RSSIValue" ascending:NO];
        NSSortDescriptor *sortForNameOfRoom = [NSSortDescriptor sortDescriptorWithKey:@"nameOfRoom" ascending:YES];
        
        [roomsAvailable sortUsingDescriptors:@[sortForRSSI, sortForNameOfRoom]];
        
        [self.tableView reloadData];
    }
}

- (void)roomManager:(RoomManager *)manager foundAvailableRooms:(NSArray *)availableRooms
{
    selectedindex = -1;//Negative value wont be INDEX of cell
    
    if (roomsAvailable == nil)
    {
        roomsAvailable = [[NSMutableArray alloc] init];
    }else
    {
        [roomsAvailable removeAllObjects];
    }
    
    for (NSString *anEmailID in availableRooms)
    {
        RoomModel *model = [self roomForEmailID:anEmailID];
        if (model)
        {
            [roomsAvailable addObject:model];
        }
    }
    
    if (roomsAvailable.count == 0)
    {
        self.placeHolderLabel.hidden = NO;
//        self.placeHolderLabel.text = @"No Meeting Rooms are available for the selected time slot.";
        self.placeHolderLabel.text = STRING_FOR_LANGUAGE(@"Rooms.Slot");

   
    }
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"nameOfRoom" ascending:YES];
    roomsAvailable = [[roomsAvailable sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
    
    [self.tableView reloadData];
    self.availableRoomsView.hidden = NO;
    [self setButtonForSearchingFreeRoom];
    self.serachRoomsButton.hidden = YES;
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)roomManager:(RoomManager *)manager FoundRooms:(NSArray *)rooms
{
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"nameOfRoom" ascending:YES];
//    rooms = [rooms sortedArrayUsingDescriptors:@[sortDescriptor]] ;

    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (RoomModel *aRoom in rooms)
    {
        [array addObject:aRoom.emailIDOfRoom];
    }
    
    emailIDsOfRoomsToCheck = array;
    roomsToCheckModelArray = rooms;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)roomManager:(RoomManager *)manager failedWithError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)roomManager:(RoomManager *)manager failedToGetPassword:(PasswordManager *)passwordManager
{
    if ([currentlyExcutingMethod isEqualToString:@"getAllRoomsOfCurrentLocation"])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)roomManager:(RoomManager *)manager gotPassword:(PasswordManager *)passwordManager
{
    if ([currentlyExcutingMethod isEqualToString:@"getAllRoomsOfCurrentLocation"])
    {
        [self getAllRoomsOfCurrentLocation];
        
    }else if ([currentlyExcutingMethod isEqualToString:@"findAvailableRooms:"])
    {
        
    }
}

#pragma mark - CLWeeklyCalendarViewDelegate

- (NSDictionary *)CLCalendarBehaviorAttributes
{
    return @{
             CLCalendarWeekStartDay : @1,                 //Start Day of the week, from 1-7 Mon-Sun -- default 1
             CLCalendarDayTitleTextColor : [UIColor darkGrayColor],
             CLCalendarBackgroundImageColor: [UIColor colorWithRed:0.44 green:0.81 blue:0.96 alpha:1]
             };
}

- (void)dailyCalendarViewDidSelect:(NSDate *)date
{
//    startDate = startDate?:[NSDate date];
//    endDate = endDate?:[startDate dateByAddingTimeInterval:MIN_TIME_SLOT_FOR_SEARCH];

    if ([date isPastDate] && ![date isDateToday])
    {
        [self.calendarView redrawToDate:[NSDate date]];
        return;
    }
    
    startDate = [self dateByGettingTimefrom:startDate withDateFrom:date];
    NSLog(@"Start date = %@", startDate);
    
    endDate = [self dateByGettingTimefrom:endDate withDateFrom:date];
    NSLog(@"End date = %@", endDate);
    
    localeDateFormatter.dateFormat = @"dd MMMM yyyy";
    localeDateFormatter.locale = [NSLocale localeWithLocaleIdentifier:selectedLanguageCode];
    self.selectedDateLabel.text = [localeDateFormatter stringFromDate:date];
    
    if (endDate != nil)
    {
        self.serachRoomsButton.hidden = NO;
    }
    
    [self resetView];
}

- (NSDate *)dateByGettingTimefrom:(NSDate *)dateForTime withDateFrom:(NSDate *)dateFromDdate
{
    if (dateForTime == nil | dateFromDdate == nil)
    {
        return nil;
    }
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:unitFlags fromDate:dateFromDdate];
    NSDate *dateFromCalendar = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit ;
    components = [[NSCalendar currentCalendar] components:unitFlags fromDate:dateForTime];
    components.minute = (components.minute / 5) * 5;
    NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:dateFromCalendar options:0];
    
    return date;
}

#pragma mark - NavigatoinDelegate
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"romeFinderToInvite_segue"])
    {
        InviteAttendeesViewController *inviteVC = (InviteAttendeesViewController *)segue.destinationViewController;
        inviteVC.startDate = [startDate copy];
        inviteVC.endDate = [endDate copy];
        
        inviteVC.selectedRoom = roomsAvailable[selectedindex];
    }else if ([segue.identifier isEqualToString:@"RoomFinderToFreeSlotsSegue"])
    {
        FreeSlotsViewController *freeSlotsVC = (FreeSlotsViewController *)segue.destinationViewController;
        freeSlotsVC.roomManager = roomManager;
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"nameOfRoom" ascending:YES];
        freeSlotsVC.rooms = [roomsToCheckModelArray sortedArrayUsingDescriptors:@[sortDescriptor]];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView isEqual:officeLocationAlert])
    {
//        [self.navigationController popToRootViewControllerAnimated:YES];
        [self.tabBarController setSelectedIndex:1];
        return;
    }
    if ([alertView isEqual:tryAgainAlert])
    {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if (buttonIndex == 1)
    {
        [self performSegueWithIdentifier:@"romeFinderToInvite_segue" sender:nil];
    }
}

#pragma mark - PasswordManagerDelegate
- (void)passwordManagerGotPassword:(PasswordManager *)manager
{
    if ([currentlyExcutingMethod isEqualToString:@"getAllRoomsOfCurrentLocation"])
    {
        [self getAllRoomsOfCurrentLocation];
        
    }else if ([currentlyExcutingMethod isEqualToString:@"findAvailableRooms:"])
    {
        
    }
}

- (void)passwordManagerFailedToGetPassoword:(PasswordManager *)manager
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
