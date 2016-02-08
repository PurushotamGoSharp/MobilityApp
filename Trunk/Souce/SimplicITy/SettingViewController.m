//
//  SettingViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 10/12/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "SettingViewController.h"
#import "LanguageViewController.h"
#import "LocationViewController.h"
#import "ThemesViewController.h"
#import "LanguageModel.h"
#import "OfficeLocationsViewController.h"
#import "DBManager.h"
#import "OfficeLocation.h"

@interface SettingViewController ()<UITableViewDataSource,UITableViewDelegate,languagesSettingdelegate,LocationSettingdelegate,ThemeSettingDelegate, OfficeLocationDelegate, DBManagerDelegate>
{
   NSArray  *arrOfTableViewData, *arrOfImages ;
    NSInteger selectedRow;
    UIBarButtonItem *backButton;
    
    NSArray *arrOfLocationData, *arrOfLanguageData, *officesOfSelectedCountry;
    NSString *selectedLanaguage;
    
    NSString *selectedLocationName;
    NSString *selectedCountryName, *selectedOfficeLocationName;

    DBManager *dbManager;
    UIButton *back;

}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Settings";
    
    //arrOfTableViewData = @[@"Language", @"Country", @"Office Location", @"Theme"];
    arrOfImages = @[@"language.png",@"lacation.png",@"ExchangeServer_Setting",@"themes"];
    
    arrOfLocationData = @[@"Belgium",@"India",@"US",@"Japan",@"Bulgaria",@"France",@"Germany"];
    arrOfLanguageData = @[@"English",@"German",@"French",@"Chinese",@"Spanish",@"Japanese"];

    back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setImage:[UIImage imageNamed:@"back_Arrow"] forState:UIControlStateNormal];
    back.titleLabel.font = [self customFont:16 ofName:MuseoSans_700];

    back.imageEdgeInsets = UIEdgeInsetsMake(0, -45, 0, 0);
    back.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
    back.frame = CGRectMake(0, 0,80, 30);
    [back setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    
    [back  addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    backButton = [[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = backButton;
}




- (void)backBtnAction
{
    [self.tabBarController setSelectedIndex:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    selectedLocationName = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_LOCATION_NAME];
    selectedLanaguage = [[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedLanguageName"];
    
    if (selectedLanaguage == nil)
    {
//        NSString *langID = [[NSLocale preferredLanguages] objectAtIndex:0];
//        selectedLanaguage = [[NSLocale currentLocale] displayNameForKey:NSLocaleLanguageCode value:langID];
        selectedLanaguage = @"English";
    }
    
    selectedCountryName = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_LOCATION_NAME];
    selectedOfficeLocationName = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_OFFICE_NAME];
    
    [self getData];
    
    [self.tableView reloadData];
    self.navigationController.navigationBarHidden = NO;

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localize) name:MCLocalizationLanguageDidChangeNotification object:nil];
    [self localize];



}


-(void)localize
{
    UITabBar *tabBar = self.tabBarController.tabBar;
    UITabBarItem *tabBarItem = tabBar.items[0];
    tabBarItem.title = STRING_FOR_LANGUAGE(@"Tools.Home");
    tabBarItem = tabBar.items[1];
    tabBarItem.title = STRING_FOR_LANGUAGE(@"Setting.Setting");
    tabBarItem = tabBar.items[2];
    tabBarItem.title = STRING_FOR_LANGUAGE(@"Tools");
    tabBarItem = tabBar.items[3];
    tabBarItem.title = STRING_FOR_LANGUAGE(@"About");
   arrOfTableViewData = @[STRING_FOR_LANGUAGE(@"Language.Setting"), STRING_FOR_LANGUAGE(@"Country.Country"), STRING_FOR_LANGUAGE(@"OfficeLocation.Location"),STRING_FOR_LANGUAGE(@"Theme")];
    self.title = STRING_FOR_LANGUAGE(@"Setting.Setting");
 [back setTitle:STRING_FOR_LANGUAGE(@"Tools.Home") forState:UIControlStateNormal];

    [self.tableView reloadData];
}




- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
      UINavigationController *navController = segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"language_segue"])
    {
        LanguageViewController *lang = navController.viewControllers[0];
        lang.delegate =self;
    }else if ([segue.identifier isEqualToString:@"location_segue"])
    {
        LocationViewController *locationVC = navController.viewControllers[0];
        locationVC.delegate = self;
    } else if ([segue.identifier isEqualToString:@"themes_segue"])
    {
        ThemesViewController *themesVC = navController.viewControllers[0];
        themesVC.delegate = self;
    }else if ([segue.identifier isEqualToString:@"exchageToOfficeLocationSegue"])
    {
        UINavigationController *navigation = segue.destinationViewController;
        OfficeLocationsViewController *officeVC = navigation.viewControllers[0];
        officeVC.officesArray = officesOfSelectedCountry;
        officeVC.delegate = self;
    }
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

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrOfTableViewData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:100];
    imageView.image = [UIImage imageNamed:arrOfImages[indexPath.row]];
    
    UILabel *titleLable = (UILabel *)[cell viewWithTag:200];
    titleLable.text = arrOfTableViewData[indexPath.row];
    titleLable.highlightedTextColor = [UIColor whiteColor];

    
    UILabel *languageLabel = (UILabel *)[cell viewWithTag:201];
    
    titleLable.font=[self customFont:16 ofName:MuseoSans_700];
    languageLabel.font=[self customFont:16 ofName:MuseoSans_700];
    
    if (indexPath.row == 0)
    {
        languageLabel.text = selectedLanaguage;
        
    }else if (indexPath.row == 1)
    {
        languageLabel.text = selectedLocationName;
        
    }else if (indexPath .row == 2)
    {
        languageLabel.text = selectedOfficeLocationName?: @"Select Location";
    }else
    {
        languageLabel.text = [self stingForColorTheme];
    }
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [self barColorForIndex:selectedRow];
    [cell setSelectedBackgroundView:bgColorView];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    selectedRow = indexPath.row;

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
   
        if (indexPath.row == 0)
        {
            [self performSegueWithIdentifier:@"language_segue" sender:self];
        }
        else if (indexPath.row == 1)
        {
            [self performSegueWithIdentifier:@"location_segue" sender:self];
        }else if (indexPath.row == 2)
        {
            [self performSegueWithIdentifier:@"exchageToOfficeLocationSegue" sender:self];
        }else
        {
            [self performSegueWithIdentifier:@"themes_segue" sender:self];
        }
}


#pragma mark SettingDelegates

- (void)selectedLanguageis:(LanguageModel *)language
{
    UITableViewCell *languageCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    UILabel *languageLabel = (UILabel *)[languageCell viewWithTag:201];
    languageLabel.text = language.name;
}

- (void)selectedLocationIs:(NSString *)location
{
//    UITableViewCell *languageCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
//    UILabel *languageLabel = (UILabel *)[languageCell viewWithTag:201];
//    languageLabel.text = location;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SELECTED_OFFICE_NAME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SELECTED_OFFICE_MAILID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    selectedOfficeLocationName = nil;
//    [self.tableView reloadData];

}

- (void)selectedThemeIs:(NSString *)theme
{
    UITableViewCell *themesCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    UILabel *themeLable = (UILabel *)[themesCell viewWithTag:201];
    themeLable.text = theme;
    
    UITabBar *tabBar = self.tabBarController.tabBar;
    NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:BACKGROUND_THEME_VALUE];
    [self setTabImageForColorIndex:index onTabBar:tabBar];
    
}

- (void)selectedOfficeIs:(NSString *)location
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    UILabel *leftLable = (UILabel*)[cell viewWithTag:200];
    leftLable.text = location;
}

- (void)setTabImageForColorIndex:(NSInteger)colorIndex onTabBar:(UITabBar *)tabBar;
{
    NSInteger imageIndex = colorIndex+1; //Image name say Commercial-01.png, staring index is 1.
    
    NSString *imageName0 = [NSString stringWithFormat:@"Dwelling-0%li.png", (long)imageIndex];
    NSString *imageName1 = [NSString stringWithFormat:@"Message-0%li.png", (long)imageIndex];
    NSString *imageName2 = [NSString stringWithFormat:@"Spanner-0%li.png", (long)imageIndex];
    NSString *imageName3 = [NSString stringWithFormat:@"Commercial-0%li.png", (long)imageIndex];
    
    
    UITabBarItem *tabBarItem = tabBar.items[0];
    tabBarItem.image = [[UIImage imageNamed:imageName0] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    tabBarItem = tabBar.items[1];
    tabBarItem.image = [[UIImage imageNamed:imageName1] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    tabBarItem = tabBar.items[2];
    tabBarItem.image = [[UIImage imageNamed:imageName2] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    tabBarItem = tabBar.items[3];
    tabBarItem.image = [[UIImage imageNamed:imageName3] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

}

- (UIColor *)colorForIndex:(NSInteger)colorIndex
{
    switch (colorIndex)
    {
        case 0:
            return [UIColor colorWithRed:.1 green:.16 blue:.2 alpha:1];
            break;
            
        case 1:
            return [UIColor colorWithRed:.4 green:.11 blue:.2 alpha:1];
            break;
            
        case 2:
            return [UIColor colorWithRed:.15 green:.18 blue:.09 alpha:1];
            break;
            
        case 3:
            return [UIColor colorWithRed:.35 green:.2 blue:.13 alpha:1];
            break;
            
        default:
            break;
    }
    
    return nil;
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
