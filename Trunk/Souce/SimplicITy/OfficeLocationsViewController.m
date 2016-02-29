//
//  OfficeLocationsViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 4/1/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "OfficeLocationsViewController.h"
#import "OfficeLocation.h"

@interface OfficeLocationsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation OfficeLocationsViewController
{
    NSInteger selectedRow;
    
    NSString *selectedLocationMailID;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    selectedLocationMailID = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_OFFICE_MAILID];
    selectedRow = -1;
    [self.tableView reloadData];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localize) name:MCLocalizationLanguageDidChangeNotification object:nil];
    [self localize];
    

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)localize
{
    self.title = STRING_FOR_LANGUAGE(@"Location.Setting");
    [self.navigationItem.rightBarButtonItem setTitle:STRING_FOR_LANGUAGE(@"Done")];
    [self.navigationItem.leftBarButtonItem setTitle:STRING_FOR_LANGUAGE(@"Cancel")];
    
    
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
        OfficeLocation *locatoin = self.officesArray[[self.tableView indexPathForSelectedRow].row];
        
        [[NSUserDefaults standardUserDefaults] setObject:locatoin.emailIDOfOffice forKey:SELECTED_OFFICE_MAILID];
        [[NSUserDefaults standardUserDefaults] setObject:locatoin.nameOfOffice forKey:SELECTED_OFFICE_NAME];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.delegate selectedOfficeIs:locatoin.nameOfOffice];
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.officesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    OfficeLocation *locatoin = self.officesArray[indexPath.row];
    
    UILabel *label = (UILabel *)[cell viewWithTag:100];
    label.text = locatoin.nameOfOffice;
    
    label.font=[self customFont:16 ofName:MuseoSans_700];
    label.highlightedTextColor = [UIColor whiteColor];

    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [self barColorForIndex:selectedRow];
    [cell setSelectedBackgroundView:bgColorView];
    
    if ([locatoin.emailIDOfOffice isEqualToString:selectedLocationMailID])
    {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:(UITableViewScrollPositionNone)];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRow = indexPath.row;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
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
