//
//  LocationViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 11/12/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "LocationViewController.h"
#import "DBManager.h"
#import "LocationModel.h"


@interface LocationViewController ()<UITableViewDataSource,UITableViewDelegate,DBManagerDelegate>
{
    NSMutableArray *arrOfLocationData;
    UILabel *titleLable;
    NSInteger selectedRow;
    DBManager *dbManager;

    __weak IBOutlet UIBarButtonItem *locationCancleButton;

    __weak IBOutlet UIBarButtonItem *locationDoneButton;

}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    arrOfLocationData = @[@"Belgium",@"India",@"US",@"Japan",@"Bulgaria",@"France",@"Germany"];
    
    arrOfLocationData = [[NSMutableArray alloc] init];
    
    [self getAllLocationData];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    selectedRow = -1;
    

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localize) name:MCLocalizationLanguageDidChangeNotification object:nil];
    [self localize];

}

-(void)localize
{
    
    [self.navigationItem.rightBarButtonItem setTitle:STRING_FOR_LANGUAGE(@"Done")];
    [self.navigationItem.leftBarButtonItem setTitle:STRING_FOR_LANGUAGE(@"Cancel")];
     self.title = STRING_FOR_LANGUAGE(@"Country");



}







- (void)getAllLocationData
{
    
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate=self;
    }
    
//    NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM location WHERE countryCode = '%@'", countryCode];
    
        NSString *queryString = @"SELECT * FROM location ORDER BY countryName ASC";
    
    
    if (![dbManager getDataForQuery:queryString])
    {
        if (![AFNetworkReachabilityManager sharedManager].reachable)
        {
            UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:WARNING_TEXT message:INTERNET_IS_REQUIRED_TO_SYNC_DATA delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [noNetworkAlert show];
        }
    }
    
}

- (void)DBManager:(DBManager *)manager gotSqliteStatment:(sqlite3_stmt *)statment
{
    while (sqlite3_step(statment) == SQLITE_ROW)
    {
    
        LocationModel *anLocation = [[LocationModel alloc] init];
        anLocation.countryCode = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 0)];
        
        NSString *JSONString = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 1)];
        anLocation.serviceDeskNumber = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding]
                                                                             options:kNilOptions
                                                                               error:nil];
        
        anLocation.countryName = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 2)];
        anLocation.code = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 3)];
        
        [arrOfLocationData addObject:anLocation];
    }
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"countryName" ascending:YES];
    arrOfLocationData = [[arrOfLocationData sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
    
    [self.tableView reloadData];
}

- (IBAction)CalcelBtnPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];

}
- (IBAction)doneBtnPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (selectedRow >= 0)
    {
        LocationModel *location = arrOfLocationData[[self.tableView indexPathForSelectedRow].row ];
        
        [[NSUserDefaults standardUserDefaults] setObject:location.countryCode forKey:SELECTED_LOCATION_CODE];
        [[NSUserDefaults standardUserDefaults] setObject:location.countryName forKey:SELECTED_LOCATION_NAME];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.delegate selectedLocationIs:location.countryName];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrOfLocationData count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
  
    titleLable = (UILabel *)[cell viewWithTag:100];
    
    titleLable.font=[self customFont:16 ofName:MuseoSans_700];
    
//    titleLable.text = arrOfLocationData[indexPath.row];
    
    LocationModel *location = arrOfLocationData[indexPath.row];
    titleLable.text = location.countryName;
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [self barColorForIndex:selectedRow];
    [cell setSelectedBackgroundView:bgColorView];
    

    titleLable.highlightedTextColor = [UIColor whiteColor];
    
    if ([location.countryCode isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_LOCATION_CODE]])
    {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:(UITableViewScrollPositionNone)];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
#pragma mark UITableViewDelegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRow = indexPath.row;

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
