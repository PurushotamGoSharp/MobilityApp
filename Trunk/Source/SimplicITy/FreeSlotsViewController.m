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

@interface FreeSlotsViewController () <CLWeeklyCalendarViewDelegate, RoomManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) CLWeeklyCalendarView *calendarView;

@property (weak, nonatomic) IBOutlet UIView *containerForCalendar;
@property (weak, nonatomic) IBOutlet UILabel *selectedDateLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FreeSlotsViewController
{
    RoomManager *roomManager;
    NSString *selectedLocationEmailID;
    
    NSIndexPath *selectedIndexPath;
    NSInteger selectedTimeSlotIndex;
    
    NSDate *startDate, *endDate;
    NSDate *selectedDate;
    
    NSArray *freeSlotsArray;
    
    NSDateFormatter *dateFormatter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    roomManager = [[RoomManager alloc] init];
    roomManager.delegate = self;
    
    self.containerForCalendar.layer.masksToBounds = YES;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.rooms.count == 0 | self.rooms == nil)
    {
        [self getAllRoomsOfCurrentLocation];
    }else
    {
        
    }
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

- (void)getAllRoomsOfCurrentLocation
{
    selectedLocationEmailID = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_OFFICE_MAILID];
    
    if (selectedLocationEmailID)
    {
        [roomManager getRoomsForRoomList:selectedLocationEmailID];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                            message:@"Please go to settings and configure Book a Room settings"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
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
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    dateFormatter.dateFormat = @"HH:mm";
    
    NSString *startString = [dateFormatter stringFromDate:timeWindow.startDate];
    NSString *endString = [dateFormatter stringFromDate:timeWindow.endDate];
    
    return [NSString stringWithFormat:@"%@ to %@", startString, endString];
}

- (NSString *)timeGapFor:(TimeWindow *)timeWindow
{
    NSInteger timeIntervel = (NSInteger)[timeWindow.endDate timeIntervalSinceDate:timeWindow.startDate];
    NSInteger hours = timeIntervel/3600;
    NSInteger minutes = timeIntervel%3600/60;
    
    NSMutableString *timeGapString = [[NSMutableString alloc] init];
    
    if (hours)
    {
        [timeGapString appendFormat:@"%li hrs", hours];
    }
    if (minutes)
    {
        [timeGapString appendFormat:@" %li mins", minutes];
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
        [cell setSelected:YES animated:YES];
    }else
    {
        [cell setSelected:NO animated:NO];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        NSInteger previousSection = selectedIndexPath.section;
        
        if (selectedIndexPath != nil)
        {
            freeSlotsArray = nil;
            selectedIndexPath = nil;
            [self updateTableViewSection:previousSection];
        }else
        {
            previousSection = -1;//Negative vlues are not possible for sectoin value.
        }
        
        if (indexPath.section != previousSection)
        {
            selectedDate = selectedDate?:[NSDate date];
            [self updateStartAndEndDateFor:selectedDate];
            
            selectedIndexPath = indexPath;
            
            RoomModel *model = self.rooms[indexPath.section];
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [roomManager findFreeSlotsOfRooms:@[model.emailIDOfRoom]
                                     forStart:startDate
                                        toEnd:endDate];
        }
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
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    
    dateFormatter.dateFormat = @"dd MMMM yyyy";
    self.selectedDateLabel.text = [dateFormatter stringFromDate:date];

}

#pragma mark - RoomManagerDelegate
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
    if (selectedIndexPath == nil)
    {
        return;
    }
    
    RoomModel *model = self.rooms[selectedIndexPath.section];
    freeSlotsArray = dictOfAllRooms[model.emailIDOfRoom];
    [self updateTableViewSection:selectedIndexPath.section];

    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
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
