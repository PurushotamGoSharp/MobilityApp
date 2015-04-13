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

@interface InviteAttendeesViewController ()<UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate, RoomManagerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation InviteAttendeesViewController
{
    __weak IBOutlet UIButton *sendInviteButton;
    NSArray *dataOfFirstSection;
    NSArray *dataOfThirdSection;
    NSMutableArray *reqiuredAttentees;

    NSString *dateForBooking;
    NSString *startDateString, *endDateString;
    NSDateFormatter *dateFormatter;
    
    NSString *userName;
    NSString *venue;
    
    RoomManager *roomManager;
    CalendarEvent *newEvent;
    
    UITextField *activeField;
    UITextField *enterUserNameTextField;
    UIAlertView *successfullAlert;
    
    UIBarButtonItem *backButton;
    
    BOOL searchFieldIsSelected;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Invite Attendees";
    
    dataOfFirstSection = @[@"Date",@"Start",@"End",@"Organizer",@"Venue"];
    dataOfThirdSection = @[@"",@"Marc",@"Bin",@"Antony",@"Sundar"];

    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"EEEE dd MMMM yyyy";
    dateForBooking = [dateFormatter stringFromDate:self.startDate];
    
    dateFormatter.dateFormat = @"hh.mm a";
    startDateString = [dateFormatter stringFromDate:self.startDate];
    endDateString = [dateFormatter stringFromDate:self.endDate];
    
    userName = [UserInfo sharedUserInfo].fullName;
    venue = self.selectedRoom.nameOfRoom;
    
    sendInviteButton.layer.cornerRadius = 5;
    sendInviteButton.titleLabel.font = [self customFont:16 ofName:MuseoSans_700];

    roomManager = [[RoomManager alloc] init];
    roomManager.delegate = self;
    newEvent = [[CalendarEvent alloc] init];
    
    newEvent.startDate = self.startDate;
    newEvent.endDate = self.endDate;
    newEvent.location = self.selectedRoom.nameOfRoom;
    newEvent.resources = @[self.selectedRoom.emailIDOfRoom];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGesture];
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setImage:[UIImage imageNamed:@"back_Arrow"] forState:UIControlStateNormal];
    [back setTitle:@"Back" forState:UIControlStateNormal];
    back.titleLabel.font = [self customFont:16 ofName:MuseoSans_700];
    back.imageEdgeInsets = UIEdgeInsetsMake(0, -45, 0, 0);
    back.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
    back.frame = CGRectMake(0, 0,80, 30);
    [back setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    
    [back  addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    backButton = [[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = backButton;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotifications];
    
//    if (successfullAlert == nil)
//    {
//        successfullAlert = [[UIAlertView alloc] initWithTitle:@"Room is booked"
//                                                      message:@"Successfully room is booked"
//                                                     delegate:self
//                                            cancelButtonTitle:@"OK"
//                                            otherButtonTitles: nil];
//    }
//    
//    [successfullAlert show];
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


- (void)backBtnAction
{
    NSArray *viewControllers = self.navigationController.viewControllers;
    RoomFinderViewController *roomFinderVC = (RoomFinderViewController *)viewControllers[viewControllers.count-2];
    [roomFinderVC refershAvailableRooms];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)hideKeyboard
{
    [self.view endEditing:YES];
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

- (void)addAttentee:(UIButton *)sender
{
    if (reqiuredAttentees == nil)
    {
        reqiuredAttentees = [[NSMutableArray alloc] init];
    }
    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:2];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:index];
    UITextField *txtField = (UITextField*)[cell viewWithTag:100];
    
    if (txtField.text.length > 0)
    {
        [reqiuredAttentees addObject:txtField.text];
        [self.tableView reloadData];
        txtField.text = @"";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)callAutoCompleteForString:(NSString *)subString
{
    [roomManager getContactsForEntry:subString
                         withSuccess:^(BOOL foundContacts, NSArray *contactsFound) {
                             NSLog(@"Found array count %li", contactsFound.count);
                         }];
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

//    if (searchFieldIsSelected)
//    {
//        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];
//        UITextField *txtField = (UITextField*)[cell viewWithTag:100];
//        txtField.delegate = self;
//        txtField.placeholder = @"Enter Email";
//        txtField.keyboardType = UIKeyboardTypeEmailAddress;
//        enterUserNameTextField = txtField;
//        UIButton *btn = (UIButton *)[cell viewWithTag:200];
//        btn.hidden = NO;
//        [btn addTarget:self action:@selector(addAttentee:) forControlEvents:(UIControlEventTouchUpInside)];
//        [txtField becomeFirstResponder];
//        
//        return cell;
//    }
    
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

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
        txtField.placeholder = @"Subject";
        UIButton *btn = (UIButton *)[cell viewWithTag:200];
        btn.hidden = YES;
        txtField.userInteractionEnabled = YES;

        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    }else
    {
        if (indexPath.row == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];
            UITextField *txtField = (UITextField*)[cell viewWithTag:100];
            txtField.delegate = self;
            txtField.placeholder = @"Select Anttendees";
            txtField.keyboardType = UIKeyboardTypeEmailAddress;
            txtField.userInteractionEnabled = NO;
            enterUserNameTextField = txtField;
            UIButton *btn = (UIButton *)[cell viewWithTag:200];
            btn.hidden = NO;
            [btn addTarget:self action:@selector(addAttentee:) forControlEvents:(UIControlEventTouchUpInside)];
            
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;

        }else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell2" forIndexPath:indexPath];
            UILabel *rightLable = (UILabel*)[cell viewWithTag:100];
            rightLable.text = reqiuredAttentees[indexPath.row - 1];
            rightLable.font = [self customFont:16 ofName:MuseoSans_700];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

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
    return 44;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView =  [[UIView alloc] initWithFrame:(CGRectMake(0, 0, 150, 30))];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:(CGRectMake(18, 0, 150, 30))];
    
    headerLabel.font = [UIFont boldSystemFontOfSize:14];
    
    if (searchFieldIsSelected)
    {
        headerLabel.text = @"Add attendees";
    }else
    {
        if (section == 0)
        {
            headerLabel.text = @"Meeting Details";
        }else if (section == 1)
        {
            headerLabel.text = @"Subject";
        }else if (section == 2)
        {
            headerLabel.text = @"Add attendees";
        }
    }
    
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && indexPath.row == 0)
    {
        [self performSegueWithIdentifier:@"InviteAtntToSelectAntendeesSegue" sender:nil];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (IBAction)sendInvites:(UIButton *)sender
{
    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:1];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:index];
    UITextField *txtField = (UITextField*)[cell viewWithTag:100];
    
    newEvent.subject = txtField.text;
    newEvent.requiredAttendees = reqiuredAttentees;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
//First we will check whether the room is booked by some one else while the user enters values;
    [roomManager availablityOfRooms:newEvent.resources forStart:newEvent.startDate toEnd:newEvent.endDate];
}

#pragma  mark RoomManagerDelegate

- (void)roomManager:(RoomManager *)manager foundAvailableRooms:(NSArray *)availableRooms
{
    if (availableRooms.count > 0)
    {
        [roomManager createCalendarEvent:newEvent];
        
    }else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Not Booked"
                                                            message:@"Sorry! Meeting Room already booked by someone else recently."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }

}

- (void)roomManager:(RoomManager *)manager createdRoomWith:(NSString *)eventID
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    if (successfullAlert == nil)
    {
        successfullAlert = [[UIAlertView alloc] initWithTitle:@"Booked"
                                                      message:@"Successfully booked the Meeting Room."
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
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
        NSArray *viewControllers = self.navigationController.viewControllers;
        RoomFinderViewController *roomFinderVC = (RoomFinderViewController *)viewControllers[viewControllers.count-2];
        [roomFinderVC resetToInitialState];
        [self.navigationController popViewControllerAnimated:YES];
    }
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
