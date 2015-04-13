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
    
    __block NSArray *contactsFoundArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:tapGesture];
    
    roomManager = [[RoomManager alloc] init];
    roomManager.delegate = self;
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
    [roomManager getContactsForEntry:subString
                         withSuccess:^(BOOL foundContacts, NSArray *contactsFound) {
                             
                             isCallingAutoComplete = NO;
                             NSLog(@"Found array count %li", contactsFound.count);
                             
                             contactsFoundArray = [contactsFound copy];
                             [self.tableView reloadData];
                         }];
}

#pragma  mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:self.searchUserNameTextField])
    {
        NSMutableString *expectedString = [textField.text mutableCopy];
        [expectedString replaceCharactersInRange:range withString:string];
        
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
        return 0;
        
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
    
    ContactDetails *aContact = contactsFoundArray[indexPath.row];
    nameLabel.text = aContact.nameOfContact;
    emailIDLabel.text = aContact.emailIDOfContact;
    
    return cell;
}

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
