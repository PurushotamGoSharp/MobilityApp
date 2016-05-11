//
//  InviteAttendeesViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 06/04/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "InviteAttendeesViewController.h"
#import "UserInfo.h"
#import "RoomManager.h"
#import "CalendarEvent.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "RoomFinderViewController.h"
#import "AddAttendeesViewController.h"
#import "ContactDetails.h"
#import "SelectDateTableViewCell.h"
#import "AppDelegate.h"

#define MIN_TIME_SLOT_FOR_SEARCH 10*60
//#define ALERT_MSG_MINIMUM_TIME_SLOT_10 @"Please select a Time Slot of minimum 10 minutes"
//#define ALERT_MSG_ALREADY_BOOKED @"Sorry! Meeting Room already booked by someone else recently."
//#define ALERT_MSG_SUCCESSFULL_BOOKING @"Successfully booked the Meeting Room."

@interface InviteAttendeesViewController ()<UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate, RoomManagerDelegate, UIAlertViewDelegate, AddAttendeesDelegate, SelectDateCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *sendInviteButton;

@end

@implementation InviteAttendeesViewController
{
  
    NSArray *dataOfFirstSection;
    NSArray *dataOfThirdSection;
    NSMutableArray *reqiuredAttentees;

    NSString *dateForBooking;
    NSString *startDateString, *endDateString;
    NSDateFormatter *dateFormatter;
    
    NSString *userName;
    NSString *venue;
    
    RoomManager *roomManager, *attendeeAvailablityChecker;
    CalendarEvent *newEvent;
    
    UITextField *activeField;
    UITextField *enterUserNameTextField;
    UIAlertView *successfullAlert;
    
    UIBarButtonItem *backButton;
    
    BOOL searchFieldIsSelected;
    BOOL reduceSizeOfCell;
    UIButton *back;
    NSIndexPath *selectedTimeIndex;
    NSDate *initialStartDate, *initialEndDate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    dataOfThirdSection = @[@"",@"Marc",@"Bin",@"Antony",@"Sundar"];

    dateFormatter = [[NSDateFormatter alloc] initWithSafeLocale];
    dateFormatter.dateFormat = @"EEEE dd MMMM yyyy";
    dateForBooking = [dateFormatter stringFromDate:self.startDate];
    
    dateFormatter.dateFormat = @"hh:mm a";
    startDateString = [dateFormatter stringFromDate:self.startDate];
    endDateString = [dateFormatter stringFromDate:self.endDate];
    
    userName = [UserInfo sharedUserInfo].fullName;
    venue = self.selectedRoom.nameOfRoom;
    
    self.sendInviteButton.layer.cornerRadius = 5;
    self.sendInviteButton.titleLabel.font = [self customFont:16 ofName:MuseoSans_700];

    roomManager = [[RoomManager alloc] init];
    roomManager.delegate = self;
    newEvent = [[CalendarEvent alloc] init];
    
    newEvent.startDate = self.startDate;
    newEvent.endDate = self.endDate;
    newEvent.location = self.selectedRoom.nameOfRoom;
    newEvent.resources = @[self.selectedRoom.emailIDOfRoom];
    
    initialStartDate = [self.startDate copy];
    initialEndDate = [self.endDate copy];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
    
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tableView.estimatedRowHeight = 40;
    [self registerForKeyboardNotifications];
    [self setTheme];

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localize) name:MCLocalizationLanguageDidChangeNotification object:nil];
    [self localize];


}

-(void)localize
{
 self.title = STRING_FOR_LANGUAGE(@"invite.attendee");
  dataOfFirstSection = @[STRING_FOR_LANGUAGE(@"Date"),STRING_FOR_LANGUAGE(@"start"),STRING_FOR_LANGUAGE(@"End"),STRING_FOR_LANGUAGE(@"Organizer"),STRING_FOR_LANGUAGE(@"Venue")];
   [back setTitle:STRING_FOR_LANGUAGE(@"Back.Survey") forState:UIControlStateNormal];
    [back sizeToFit];
    [self.sendInviteButton setTitle:STRING_FOR_LANGUAGE(@"Send.Invite") forState:UIControlStateNormal];
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)setTheme
{
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
    self.sendInviteButton.backgroundColor = color;
}
- (void)backBtnAction
{
    if (!self.fromSelectRoomVC)
    {
        NSArray *viewControllers = self.navigationController.viewControllers;
        RoomFinderViewController *roomFinderVC = (RoomFinderViewController *)viewControllers[viewControllers.count-2];
        [roomFinderVC refershAvailableRooms];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)hideKeyboard:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
    
    if (selectedTimeIndex)
    {
        CGPoint point = [tap locationInView:self.tableView];
        NSIndexPath *tappedIndexPath = [self.tableView indexPathForRowAtPoint:point];
        
        if (![tappedIndexPath isEqual:selectedTimeIndex])
        {
            NSIndexPath *indexPath = selectedTimeIndex;
            if ((tappedIndexPath.row != 1) & (tappedIndexPath.row != 2))
            {
                selectedTimeIndex = nil;
            }
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:(UITableViewRowAnimationFade)];
            [self.tableView endUpdates];
        }
    }
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
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
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        [self.tableView scrollRectToVisible:activeField.frame animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

- (void)setStartDateForDatePicker:(UIDatePicker *)datePicker
{
    
}

- (void)addAttentee:(UIButton *)sender
{
//    if (reqiuredAttentees == nil)
//    {
//        reqiuredAttentees = [[NSMutableArray alloc] init];
//    }
//    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:2];
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:index];
//    UITextField *txtField = (UITextField*)[cell viewWithTag:100];
//    
//    if (txtField.text.length > 0)
//    {
//        [reqiuredAttentees addObject:txtField.text];
//        [self.tableView reloadData];
//        txtField.text = @"";
//    }
    
    [self performSegueWithIdentifier:@"InviteAtntToSelectAntendeesSegue" sender:nil];

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

- (IBAction)sendInvites:(UIButton *)sender
{
    NSTimeInterval timeIntervel = [newEvent.endDate timeIntervalSinceDate:newEvent.startDate];
    if (timeIntervel < MIN_TIME_SLOT_FOR_SEARCH)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:WARNING_TEXT
                                                            message:ALERT_MSG_MINIMUM_TIME_SLOT_10
                                                           delegate:self
                                                  cancelButtonTitle:OK_FOR_ALERT
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:1];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:index];
    UITextField *txtField = (UITextField*)[cell viewWithTag:100];
    
    newEvent.subject = txtField.text;
    newEvent.requiredAttendees = [reqiuredAttentees valueForKeyPath:@"@distinctUnionOfObjects.emailIDOfContact"];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    newEvent.startDate = [newEvent.startDate dateByAddingTimeInterval:1];
    //First we will check whether the room is booked by some one else while the user enters values;
    [roomManager availablityOfRooms:newEvent.resources forStart:newEvent.startDate toEnd:newEvent.endDate];
}

//
- (void)checkAvailablityOfAttendeesEmailID:(NSArray *)attendeesToCheck
{
    if (!attendeesToCheck.count)
    {
        return;
    }
    
    if (attendeeAvailablityChecker == nil)
    {
        attendeeAvailablityChecker = [[RoomManager alloc] init];
        attendeeAvailablityChecker.delegate = self;
    }
    
    [attendeeAvailablityChecker availablityOfRooms:attendeesToCheck
                                          forStart:newEvent.startDate
                                             toEnd:newEvent.endDate];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)callAutoCompleteForString:(NSString *)subString
{
//    [roomManager getContactsForEntry:subString
//                         withSuccess:^(BOOL foundContacts, NSArray *contactsFound) {
//                             NSLog(@"Found array count %li", contactsFound.count);
//                         }];
}

- (void)startTimeDatePickerValueChange:(UIDatePicker *)picker
{
    self.startDate = [self dateByGettingTimefrom:picker.date withDateFrom:self.startDate];
    dateFormatter.dateFormat = @"hh:mm a";
    startDateString = [dateFormatter stringFromDate:self.startDate];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UILabel *rightLable = (UILabel*)[cell viewWithTag:200];
    rightLable.text = startDateString;
    
    newEvent.startDate = self.startDate;
    NSLog(@"Start Working");
}

- (void)endTimeDatePickerValueChange:(UIDatePicker *)picker
{
    self.endDate = [self dateByGettingTimefrom:picker.date withDateFrom:self.endDate];
    
    dateFormatter.dateFormat = @"hh:mm a";
    endDateString = [dateFormatter stringFromDate:self.endDate];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    UILabel *rightLable = (UILabel*)[cell viewWithTag:200];
    rightLable.text = endDateString;

    newEvent.endDate = self.endDate;

    NSLog(@"End Working");
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
    
    if ([textField isEqual:enterUserNameTextField])
    {
        if (!searchFieldIsSelected)
        {
            searchFieldIsSelected = YES;
            [self.tableView reloadData];
        }
    }
    
    if (selectedTimeIndex)
    {
        NSIndexPath *previousIndex = selectedTimeIndex;
        selectedTimeIndex = nil;
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[previousIndex]
                              withRowAnimation:(UITableViewRowAnimationFade)];
        [self.tableView endUpdates];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if ([textField isEqual:enterUserNameTextField])
    {
        NSMutableString *expectedString = [textField.text mutableCopy];
        [expectedString replaceCharactersInRange:range withString:string];
        
        if (expectedString.length >= 3)
        {
            [self callAutoCompleteForString:expectedString];
        }
    }
    
    return YES;
}

#pragma  mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (searchFieldIsSelected)
    {
        return 1;
    }
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (searchFieldIsSelected)
    {
        return 1;
    }
    
    if (section == 0)
    {
        return [dataOfFirstSection count];
    }else if (section == 1)
    {
        return 1;
    }else
    {
        //first cell in this section is text field to enter the emailIDs
        return ([reqiuredAttentees count] + 1);
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    if (indexPath.section == 0)
    {
        if (self.fromSelectRoomVC & (indexPath.row == 1 | indexPath.row == 2))
        {
            SelectDateTableViewCell *selectedCell = [tableView dequeueReusableCellWithIdentifier:@"TimeSelectCell" forIndexPath:indexPath];
            selectedCell.delegate = self;
            UIDatePicker *datePikcer = selectedCell.datePicker;

            cell = selectedCell;
            cell.layer.masksToBounds = YES;

            if (indexPath.row == 1)
            {
                datePikcer.minimumDate = initialStartDate;
                NSDate *minDate = self.endDate?:initialEndDate;
                datePikcer.maximumDate = [minDate dateByAddingTimeInterval:-MIN_TIME_SLOT_FOR_SEARCH];
                datePikcer.date = self.startDate;

            }else if (indexPath.row == 2)
            {
                datePikcer.minimumDate = [self.startDate dateByAddingTimeInterval:MIN_TIME_SLOT_FOR_SEARCH];
                datePikcer.maximumDate = initialEndDate;
                datePikcer.date = self.endDate;
            }
            if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad)
            {
                [datePikcer removeFromSuperview];
                [cell.contentView addSubview:datePikcer];
                
                NSDictionary *viewsDict = NSDictionaryOfVariableBindings(datePikcer);
                NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-[datePikcer]-|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewsDict];
                [cell.contentView addConstraints:constraints];
                constraints  = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[datePikcer]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:viewsDict];
                
                [cell.contentView addConstraints:constraints];
                [cell.contentView sendSubviewToBack:datePikcer];
                
                UIView *alphaView = [cell viewWithTag:160];
                [cell.contentView sendSubviewToBack:alphaView];
            }
        }else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        }

        UILabel *leftLable = (UILabel*)[cell viewWithTag:100];
        UILabel *rightLable = (UILabel*)[cell viewWithTag:200];
        leftLable.text = dataOfFirstSection[indexPath.row];
        
        switch (indexPath.row)
        {
            case 0:
                rightLable.text = dateForBooking;
                break;
            case 1:
                rightLable.text = startDateString;

                break;
            case 2:
                rightLable.text = endDateString;
                break;
            case 3:
                rightLable.text = userName;
                break;
            case 4:
                rightLable.text = venue;
                break;
            default:
                break;
        }
        
        leftLable.font = [self customFont:16 ofName:MuseoSans_700];
        rightLable.font = [self customFont:16 ofName:MuseoSans_700];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    }else if (indexPath.section == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];

        UITextField *txtField = (UITextField*)[cell viewWithTag:100];
        txtField.delegate = self;
        txtField.placeholder = STRING_FOR_LANGUAGE(@"Subject") ;
        UIButton *btn = (UIButton *)[cell viewWithTag:200];
        btn.hidden = YES;
        txtField.userInteractionEnabled = YES;

        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    }else
    {
        if (indexPath.row == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"AddAttendeesCell" forIndexPath:indexPath];
            UILabel *label = (UILabel *)[cell viewWithTag:100];
            label.text = STRING_FOR_LANGUAGE(@"Add.Attendee");
            
            UIButton *btn = (UIButton *)[cell viewWithTag:200];
            btn.hidden = NO;
            [btn addTarget:self action:@selector(addAttentee:) forControlEvents:(UIControlEventTouchUpInside)];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel *placeHolderLabel = (UILabel *)[cell viewWithTag:300];
            placeHolderLabel.text = STRING_FOR_LANGUAGE(@"Add.Paticipants");
            
            
            if (reqiuredAttentees.count == 0)
            {
                placeHolderLabel.hidden = NO;
            }else
            {
                [placeHolderLabel removeFromSuperview];
            }
        }else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell2" forIndexPath:indexPath];
            UILabel *rightLable = (UILabel*)[cell viewWithTag:100];
            UIImageView *statusImage = (UIImageView *)[cell viewWithTag:200];
            ContactDetails *aContact = reqiuredAttentees[indexPath.row - 1];
            rightLable.text = aContact.displayName;
            rightLable.font = [self customFont:16 ofName:MuseoSans_700];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if (aContact.isChecked)
            {
                if (aContact.isAvailable)
                {
                    statusImage.image = [UIImage imageNamed:@"Sel"];
                }else
                {
                    statusImage.image = [UIImage imageNamed:@"Sel1"];
                }
            }else
            {
                statusImage.image = [UIImage imageNamed:@""];
            }
//            UIImageView *imageView = (UIImageView*)[cell viewWithTag:200];
//            
//            if (indexPath.row == 1)
//            {
//                imageView.image = [UIImage imageNamed:@"Sel1"];
//            }
        }
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 & indexPath.row == 0)
    {
        if (reqiuredAttentees.count != 0)
        {
            return 25;
        }
        return UITableViewAutomaticDimension;
    }
    
    
    if ([indexPath isEqual:selectedTimeIndex])
    {
        return 185;
    }
    return 44;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 2)
    {
        return 0;
    }
    
    return 30;
}

//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
//    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
//    
//    header.textLabel.font = [UIFont boldSystemFontOfSize:14];
//}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (section == 0)
//    {
//        return @"Meeting Details";
//    }else if (section == 1)
//    {
//        return @"Subject";
//    }
//    
//    return nil;
//}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 2)
    {
        return nil;
    }
    UIView *headerView =  [[UIView alloc] initWithFrame:(CGRectMake(0, 0, 150, 30))];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:(CGRectMake(18, 0, 150, 30))];
    headerView.backgroundColor = self.view.backgroundColor;

    headerLabel.font = [UIFont boldSystemFontOfSize:14];
    
    if (section == 0)
    {
        headerLabel.text = STRING_FOR_LANGUAGE(@"Meeting.Details ");
    }else if (section == 1)
    {
        headerLabel.text = STRING_FOR_LANGUAGE(@"Subject");
    }

    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 2 && indexPath.row == 0)
    {
        [self performSegueWithIdentifier:@"InviteAtntToSelectAntendeesSegue" sender:nil];
        return;
    }
    
    if (indexPath.section == 0)
    {
        if (self.fromSelectRoomVC & (indexPath.row == 1 | indexPath.row == 2))
        {
            if (selectedTimeIndex == indexPath)
            {
                selectedTimeIndex = nil;
            }else
            {
                selectedTimeIndex = indexPath;
                
                SelectDateTableViewCell *cell = (SelectDateTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
                UIDatePicker *datePikcer = cell.datePicker;
                
                if (indexPath.row == 1)
                {
                    datePikcer.date = self.startDate;
                    [self startTimeDatePickerValueChange:datePikcer];
                    
                }else if (indexPath.row == 2)
                {
                    datePikcer.date = self.endDate;
                    [self endTimeDatePickerValueChange:datePikcer];
                }
            }
            [tableView beginUpdates];
            [tableView reloadRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:(UITableViewRowAnimationFade)];
            //        [tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
            //                 withRowAnimation:(UITableViewRowAnimationFade)];
            [tableView endUpdates];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && indexPath.row > 0)
    {
        return YES;
    }
    
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [reqiuredAttentees removeObjectAtIndex:indexPath.row-1];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationLeft)];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

#pragma  mark RoomManagerDelegate

- (void)roomManager:(RoomManager *)manager foundAvailableRooms:(NSArray *)availableRooms
{
    if ([manager isEqual:roomManager])
    {
        if (availableRooms.count > 0)
        {
            [roomManager createCalendarEvent:newEvent];
        }else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:STRING_FOR_LANGUAGE(@"not.Book")
                                                                message:ALERT_MSG_ALREADY_BOOKED
                                                               delegate:nil
                                                      cancelButtonTitle:OK_FOR_ALERT
                                                      otherButtonTitles: nil];
            [alertView show];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }

    }else if ([manager isEqual:attendeeAvailablityChecker])
    {
        for (ContactDetails *aContact in reqiuredAttentees)
        {
            //if the user name is already checked we should not consider that
            if (!aContact.isChecked)
            {
                aContact.isAvailable = [availableRooms containsObject:aContact.emailIDOfContact];
                aContact.isChecked = YES;
            }
        }
        
        [self.tableView reloadData];
    }
}

- (void)roomManager:(RoomManager *)manager createdRoomWith:(NSString *)eventID
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    if (successfullAlert == nil)
    {
        successfullAlert = [[UIAlertView alloc] initWithTitle:STRING_FOR_LANGUAGE(@"Booked")
                                                      message:ALERT_MSG_SUCCESSFULL_BOOKING
                                                     delegate:self
                                            cancelButtonTitle:OK_FOR_ALERT
                                            otherButtonTitles: nil];
    }
    
    [successfullAlert show];
}

- (void)roomManager:(RoomManager *)manager failedWithError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

#pragma  mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView isEqual:successfullAlert])
    {
        if (!self.fromSelectRoomVC)
        {
            NSArray *viewControllers = self.navigationController.viewControllers;
            RoomFinderViewController *roomFinderVC = (RoomFinderViewController *)viewControllers[viewControllers.count-2];
            [roomFinderVC resetToInitialState];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}



#pragma  mark AddAttendeesDelegate
- (void)addAntendees:(NSArray *)attendees
{
    for (ContactDetails *aContact in attendees)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"emailIDOfContact == %@", aContact.emailIDOfContact];
        NSArray *filtered = [reqiuredAttentees filteredArrayUsingPredicate:predicate];
        
        if (filtered.count == 0)
        {
            if (reqiuredAttentees == nil)
            {
                reqiuredAttentees = [[NSMutableArray alloc] init];
            }
            [reqiuredAttentees insertObject:aContact atIndex:0];
        }
    }
    [self checkAvailablityOfAttendeesEmailID:[attendees valueForKeyPath:@"@distinctUnionOfObjects.emailIDOfContact"]];
    [self.tableView reloadData];
}

#pragma mark - SelectDateCellDelegate
- (void)selectedCell:(SelectDateTableViewCell *)cell timeChanged:(UIDatePicker *)datePicker
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if (indexPath.row == 1)
    {
        [self startTimeDatePickerValueChange:datePicker];
    }else if (indexPath.row == 2)
    {
        [self endTimeDatePickerValueChange:datePicker];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"InviteAtntToSelectAntendeesSegue"])
    {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        AddAttendeesViewController *addAttendeesVC = [navController.viewControllers firstObject];
        addAttendeesVC.delegate = self;
    }
}


@end
