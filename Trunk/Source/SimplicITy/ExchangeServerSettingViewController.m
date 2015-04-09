//
//  ExchangeServerSettingViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 27/03/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "ExchangeServerSettingViewController.h"
#import "OfficeLocationsViewController.h"
#import "DBManager.h"
#import "OfficeLocation.h"

@interface ExchangeServerSettingViewController ()<UITableViewDataSource,UITableViewDelegate,OfficeLocationDelegate, DBManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableViewOutLet;

@end

@implementation ExchangeServerSettingViewController
{
    DBManager *dbManager;
    NSString *selectedCountryName, *selectedOfficeLocationName;
    
    NSArray *officesOfSelectedCountry;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Book a room";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    selectedCountryName = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_LOCATION_NAME];
    selectedOfficeLocationName = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_OFFICE_NAME];
    
    [self getData];
    
    [self.tableViewOutLet reloadData];
}

- (IBAction)ewsSettingssChanged:(UIBarButtonItem *)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    UITableViewCell *userNameCell = [self.tableViewOutLet cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
//    UITextField *textFld = (UITextField*)[userNameCell viewWithTag:100];
//
//    [userDefaults setObject:textFld.text forKey:EWS_USER_NAME];
    
    UITableViewCell *passwordCell = [self.tableViewOutLet cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    UITextField *textFld = (UITextField*)[passwordCell viewWithTag:100];
    
    [userDefaults setObject:textFld.text forKey:EWS_USERS_PASSWORD];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Successfully updated" message:@"Password is updated" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

- (void)getData
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate=self;
    }
    
    NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM officeLocations WHERE API = '%@'", SEARCH_OFFICE_API];
    [dbManager getDataForQuery:queryString];
}



- (NSArray *)parseResponse:(NSData *)response
{
    NSMutableArray *arrayOfFilteredLocation = [[NSMutableArray alloc] init];
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    NSArray *arr = json[@"aaData"][@"office"];
    
    for (NSDictionary *anOffice in arr)
    {
        if ([anOffice[@"Status"] boolValue])
        {
            if ([anOffice[@"Country"] isEqualToString:selectedCountryName])
            {
                NSDictionary *dictFromJSON = [NSJSONSerialization JSONObjectWithData:[anOffice[@"JSON"] dataUsingEncoding:NSUTF8StringEncoding]
                                                                             options:kNilOptions
                                                                               error:nil];
                
                OfficeLocation *office = [[OfficeLocation alloc] init];
                office.nameOfOffice = dictFromJSON[@"Distribution"][@"Name"];
                office.emailIDOfOffice = dictFromJSON[@"Distribution"][@"EmailID"];
                office.officeCode = anOffice[@"Code"];
                
                [arrayOfFilteredLocation addObject:office];

            }
        }
    }
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"nameOfOffice" ascending:YES];
    arrayOfFilteredLocation = [[arrayOfFilteredLocation sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
    
    return arrayOfFilteredLocation;
}


#pragma mark DBManagerDelegate
- (void)DBManager:(DBManager *)manager gotSqliteStatment:(sqlite3_stmt *)statment
{
    if (sqlite3_step(statment) == SQLITE_ROW)
    {
        NSString *string = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 1)];
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        
        officesOfSelectedCountry = [self parseResponse:data];
    }
}

#pragma  mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        
        UILabel *rightLable = (UILabel*)[cell viewWithTag:100];
        UILabel *leftLable = (UILabel*)[cell viewWithTag:200];

        rightLable.font = [self customFont:16 ofName:MuseoSans_700];
        leftLable.font = [self customFont:16 ofName:MuseoSans_700];
        
        if (indexPath.row == 0)
        {
            rightLable.text = @"Location";
            leftLable.text = selectedOfficeLocationName?: @"Select Location";
            
        }
//        else
//        {
//            rightLable.text = @"URL";
//            leftLable.text = EWS_REQUSET_URL;
//            cell.accessoryType = UITableViewCellAccessoryNone;
//        }
        
    }else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];
        
        UITextField *textFld = (UITextField*)[cell viewWithTag:100];
        
        textFld.font = [self customFont:16 ofName:MuseoSans_700];
        
        if (indexPath.row == 0)
        {
//            textFld.placeholder = @"Username";
//            textFld.text = [[NSUserDefaults standardUserDefaults] objectForKey:EWS_USER_NAME]?: @"";
//            textFld.secureTextEntry = NO;
//
//        }else
//        {
            textFld.placeholder = @"Password";
            textFld.text = [[NSUserDefaults standardUserDefaults] objectForKey:EWS_USERS_PASSWORD]?: @"";
            textFld.secureTextEntry = YES;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            [self performSegueWithIdentifier:@"exchageToOfficeLocationSegue" sender:self];
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (section == 1)
//    {
//        return @"Password";
//    }
//    return nil;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView =  [[UIView alloc] initWithFrame:(CGRectMake(0, 0, 150, 30))];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:(CGRectMake(18, 0, 150, 30))];
    
    headerLabel.font = [UIFont boldSystemFontOfSize:14];
    
    if (section == 0)
    {
        headerLabel.text = @"Office Location";
    }else if (section == 1)
    {
        headerLabel.text = @"Password";
    }
    
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UINavigationController *navigation = segue.destinationViewController;
    OfficeLocationsViewController *officeVC = navigation.viewControllers[0];
    officeVC.officesArray = officesOfSelectedCountry;
    officeVC.delegate = self;
}


- (void)selectedOfficeIs:(NSString *)location
{
    UITableViewCell *cell = [self.tableViewOutLet cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UILabel *leftLable = (UILabel*)[cell viewWithTag:200];
    leftLable.text = location;
}

@end
