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

//#define ALERT_MSG_GIVE_VALID_EMAILID @"Please give a valid Email ID."

@interface AddAttendeesViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, RoomManagerDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchUserNameTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation AddAttendeesViewController
{
    RoomManager *roomManager;
    BOOL isCallingAutoComplete;
    BOOL canStopCallingAPI;
    __block NSArray *referenceArray;
    __block NSArray *contactsFoundArray;
    NSMutableArray *selectedAttentdees;
    
    NSString *lastSubStringThatIsSearched;
    NSString *noResultsLastSubString;



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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localize) name:MCLocalizationLanguageDidChangeNotification object:nil];
    [self localize];
    

    
    [self.searchUserNameTextField becomeFirstResponder];
    self.searchUserNameTextField.placeholder = STRING_FOR_LANGUAGE(@"Type.Name");


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)localize{
   
    
    self.title = STRING_FOR_LANGUAGE(@"Add.Attendee");
    [self.navigationItem.rightBarButtonItem setTitle:STRING_FOR_LANGUAGE(@"Done")];
    [self.navigationItem.leftBarButtonItem setTitle:STRING_FOR_LANGUAGE(@"Cancel")];
    
    
}




- (void)hideKeyboard
{
    [self.view endEditing:YES];
}

- (void)callAutoCompleteForString:(NSString *)subString
{
    isCallingAutoComplete = YES;
    lastSubStringThatIsSearched = subString;
//    [roomManager getContactsForEntry:subString
//                         withSuccess:^(BOOL foundContacts, NSArray *contactsFound) {
//                             
//                             isCallingAutoComplete = NO;
////                             NSLog(@"Found array count %li", contactsFound.count);
////  //From API call maximum  of 100 contacts will be returned. So what we can do is if number of contacts reutruned is less than 100 we can STOP CALLING API. Because there will not be more than 100 for that sub-string. And when user presses back button we have to start calling API.
////                             if (contactsFound.count < 100)
////                             {
////                                 canStopCallingAPI = YES;
////                             }else
////                             {
////                                 canStopCallingAPI = NO;
////                                 if (!isCallingAutoComplete)
////                                 {
////  //If substring that is searched is having more than 100 results, then API will be called again with same SUBSTRING. So it will form a loop. So break that loop, we will not make the call if last substring is equal to Current substring
////                                     if (![lastSubStringThatIsSearched isEqualToString:self.searchUserNameTextField.text])
////                                     {
////                                         [self callAutoCompleteForString:self.searchUserNameTextField.text];
////                                     }
////                                 }
////                             }
//                             
//                             referenceArray = [contactsFound copy];
////                             contactsFoundArray = [self filterContacts:contactsFound forString:self.searchUserNameTextField.text];
//                             contactsFoundArray = [contactsFound copy];
//                             [self.tableView reloadData];
//                             
//                             if (![lastSubStringThatIsSearched isEqualToString:self.searchUserNameTextField.text])
//                             {
//                                 [self callAutoCompleteForString:self.searchUserNameTextField.text];
//                             }
//                         }];
    
    [roomManager getContactsForEntry:subString];
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
        
        isCallingAutoComplete = NO;

        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        [selectedAttentdees addObject:aContact];
        [self.tableView endUpdates];
        
        self.searchUserNameTextField.text = @"";
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:WARNING_TEXT
                                                        message:ALERT_MSG_GIVE_VALID_EMAILID
                                                       delegate:nil
                                              cancelButtonTitle:OK_FOR_ALERT
                                              otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)doneButtonPressed:(UIBarButtonItem *)sender
{
    [self hideKeyboard];
    if (selectedAttentdees.count > 0)
    {
        [self.delegate addAntendees:selectedAttentdees];
    }
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 
                             }];
}

- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender
{
    [self hideKeyboard];
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 
                             }];
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
        
        
        //if a string is not having no results, antoher string that has the first string as PREFIX will also not have any results. [eg) First string = VARGH and it does not have any results, then VARGHESE also will not have any results]
        noResultsLastSubString = noResultsLastSubString?:@"";

        if (![expectedString hasPrefix:noResultsLastSubString])
        {
            if (expectedString.length >= 3 && !isCallingAutoComplete)
            {
                [self callAutoCompleteForString:expectedString];
            }
            
            if (expectedString.length < 3)
            {
                contactsFoundArray = nil;
            }

        }
        [self.tableView reloadData];
    }
    
    return YES;
}


- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    contactsFoundArray = nil;
    [self.tableView reloadData];
   
    return YES;
}
#pragma  mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1)
    {
        return selectedAttentdees.count;
        
    }else if (section == 0)
    {
        if (isCallingAutoComplete)
        {
            return 1;
        }

        return 0;
    }
    
    return contactsFoundArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (isCallingAutoComplete & (indexPath.row == 0) & (indexPath.section == 0))
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"indicatorCell" forIndexPath:indexPath];
        UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[cell viewWithTag:300];
        [indicator startAnimating];
        return cell;
    }else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    }

    UILabel *nameLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *emailIDLabel = (UILabel *)[cell viewWithTag:101];
    
    ContactDetails *aContact;
    if (indexPath.section == 1)
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

//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
//    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
//    
//    header.textLabel.font = [UIFont boldSystemFontOfSize:14];
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (section == 1)
//    {
//        if (selectedAttentdees.count == 0)
//        {
//            return nil;
//        }
//        return @"Selected Attendees";
//    }else if (section == 2)
//    {
//        if (contactsFoundArray.count == 0)
//        {
//            return nil;
//        }
//        return @"Contacts Found";
//    }
//    
//    return nil;
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView =  [[UIView alloc] initWithFrame:(CGRectMake(0, 0, 150, 30))];
    headerView.backgroundColor = self.view.backgroundColor;
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:(CGRectMake(18, 5, 150, 30))];
    
    headerLabel.font = [UIFont boldSystemFontOfSize:14];
    
    {
        if (section == 1)
        {
            if (selectedAttentdees.count == 0)
            {
                return nil;
            }
            headerLabel.text = STRING_FOR_LANGUAGE(@"Selected.Attendee");
            [headerLabel sizeToFit];
        }else if (section == 0)
        {
            return nil;
        }else if (section == 2)
        {
            if (contactsFoundArray.count == 0)
            {
                return nil;
            }
            headerLabel.text = STRING_FOR_LANGUAGE(@"Contact.Found ");
           [headerLabel sizeToFit];
        }
    }
    
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        if (selectedAttentdees.count == 0)
        {
            return 0;
        }
        return 30;
        
    }else if (section == 2)
    {
        if (contactsFoundArray.count == 0)
        {
            return 0;
        }
        
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
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
            [selectedAttentdees addObject:contactsFoundArray[indexPath.row]];
            [self.tableView endUpdates];
            self.searchUserNameTextField.text = @"";
            contactsFoundArray = nil;
            [self.tableView reloadData];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isCallingAutoComplete & (indexPath.row == 0) & (indexPath.section == 0))
    {
        return 30;
    }
    return 47;
}

#pragma  mark RoomManagerDelegate

- (void)roomManager:(RoomManager *)manager failedWithError:(NSError *)error
{
    NSLog(@"Error from manager");
    isCallingAutoComplete = NO;
    [self.tableView reloadData];
}

- (void)roomManager:(RoomManager *)manager successfullYGotContacts:(NSArray *)foundContacts
{
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
    
    referenceArray = foundContacts;
    //                             contactsFoundArray = [self filterContacts:contactsFound forString:self.searchUserNameTextField.text];
    contactsFoundArray = foundContacts;
    
    noResultsLastSubString = @"";

    if (foundContacts.count == 0)
    {
        noResultsLastSubString = lastSubStringThatIsSearched;
    }else
    {
        noResultsLastSubString = @"";
    }
    
    NSString *subStringToSearch = self.searchUserNameTextField.text;
    
 //if a string is not having no results, antoher string that has the first string as PREFIX will also not have any results. [eg) First string = VARGH and it does not have any results, then VARGHESE also will not have any results]
    if (![subStringToSearch hasPrefix:noResultsLastSubString])
    {
        if (![lastSubStringThatIsSearched isEqualToString:subStringToSearch])
        {
            if (subStringToSearch.length >= 3)
            {
                [self callAutoCompleteForString:subStringToSearch];
            }else
            {
                contactsFoundArray = nil;
            }
        }
    }

    [self.tableView reloadData];
}

#pragma  mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
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
