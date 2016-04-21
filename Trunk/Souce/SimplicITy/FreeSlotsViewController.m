//
//  FreeSlotsViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 4/14/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#define HEIGHT_OF_CL_CALENDAR 79

#import "FreeSlotsViewController.h"
#import "CLWeeklyCalendarViewSourceCode/CLWeeklyCalendarView.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "RoomManager.h"
#import "RoomModel.h"
#import "TimeWindow.h"
#import "InviteAttendeesViewController.h"
#import "NSDate+CL.h"
#import "PasswordManager.h"

//#define ALERT_MSG_SET_OFFICE_LOCATION @"Please go to Settings and choose Office Location"

@interface FreeSlotsViewController () <CLWeeklyCalendarViewDelegate, RoomManagerDelegate, UITableViewDataSource, UITableViewDelegate, PasswordManagerDelegate>

@property (nonatomic, strong) CLWeeklyCalendarView *calendarView;

@property (weak, nonatomic) IBOutlet UIView *containerForCalendar;
@property (weak, nonatomic) IBOutlet UILabel *selectedDateLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *bannerImageView;
@property (weak, nonatomic) IBOutlet UIButton *searchByTimeButton;

@end

@implementation FreeSlotsViewController
{
    PasswordManager *passwordManager;
    NSString *currentlyExcutingMethod;

    NSString *selectedLocationEmailID;
    
    NSIndexPath *selectedIndexPath;
    NSInteger selectedTimeSlotIndex;
    
    NSDate *startDate, *endDate;
    NSDate *selectedDate;
    
    NSArray *freeSlotsArray;
    
    NSDateFormatter *dateFormatter, *localeDateFormatter;
    
    UIBarButtonItem *backButton;
    UIButton *back;
    
    BOOL preventReloadingOfTable;//When user taps a Room, free slots will be shown to user. At that time we should not reload the table as BEACON VALUE CAHNGES. So whenever user taps on a Room we will prevent table reload as BEACON VALUE CAHNGES
    NSString *selectedLanguageCode;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    roomManager = [[RoomManager alloc] init];
    localeDateFormatter = [[NSDateFormatter alloc] init];

    self.containerForCalendar.layer.masksToBounds = YES;
    
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
    
    //self.title = @"Book a Room";
    
    passwordManager = [[PasswordManager alloc] init];
    passwordManager.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.roomManager.delegate = self;
    [self setTheme];
    selectedLanguageCode = [MCLocalization sharedInstance].language;

    if (self.rooms.count == 0 | self.rooms == nil)
    {
        [self getAllRoomsOfCurrentLocation];
    }else
    {
        
    }
    
    self.searchByTimeButton.layer.cornerRadius = 5;
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localize) name:MCLocalizationLanguageDidChangeNotification object:nil];
    [self localize];
    
}

-(void) localize
{
    self.title = STRING_FOR_LANGUAGE(@"Book.Room");
    [back setTitle:STRING_FOR_LANGUAGE(@"Home") forState:UIControlStateNormal];
    [back sizeToFit];
    [self.searchByTimeButton setTitle:STRING_FOR_LANGUAGE(@"Search.Date") forState:(UIControlStateNormal)];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    NSInteger previousSection = selectedIndexPath.section;
    if (selectedIndexPath != nil)
    {
        freeSlotsArray = nil;
        selectedIndexPath = nil;
        [self updateTableViewSection:previousSection];
    }
}

- (void)viewDidLayoutSubviews
{
    [self calendarView];
}

- (void)setTheme
{
    NSInteger selectedThemeIndex = [[NSUserDefaults standardUserDefaults] integerForKey:BACKGROUND_THEME_VALUE];
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
    self.searchByTimeButton.backgroundColor = color;
}

- (void)backBtnAction
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    //    self.writeReviewTxtView.text = @"";
    //    [self hideWriteReviewTextView];
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

- (IBAction)searchByTime:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getAllRoomsOfCurrentLocation
{
    selectedLocationEmailID = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_OFFICE_MAILID];
    
    if (selectedLocationEmailID)
    {
        currentlyExcutingMethod = @"getAllRoomsOfCurrentLocation";
        
        if ([passwordManager passwordForUser].length > 0)
        {
            [self.roomManager getRoomsForRoomList:selectedLocationEmailID];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }else
        {
            [passwordManager showAlertWithDefaultMessage];
        }
        
    }else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:WARNING_TEXT
                                                            message:ALERT_MSG_SET_OFFICE_LOCATION
                                                           delegate:self
                                                  cancelButtonTitle:OK_FOR_ALERT
                                                  otherButtonTitles:nil];
        [alertView show];
    }
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

- (void)updateStartAndEndDateFor:(NSDate *)date
{
    NSDate *updatedStartDate, *updatedEndDate;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];

    NSDateComponents *components = [gregorian components:NSUIntegerMax
                                                                   fromDate:date];
//if date is today, we will just convert it to next 5 min value.
//If date is any other day we will just convert hour and min to represent START OF THE DAY
    if ([self isDateToday:date])
    {
        [components setMinute:(components.minute / 5) * 5];
        [components setSecond:0];
    }else
    {
        [components setHour:0];
        [components setMinute:0];
        [components setSecond:0];
    }
    updatedStartDate = [gregorian dateFromComponents:components];
    
    [components setHour:23];
    [components setMinute:55];

    updatedEndDate = [gregorian dateFromComponents:components];
    
    startDate = updatedStartDate;
    endDate = updatedEndDate;
}

- (void)updateTableViewSection:(NSInteger)section
{
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (NSString *)stringFromTimeWindow:(TimeWindow *)timeWindow
{
    if (dateFormatter == nil)
    {
        dateFormatter = [[NSDateFormatter alloc] initWithSafeLocale];
    }
    dateFormatter.dateFormat = @"HH:mm";
    
    NSString *startString = [dateFormatter stringFromDate:timeWindow.startDate];
    NSString *endString = [dateFormatter stringFromDate:timeWindow.endDate];
    
    return [NSString stringWithFormat:@"%@ to %@", startString, endString];
}
- (BOOL)checkForPrivteRoom:(RoomModel *)room
{
    return ([room.nameOfRoom rangeOfString:@" Priv "].location == NSNotFound);
}

- (NSString *)timeGapFor:(TimeWindow *)timeWindow
{
    NSInteger timeIntervel = (NSInteger)[timeWindow.endDate timeIntervalSinceDate:timeWindow.startDate];
    NSInteger hours = timeIntervel/3600;
    NSInteger minutes = timeIntervel%3600/60;
    
    NSMutableString *timeGapString = [[NSMutableString alloc] init];
    
    if (hours)
    {
        [timeGapString appendFormat:@"%li hrs",(long) hours];
    }
    if (minutes)
    {
        [timeGapString appendFormat:@" %li mins",(long) minutes];
    }
    
    return timeGapString;
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.rooms.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (selectedIndexPath != nil)
    {
        if (selectedIndexPath.section == section)
        {
            return freeSlotsArray.count+1;
        }
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];
        RoomModel *model = self.rooms[indexPath.section];
        UILabel *officelabel = (UILabel *)[cell viewWithTag:100];
        
        officelabel.text = model.nameOfRoom;
        
        UIImageView *beaconIndicatorImageView = (UIImageView *)[cell viewWithTag:555];
        if (model.RSSIValue > NSIntegerMin & model.RSSIValue != 0)
        {
            beaconIndicatorImageView.image = [UIImage imageNamed:@"ibeacon-green"];
        }else
        {
            beaconIndicatorImageView.image = nil;
        }
    }else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell2" forIndexPath:indexPath];
        TimeWindow *timeWindow = freeSlotsArray[indexPath.row - 1];
        UILabel *startEndTimeLabel = (UILabel *)[cell viewWithTag:100];
        startEndTimeLabel.text = [self stringFromTimeWindow:timeWindow];
        
        UILabel *timeGapLabel = (UILabel *)[cell viewWithTag:200];
        timeGapLabel.text = [self timeGapFor:timeWindow];
    }
    
    if ([selectedIndexPath isEqual:indexPath])
    {

    }else
    {

    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0)
    {
        NSInteger previousSection = selectedIndexPath.section;
        
        if (selectedIndexPath != nil)
        {
            preventReloadingOfTable = NO;
            freeSlotsArray = nil;
            selectedIndexPath = nil;
            [self updateTableViewSection:previousSection];
//            self.searchByTimeButton.hidden = YES;
        }else
        {
            previousSection = -1;//Negative vlues are not possible for sectoin value.
            self.searchByTimeButton.hidden = YES;
            [self.searchByTimeButton removeFromSuperview];
        }
        if (indexPath.section != previousSection)
        {
            //When user taps on a new ROOM
            selectedDate = selectedDate?:[NSDate date];
            [self updateStartAndEndDateFor:selectedDate];
            selectedIndexPath = indexPath;
            
            preventReloadingOfTable = YES;//When user taps a Room, free slots will be shown to user. At that time we should not reload the table as BEACON VALUE CAHNGES. So whenever user taps on a Room we will prevent table reload as BEACON VALUE CAHNGES
            
            RoomModel *model = self.rooms[indexPath.section];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [self.roomManager findFreeSlotsOfRooms:@[model.emailIDOfRoom]
                                     forStart:startDate
                                        toEnd:endDate];
            
        }
        
//        if (selectedIndexPath)
//        {
//            self.searchByTimeButton.hidden = YES;
//        }else
//        {
//            self.searchByTimeButton.hidden = NO;
//        }
    }else if (indexPath.section == selectedIndexPath.section)
    {
        selectedTimeSlotIndex = indexPath.row;
        [self performSegueWithIdentifier:@"BookbyRoomToInviteAttendeeSegue" sender:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return 40;
    }
    
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section != 0)
    {
        return 0;
    }
    
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section != 0)
    {
        return nil;
    }
    UIView *headerView =  [[UIView alloc] initWithFrame:(CGRectMake(0, 0, 150, 30))];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:(CGRectMake(18, 5, 150, 30))];
    headerView.backgroundColor = [UIColor colorWithRed:.38 green:.77 blue:.95 alpha:1];
    headerLabel.font = [UIFont boldSystemFontOfSize:14];
   // headerLabel.text = @"Meeting Room(s)";
    headerLabel.text = STRING_FOR_LANGUAGE(@"rooms.meeting");
    [headerLabel sizeToFit];
    headerLabel.textColor = [UIColor whiteColor];
    [headerView addSubview:headerLabel];
    
    return headerView;
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
    if ([date isPastDate] && ![date isDateToday])
    {
        [self.calendarView redrawToDate:[NSDate date]];
        return;
    }
    selectedDate = date;
    
    NSInteger previousSection = selectedIndexPath.section;
    if (selectedIndexPath != nil)
    {
        freeSlotsArray = nil;
        selectedIndexPath = nil;
        [self updateTableViewSection:previousSection];
    }
    
    if (dateFormatter == nil)
    {
        dateFormatter = [[NSDateFormatter alloc] initWithSafeLocale];
    }
    
    localeDateFormatter.dateFormat = @"dd MMMM yyyy";
    localeDateFormatter.locale = [NSLocale localeWithLocaleIdentifier:selectedLanguageCode];
    self.selectedDateLabel.text = [localeDateFormatter stringFromDate:date];

}

#pragma mark - RoomManagerDelegate

- (void)roomManager:(RoomManager *)manager updatedRSSIValueForRooms:(NSMutableArray *)updatedRooms
{
    self.rooms = updatedRooms;
    
    if (preventReloadingOfTable) return; //When user taps a Room, free slots will be shown to user. At that time we should not reload the table as BEACON VALUE CAHNGES. So whenever user taps on a Room we will prevent table reload as BEACON VALUE CAHNGES

    
    if (updatedRooms.count > 0)
    {
        NSSortDescriptor *sortForRSSI = [NSSortDescriptor sortDescriptorWithKey:@"RSSIValue" ascending:NO];
        NSSortDescriptor *sortForNameOfRoom = [NSSortDescriptor sortDescriptorWithKey:@"nameOfRoom" ascending:YES];
        
        [updatedRooms sortUsingDescriptors:@[sortForRSSI, sortForNameOfRoom]];
        
        self.rooms = updatedRooms;
        [self.tableView reloadData];
    }
}
- (void)roomManager:(RoomManager *)manager FoundRooms:(NSArray *)rooms
{    
    self.rooms = rooms;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self.tableView reloadData];
}

- (void)roomManager:(RoomManager *)manager failedWithError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)roomManager:(RoomManager *)manager foundSlotsAvailable:(NSDictionary *)dictOfAllRooms
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    if (selectedIndexPath == nil)
    {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning"
//                                                            message:@"No slots available"
//                                                           delegate:self
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//        [alertView show];

        return;
    }
    
    RoomModel *model = self.rooms[selectedIndexPath.section];
    freeSlotsArray = dictOfAllRooms[model.emailIDOfRoom];
    if (freeSlotsArray.count == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:WARNING_TEXT
                                                            message:STRING_FOR_LANGUAGE(@"No.TimeSlot")
                                                           delegate:self
                                                  cancelButtonTitle:OK_FOR_ALERT
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [self updateTableViewSection:selectedIndexPath.section];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:freeSlotsArray.count inSection:selectedIndexPath.section];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:(UITableViewScrollPositionBottom)
                                  animated:YES];
//    [self.tableView selectRowAtIndexPath:selectedIndexPath
//                                animated:YES
//                          scrollPosition:(UITableViewScrollPositionNone)];
}

- (void)roomManager:(RoomManager *)manager gotPassword:(PasswordManager *)passwordManager
{
    if ([currentlyExcutingMethod isEqualToString:@"getAllRoomsOfCurrentLocation"])
    {
        [self getAllRoomsOfCurrentLocation];
        
    }
}

- (void)roomManager:(RoomManager *)manager failedToGetPassword:(PasswordManager *)passwordManager
{
    if ([currentlyExcutingMethod isEqualToString:@"getAllRoomsOfCurrentLocation"])
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"BookbyRoomToInviteAttendeeSegue"])
    {
        InviteAttendeesViewController *inviteVC = (InviteAttendeesViewController *)segue.destinationViewController;
        TimeWindow *timeWindow = freeSlotsArray[selectedTimeSlotIndex-1];
        inviteVC.startDate = [timeWindow.startDate copy];
        inviteVC.endDate = [timeWindow.endDate copy];
        
        inviteVC.selectedRoom = self.rooms[selectedIndexPath.section];
        inviteVC.fromSelectRoomVC = YES;
    }
}

#pragma mark - PasswordManagerDelegate
- (void)passwordManagerGotPassword:(PasswordManager *)manager
{
    if ([currentlyExcutingMethod isEqualToString:@"getAllRoomsOfCurrentLocation"])
    {
        [self getAllRoomsOfCurrentLocation];
        
    }
}

- (void)passwordManagerFailedToGetPassoword:(PasswordManager *)manager
{
    [self.navigationController popToRootViewControllerAnimated:YES];
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
