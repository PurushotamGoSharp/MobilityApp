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

#define HEIGHT_OF_CL_CALENDAR 79
#define MIN_TIME_SLOT_FOR_SEARCH 15*60

@interface RoomFinderViewController () <UITableViewDataSource, UITableViewDelegate, RoomManagerDelegate, CLWeeklyCalendarViewDelegate>
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

@property (nonatomic, strong) CLWeeklyCalendarView *calendarView;

@end

@implementation RoomFinderViewController
{
    NSDateFormatter *dateFormatter;
    RoomManager *roomManager;
    
    NSArray *roomsAvailable;
    NSArray *roomsToCheck;
    NSDate *startDate, *endDate;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"hh.mm a";
    
    roomManager = [[RoomManager alloc] init];
    roomManager.delegate = self;
    roomsToCheck = @[@"boardroom@vmex.com", @"trainingroom@vmex.com", @"discussionroom@vmex.com", @"room1@vmex.com"];
    
    self.containerForCalendar.layer.masksToBounds = YES;
//    [self.startTimeButton setBackgroundImage:[[UIImage imageNamed:@"startTimeNormal"] resizableImageWithCapInsets:(UIEdgeInsetsMake(0, 0, 0, 40))] forState:(UIControlStateNormal)];
//    [self.startTimeButton setBackgroundImage:[[UIImage imageNamed:@"startTimeSelected"] resizableImageWithCapInsets:(UIEdgeInsetsMake(0, 0, 0, 40))] forState:(UIControlStateSelected | UIControlStateHighlighted)];
//    
//    [self.endTimeButton setBackgroundImage:[[UIImage imageNamed:@"endTime"] resizableImageWithCapInsets:(UIEdgeInsetsMake(0, 0, 0, 40))] forState:(UIControlStateNormal)];
//    [self.endTimeButton setBackgroundImage:[[UIImage imageNamed:@"endTime Selected"] resizableImageWithCapInsets:(UIEdgeInsetsMake(0, 0, 0, 40))] forState:(UIControlStateSelected | UIControlStateHighlighted)];
    
    [roomManager getRoomsForRoomList:@"Building1ConferenceRooms@vmex.com"];
    
    self.serachRoomsButton.layer.cornerRadius = 5;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    
    self.serachRoomsButton.hidden = NO;
}

- (IBAction)setStartTime:(UIButton *)sender
{
    [self setSelectedAsStart];
    self.availableRoomsView.hidden = YES;

    startDate = startDate?:[NSDate date];
    [self.startDatePicker setDate:startDate animated:YES];
    
//    dateFormatter.dateFormat = @"hh.mm a";
//    NSString *dateInString = [dateFormatter stringFromDate:startDate];
//    [self.startTimeButton setTitle:dateInString forState:(UIControlStateNormal)];

}

- (IBAction)setEndTime:(UIButton *)sender
{
    [self setSelectedAsEnd];
    self.availableRoomsView.hidden = YES;
    NSDate *minDate = [startDate?:[NSDate date] dateByAddingTimeInterval:MIN_TIME_SLOT_FOR_SEARCH];
//    [self.endDatePicker setMinimumDate:minDate];
    
//if START_DATE is nil, we will set END_DATE as currentDate+Min_TIME+SLOT
    endDate = endDate?:minDate;
    [self.endDatePicker setDate:endDate animated:YES];
    
//    dateFormatter.dateFormat = @"hh.mm a";
//    NSString *dateInString = [dateFormatter stringFromDate:endDate];
//    [self.endTimeButton setTitle:dateInString forState:(UIControlStateNormal)];

}

- (void)setSelectedAsStart
{
    self.startTimeButton.selected = YES;
    self.startDatePicker.hidden = NO;
    self.endDatePicker.hidden = YES;
    self.endTimeButton.selected = NO;
    
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
    if (![self timeWindowIsValid])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please select a time slot minimum of 15 minutes" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        NSLog(@"Time window is less than MIN Value");
        return;
    }
    
    self.placeHolderLabel.hidden = YES;

    [self resetView];
    [roomManager availablityOfRooms:roomsToCheck forStart:startDate toEnd:endDate];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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
    
    dateFormatter.dateFormat = @"hh.mm a";
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


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [roomsAvailable count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell viewWithTag:100];
    label.text = roomsAvailable[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}



#pragma mark - RoomManagerDelegate
- (void)roomManager:(RoomManager *)manager foundAvailableRooms:(NSArray *)availableRooms
{
    roomsAvailable = availableRooms;
    
    if (roomsAvailable.count == 0)
    {
        self.placeHolderLabel.hidden = NO;
        self.placeHolderLabel.text = @"No rooms are available for the selected time slot.";
    }
    
    [self.tableView reloadData];
    self.availableRoomsView.hidden = NO;
    self.serachRoomsButton.hidden = YES;
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)roomManager:(RoomManager *)manager FoundRooms:(NSArray *)rooms
{
    
}

- (void)roomManager:(RoomManager *)manager failedWithError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
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

    startDate = [self dateByGettingTimefrom:startDate withDateFrom:date];
    NSLog(@"Start date = %@", startDate);
    
    endDate = [self dateByGettingTimefrom:endDate withDateFrom:date];
    NSLog(@"End date = %@", endDate);
    
    dateFormatter.dateFormat = @"dd MMMM yyyy";
    self.selectedDateLabel.text = [dateFormatter stringFromDate:date];
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
    NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:dateFromCalendar options:0];
    
    return date;
}

@end
