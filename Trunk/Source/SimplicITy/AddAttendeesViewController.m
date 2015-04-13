//
//  AddAttendeesViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 4/13/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "AddAttendeesViewController.h"
#import "RoomManager.h"
#import "ContactDetails.h"

@interface AddAttendeesViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, RoomManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchUserNameTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation AddAttendeesViewController
{
    RoomManager *roomManager;
    BOOL isCallingAutoComplete;
    BOOL canStopCallingAPI;
    __block NSArray *referenceArray;
    NSArray *contactsFoundArray;
    NSMutableArray *selectedAttentdees;
    
    NSString *lastSubStringThatIsSearched;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGesture];
    
    roomManager = [[RoomManager alloc] init];
    roomManager.delegate = self;
    
    selectedAttentdees = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideKeyboard
{
    [self.view endEditing:YES];
}

- (void)callAutoCompleteForString:(NSString *)subString
{
    isCallingAutoComplete = YES;
    lastSubStringThatIsSearched = subString;
    [roomManager getContactsForEntry:subString
                         withSuccess:^(BOOL foundContacts, NSArray *contactsFound) {
                             
                             isCallingAutoComplete = NO;
//                             NSLog(@"Found array count %li", contactsFound.count);
//  //From API call maximum  of 100 contacts will be returned. So what we can do is if number of contacts reutruned is less than 100 we can STOP CALLING API. Because there will not be more than 100 for that sub-string. And when user presses back button we have to start calling API.
//                             if (contactsFound.count < 100)
//                             {
//                                 canStopCallingAPI = YES;
//                             }else
//                             {
//                                 canStopCallingAPI = NO;
//                                 if (!isCallingAutoComplete)
//                                 {
//  //If substring that is searched is having more than 100 results, then API will be called again with same SUBSTRING. So it will form a loop. So break that loop, we will not make the call if last substring is equal to Current substring
//                                     if (![lastSubStringThatIsSearched isEqualToString:self.searchUserNameTextField.text])
//                                     {
//                                         [self callAutoCompleteForString:self.searchUserNameTextField.text];
//                                     }
//                                 }
//                             }
                             
                             
                             if (![lastSubStringThatIsSearched isEqualToString:self.searchUserNameTextField.text])
                             {
                                 [self callAutoCompleteForString:self.searchUserNameTextField.text];
                             }
                             
                             referenceArray = contactsFound;
                             contactsFoundArray = [self filterContacts:contactsFound forString:self.searchUserNameTextField.text];
                             [self.tableView reloadData];
                         }];
}

- (NSArray *)filterContacts:(NSArray *)arrayOfContacts forString:(NSString *)searchString
{
    if (searchString.length < 3)
    {
        return nil;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nameOfContact CONTAINS[cd] %@ OR emailIDOfContact CONTAINS[cd] %@ OR  displayName CONTAINS[cd] %@", searchString, searchString, searchString];
    NSArray *filteredArray = [arrayOfContacts filteredArrayUsingPredicate:predicate];
    
    return filteredArray;
}

- (IBAction)addEmailIDDirectly:(UIButton *)sender
{
    if ([self validateEmail:self.searchUserNameTextField.text])
    {
        ContactDetails *aContact = [[ContactDetails alloc] init];
        aContact.emailIDOfContact = self.searchUserNameTextField.text;
        aContact.displayName = self.searchUserNameTextField.text;
        
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        [selectedAttentdees addObject:aContact];
        [self.tableView endUpdates];
        
        self.searchUserNameTextField.text = @"";
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"Please give a valid Email ID."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}


- (BOOL)validateEmail:(NSString *) candidate
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

#pragma  mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:self.searchUserNameTextField])
    {
        NSMutableString *expectedString = [textField.text mutableCopy];
        [expectedString replaceCharactersInRange:range withString:string];
        
//        if (expectedString.length >= 3 && !isCallingAutoComplete && !canStopCallingAPI)
//        {
//            [self callAutoCompleteForString:expectedString];
//        }else
//        {
//            contactsFoundArray = [self filterContacts:referenceArray forString:expectedString];
//            [self.tableView reloadData];
//            
//        }
//        
//        if (expectedString.length < 3)
//        {
//            canStopCallingAPI = NO;
//        }
        
        if (expectedString.length >= 3 && !isCallingAutoComplete)
        {
            isCallingAutoComplete = YES;
            [self callAutoCompleteForString:expectedString];
        }
    }
    
    return YES;
}

#pragma  mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return selectedAttentdees.count;
        
    }else if (section == 1)
    {
        return 0;
    }
    
    return contactsFoundArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *emailIDLabel = (UILabel *)[cell viewWithTag:101];
    
    ContactDetails *aContact;
    if (indexPath.section == 0)
    {
        aContact = selectedAttentdees[indexPath.row];
        
    }else if (indexPath.section == 2)
    {
        aContact = contactsFoundArray[indexPath.row];
    }
    nameLabel.text = aContact.displayName;
    emailIDLabel.text = aContact.emailIDOfContact;
    
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView =  [[UIView alloc] initWithFrame:(CGRectMake(0, 0, 150, 30))];
    headerView.backgroundColor = [self subViewsColours];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:(CGRectMake(18, 0, 150, 30))];
    
    headerLabel.font = [UIFont boldSystemFontOfSize:14];
    
    {
        if (section == 0)
        {
            if (selectedAttentdees.count == 0)
            {
                return nil;
            }
            headerLabel.text = @"Selected Antendees";
        }else if (section == 1)
        {
            return nil;
        }else if (section == 2)
        {
            headerLabel.text = @"Found Contacts";
        }
    }
    
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        if (selectedAttentdees.count == 0)
        {
            return 0;
        }
        return 30;
    }
    if (section == 2)
    {
        return 30;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2)
    {
        if (![selectedAttentdees containsObject:contactsFoundArray[indexPath.row]])
        {
            [self.tableView beginUpdates];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            [selectedAttentdees addObject:contactsFoundArray[indexPath.row]];
            [self.tableView endUpdates];
            
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma  mark RoomManagerDelegate

- (void)roomManager:(RoomManager *)manager failedWithError:(NSError *)error
{
    isCallingAutoComplete = NO;
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
