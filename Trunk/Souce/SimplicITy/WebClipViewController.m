//
//  WebClipViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/4/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "WebClipViewController.h"
#import "webClipModel.h"
#import "DBManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "WebClipCollectionViewCell.h"
#import "HeaderCollectionReusableView.h"
#import "HexColors.h"

@interface WebClipViewController () <UICollectionViewDataSource, UICollectionViewDelegate,postmanDelegate,DBManagerDelegate, UIAlertViewDelegate>
{
    UIBarButtonItem *backButton;
    Postman *postMan;
    NSMutableArray *webClipArr,*dashBoardItemArr,*selectedArr;
    NSString *databasePath;
    sqlite3 *database;
    DBManager *dbManager,*dashBoardDBmanager;
    NSString *URLString;
    UIAlertView *openAppAlert;
    UIButton *back;
    BOOL isSelectApps;
    NSMutableArray *selectedAppsArr;
    NSInteger colourNumber;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstrant;
@property (weak, nonatomic) IBOutlet UIView *topView;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewOutlet;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *selectappsButton;
@property (weak, nonatomic) IBOutlet UIButton *movetoDashBoardButton;
@property (weak, nonatomic) IBOutlet UILabel *selectuptoLabel;
@property (weak, nonatomic) IBOutlet UILabel *iconleftLabel;

@end

@implementation WebClipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    self.selectuptoLabel.font = [self customFont:14 ofName:MuseoSans_700];
    self.iconleftLabel.font = [self customFont:14 ofName:MuseoSans_700];
    
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
    webClipArr = [[NSMutableArray alloc] init];
    dashBoardItemArr =[[NSMutableArray alloc]init];
    [self DashBoardItem];
    NSString *langCode =  [[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedLanguageCode"];
    URLString = [NSString stringWithFormat:@"%@%@%@",WEB_CLIPS_BASE_API,LANGUAGE_CODE_STRING,langCode];
    postMan = [[Postman alloc] init];
    postMan.delegate = self;
   

    
    
    
    if ([AFNetworkReachabilityManager sharedManager].isReachable)
    {
        if ([[NSUserDefaults standardUserDefaults]boolForKey:@"webclip"])
        {
            [self tryUpdatewebClip];

        }else
        {
            [self  getData];
        }
    }
    else
    {
        [self  getData];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localize) name:MCLocalizationLanguageDidChangeNotification object:nil];
    [self localize];
}

- (void)localize
{
    self.title = STRING_FOR_LANGUAGE(@"Apps");
    [back setTitle:STRING_FOR_LANGUAGE(@"Home") forState:UIControlStateNormal];
    [_movetoDashBoardButton setTitle:STRING_FOR_LANGUAGE(@"MovetoDashboard") forState:UIControlStateNormal];
    self.selectuptoLabel.text = SELECT_UPTO9APPS;
    
    [back sizeToFit];




}

- (void)tryUpdatewebClip
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [postMan get:URLString];
}

- (void)backBtnAction
{
    [self.tabBarController setSelectedIndex:0];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getdashboardItemFromTable];
     self.selectappsButton.title = EDIT_APPS_NAVBUTTON;
    isSelectApps = NO;
    self.topConstrant.constant = -55;
    [self.collectionViewOutlet reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (IBAction)SelectAppsButtonAction:(id)sender {
    if (isSelectApps) {
        isSelectApps = NO;
      self.selectappsButton.title = EDIT_APPS_NAVBUTTON;
        self.topConstrant.constant = -55;
        [selectedAppsArr removeAllObjects];
    } else {
        selectedAppsArr = [[NSMutableArray alloc]init];
        isSelectApps = YES;
        self.selectappsButton.title = CLOSE_APPS_NAVBUTTON;
        self.topConstrant.constant = 0;
    }
    self.iconleftLabel.text = [NSString stringWithFormat:@"%lu %@",9 -(unsigned long)selectedArr.count,ICONS_LEFT];
    [self.collectionViewOutlet reloadData];
    
}
- (IBAction)movetoDashBoardButtonAction:(id)sender {

}

#pragma mark 
#pragma mark postmanDelegate

- (void)postman:(Postman *)postman gotSuccess:(NSData *)response forURL:(NSString *)urlString
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([urlString isEqualToString:URLString])
    {
        [self parseResponsedata:response andgetImages:YES];
        [self saveWebClipsData:response forURL:urlString];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"webclip"];
        [[NSUserDefaults standardUserDefaults] synchronize];

    }else
    {
        [self createImages:response forUrl:urlString];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"document"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)postman:(Postman *)postman gotFailure:(NSError *)error forURL:(NSString *)urlString
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)parseResponsedata:(NSData *)response andgetImages:(BOOL)download
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    NSArray *arr = json[@"aaData"][@"WebClips"];
    for (NSDictionary *aDict in arr)
    {
        if ([aDict[@"Status"] boolValue])
        {
            webClipModel *webClip = [[webClipModel alloc]init];
            webClip.title = aDict[@"Title"];
            webClip.urlLink = aDict[@"HREF"];
            webClip.imageCode = aDict[@"DocumentCode"];
            webClip.code = aDict[@"Code"];
            webClip.image = nil;
            [webClipArr addObject:webClip];
            if (download || [[NSUserDefaults standardUserDefaults] boolForKey:@"document"])
            {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                NSString *imageUrl = [NSString stringWithFormat:RENDER_DOC_API,webClip.imageCode];
                [postMan get:imageUrl];
            }
        }
    }
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    webClipArr = [[webClipArr sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
    [self.collectionViewOutlet reloadData];
}

- (void)createImages:(NSData *)response forUrl:(NSString *)url
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    if (![json[@"aaData"][@"Success"] boolValue])
    {
        return;
    }
    NSString *imageAsBlob = json[@"aaData"][@"Base64Model"][@"Image"];
//    NSLog(@"%@",imageAsBlob);
    NSString *pathToDoc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSData *imageDataForFromBase64 = [[NSData alloc] initWithBase64EncodedString:imageAsBlob options:kNilOptions];
    
    UIImage *image = [UIImage imageWithData:imageDataForFromBase64];
    
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *pathToImage;
    
//    NSMutableString *webClipFileName = [[NSMutableString alloc] init];
//    webClipFileName = @""
    NSRange rangeOfFileName;
    rangeOfFileName.length = url.length;
    rangeOfFileName.location = 0;
    
    NSMutableString *stringToRemove = [RENDER_DOC_API mutableCopy];
    NSRange rangeOfBaseURL;
    rangeOfBaseURL.length = stringToRemove.length;
    rangeOfBaseURL.location = 0;
    [stringToRemove replaceOccurrencesOfString:@"%@" withString:@"" options:NSCaseInsensitiveSearch range:rangeOfBaseURL];
    
    NSLog(@"Base URL = %@", stringToRemove);
    NSMutableString *docCode = [url mutableCopy];
    [docCode replaceOccurrencesOfString:stringToRemove
                                withString:@""
                                   options:NSCaseInsensitiveSearch
                                     range:rangeOfFileName];
    
    pathToImage = [NSString stringWithFormat:@"%@/%@@2x.png", pathToDoc, docCode];
    NSLog(@"%@", pathToImage);
    [imageData writeToFile:pathToImage atomically:YES];
    
    [self.collectionViewOutlet reloadData];
}

- (void)saveWebClipsData:(NSData *)response forURL:(NSString *)APILink
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate=self;
    }
    [dbManager dropTable:@"webClips"];
    NSString *createQuery = @"create table if not exists webClips (API text PRIMARY KEY, data text)";
    [dbManager createTableForQuery:createQuery];
    
    NSMutableString *stringFromData = [[NSMutableString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSRange rangeofString;
    rangeofString.location = 0;
    rangeofString.length = stringFromData.length;
    [stringFromData replaceOccurrencesOfString:@"'" withString:@"''" options:(NSCaseInsensitiveSearch) range:rangeofString];
    
    NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO  webClips (API,data) values ('%@', '%@')", APILink,stringFromData];
    
    [dbManager saveDataToDBForQuery:insertSQL];
}

- (void)getData
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate=self;
    }
    
    NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM webClips WHERE API = '%@'", URLString];
    if (![dbManager getDataForQuery:queryString])
    {
        if (![AFNetworkReachabilityManager sharedManager].reachable)
        {
            UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:WARNING_TEXT message:INTERNET_IS_REQUIRED_TO_SYNC_DATA delegate:nil cancelButtonTitle:OK_FOR_ALERT otherButtonTitles: nil];
            [noNetworkAlert show];
        }
        
        [self tryUpdatewebClip];
    }
}

- (void)DBManager:(DBManager *)manager gotSqliteStatment:(sqlite3_stmt *)statment
{
    if ([manager isEqual:dashBoardDBmanager]) {
        selectedArr =[[NSMutableArray alloc]init];
        while (sqlite3_step(statment) == SQLITE_ROW)
        {
            webClipModel *dModel = [[webClipModel alloc] init];
            dModel.title = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 0)];
            dModel.imageName = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 2)];
            dModel.seguaName = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 3)];
            dModel.imageCode = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 4)];
            dModel.code = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 5)];
           dModel.colourCode = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 6)];
            [selectedArr addObject:dModel];
        }
    }else
    {
    if (sqlite3_step(statment) == SQLITE_ROW)
    {
        NSString *string = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 1)];
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        [self parseResponsedata:data andgetImages:NO];
    }else
    {
        [self tryUpdatewebClip];
    }
    }

}

#pragma mark UICollectionViewDataSource methods


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section==0) {
        return 5;
    } else {
        return [webClipArr count];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    WebClipCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    UILabel *titlelable = (UILabel *)[cell viewWithTag:100];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:101];
    UIView *imageContainerView = (UIView *)[cell viewWithTag:120];
    imageContainerView.layer.cornerRadius = 8;
    
    webClipModel *webClip;
    if (indexPath.section == 0 ) {
      webClip = dashBoardItemArr[indexPath.row];
        imageView.image = [UIImage imageNamed:webClip.imageName];
        titlelable.text = STRING_FOR_LANGUAGE(webClip.title);
        titlelable.font=[self customFont:14 ofName:MuseoSans_700];
        imageContainerView.backgroundColor = [UIColor colorWithHexString:webClip.colourCode];
    
    } else {
       webClip = webClipArr[indexPath.row];
        titlelable.text = webClip.title;
        titlelable.font=[self customFont:14 ofName:MuseoSans_700];
        imageView.image = [self getimageForDocCode:webClip.imageCode];
        imageContainerView.backgroundColor = [UIColor clearColor];
 
    }
   
        if (isSelectApps) {
        [cell.alphaView setHidden:NO];
       // self.tabBarController.tabBar.hidden = YES;
    } else {
        [cell.selectedImage setHidden:YES];
        [cell.alphaView setHidden:YES];
       // self.tabBarController.tabBar.hidden = NO;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@", webClip.title];
    NSArray *filteredArray = [selectedArr filteredArrayUsingPredicate:predicate];
    
    
    if (filteredArray.count == 1)
    {
        cell.selectedImage.image =[UIImage imageNamed:@"seclecteApps"];
        [cell.selectedImage setHidden:NO];

    }else
    {
        if (isSelectApps) {
            cell.selectedImage.image =[UIImage imageNamed:@"unselectedApps"];
            [cell.selectedImage setHidden:NO];
        } else {
              [cell.selectedImage setHidden:YES];
        }
    }
    return cell;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    webClipModel *webClip = webClipArr[indexPath.row];
    if (isSelectApps) {
        webClipModel *aModel;
        if (indexPath.section==0) {
            aModel=dashBoardItemArr[indexPath.row];
        } else {
            aModel=webClipArr[indexPath.row];
        }
        
        self.iconleftLabel.text = [NSString stringWithFormat:@"%lu icon(s)left",8 -(unsigned long)selectedArr.count];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code == %@", aModel.code];
        NSArray *filteredArray = [selectedArr filteredArrayUsingPredicate:predicate];
        if (filteredArray.count == 1)
        {
            if (selectedArr.count==1) {
             [self showAlerWhenUserSelectMoreThanNineItem:RECHED_MINNO_TILES];
             return;
            } else {
                [self delettableRow:aModel];
                [self getdashboardItemFromTable];
            }
            
        }else
        {
            if (selectedArr.count>8 ) {
                [self showAlerWhenUserSelectMoreThanNineItem:RECHED_MAXNO_TILES];
                return;
            }else
            {
            [self saveDatainSqliteForDashboard:aModel];
            [selectedArr addObject:aModel];
            }}
       
        
        [self.collectionViewOutlet reloadData];
    }
    
    else {
        if (indexPath.section==0) {
        } else {
            BOOL didOpen = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:webClip.urlLink]];
            if (!didOpen)
            {
                if (openAppAlert == nil)
                {
                    openAppAlert = [[UIAlertView alloc] initWithTitle:STRING_FOR_LANGUAGE(@"Can.open.not") message:STRING_FOR_LANGUAGE(@"App.Not.Install") delegate:self cancelButtonTitle:STRING_FOR_LANGUAGE(@"No") otherButtonTitles:STRING_FOR_LANGUAGE(@"Yes"), nil];
                }
                [openAppAlert show];
            }
        }
    }
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        HeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        if (indexPath.section ==0) {
            headerView.headerTitle.text = MOBILITY_APP;
        } else {
            headerView.headerTitle.text = STRING_FOR_LANGUAGE(@"Apps");
        }
        headerView.headerTitle.font=[self customFont:18 ofName:MuseoSans_700];
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        reusableview = footerview;
    }
    return reusableview;
}

- (UIImage *)getimageForDocCode:(NSString *)docCode
{
    NSString *pathToDoc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [pathToDoc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@@2x.png", docCode]];
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    if (imageData)
    {
        UIImage *tempImage = [UIImage imageWithData:imageData];
        imageData = nil;
        UIImage *webClipImage = [UIImage imageWithCGImage:tempImage.CGImage scale:2 orientation:tempImage.imageOrientation] ;
        tempImage = nil;
        return webClipImage;
    }
    return nil;
}

-(void)isSelectedButtonEnable:(NSIndexPath *)indexPath{
    webClipModel *aModel;
    if (indexPath.section==0) {
        aModel=dashBoardItemArr[indexPath.item];
    } else {
        aModel=webClipArr[indexPath.item];
        
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@", aModel.title];
    NSArray *filteredArray = [selectedArr filteredArrayUsingPredicate:predicate];
    if (filteredArray.count == 1)
    {
        [self delettableRow:aModel];
        [selectedArr removeObject:aModel];
    }else
    {
       [self saveDatainSqliteForDashboard:aModel];
      [selectedArr addObject:aModel];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([openAppAlert isEqual:alertView])
    {
        if (buttonIndex == 1)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[UserInfo sharedUserInfo].appStoreURL]];
        }
    }
}

-(void)showAlerWhenUserSelectMoreThanNineItem:(NSString *)messageString
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:ALERT_FOR_ALERT
                                  message:messageString
                                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:OK_FOR_ALERT
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"cancle"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];


}

// method for selection item and removing from dashboard
//-(void)whenpressSelectButtonActionwithCollection:(NSIndexPath *)indexPath
//{
//    webClipModel *aModel;
//    if (indexPath.section==0) {
//         aModel=dashBoardItemArr[indexPath.item];
//    } else {
//        aModel=webClipArr[indexPath.item];
//    }
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@", aModel.title];
//    NSArray *filteredArray = [selectedArr filteredArrayUsingPredicate:predicate];
//    if (filteredArray.count == 1)
//    {
//        [self delettableRow:aModel];
//        [selectedArr removeObject:aModel];
//    }else
//    {
//        
//        [self saveDatainSqliteForDashboard:aModel];
//        [selectedArr addObject:aModel];
//    }
//    [self.collectionViewOutlet reloadData];

//}

-(void)saveDatainSqliteForDashboard:(webClipModel *)amodel
{
    if (dashBoardDBmanager == nil)
    {
        dashBoardDBmanager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dashBoardDBmanager.delegate=self;
    }
    NSString *createQuery = @"create table if not exists DashboardItem (Title text, Url text, ImageName text,seguaName text,imageCode text,code text,colourCode text)";
    [dashBoardDBmanager createTableForQuery:createQuery];
    colourNumber = 0;
    NSString *randomColourCode;
    if (amodel.colourCode) {
        randomColourCode = amodel.colourCode;
    } else {
        randomColourCode =  [self tilesColoreCode:colourNumber];
    }
    NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO  DashboardItem (Title,Url,ImageName,seguaName,imageCode,code,colourCode) values ('%@', '%@', '%@' , '%@' , '%@' ,'%@' ,'%@')", amodel.title,amodel.urlLink,amodel.imageName,amodel.seguaName,amodel.imageCode,amodel.code,randomColourCode];
    [dashBoardDBmanager saveDataToDBForQuery:insertSQL];
    //[self getdashboardItemFromTable];

}

-(void)getdashboardItemFromTable
{
    
    if (dashBoardDBmanager == nil)
    {
        dashBoardDBmanager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dashBoardDBmanager.delegate=self;
    }
    NSString *queryString = @"SELECT * FROM DashboardItem";
    [dashBoardDBmanager getDataForQuery:queryString];
}

-(void)delettableRow:(webClipModel *)amodel{
    NSString *deletQuery = [NSString stringWithFormat:@"DELETE FROM DashboardItem WHERE code = \'%@\'",amodel.code];
    [dashBoardDBmanager deleteRowForQuery:deletQuery];
    [self.collectionViewOutlet reloadData];
}




-(NSString *)tilesColoreCode:(NSInteger)colourNumber
{
   NSString *colorCode;
   int r = arc4random() % 10;
    
    switch (r) {
        case 0:
            return colorCode = @"#f2da6f";
            break;
        case 1:
            return colorCode = @"#c0b1ce";
            break;
        case 2:
            return colorCode = @"#491537";
            break;
        case 3:
            return colorCode = @"#50337f";
            break;
        case 4:
            return colorCode = @"#77051a";
            break;
        case 5:
            return colorCode = @"#b3bc4f";
            break;
        case 6:
            return colorCode = @"#555649";
            break;
        case 7:
            return colorCode = @"#54537c";
            break;
        case 8:
            return colorCode = @"#0a093a";
            break;
        case 9:
            return colorCode = @"#253f00";
            break;

        default:
            break;
    
    
    }
          return colorCode ;



}




-(void)DashBoardItem
{
    webClipModel *dModel = [[webClipModel alloc]init];
    dModel.title = @"News";
    dModel.seguaName = @"homeTonewsSegua";
    dModel.imageName = @"MessageIcon";
    dModel.code = @"DNEWS";
     dModel.colourCode = @"#F79A14";
    [dashBoardItemArr addObject:dModel];
    dModel = [[webClipModel alloc]init];
    dModel.title = @"Book.Room";
    dModel.imageName = @"BookARoomDashIcon";
    dModel.seguaName = @"hometoBookaRoom";
    dModel.code = @"DBOOKAROOM";
    dModel.colourCode = @"#1D93F6";
    [dashBoardItemArr addObject:dModel];
    dModel = [[webClipModel alloc]init];
    dModel.title = @"Password.Expiry";
    dModel.seguaName = @"homeToPasswordExp";
    dModel.imageName = @"PasswordToolDashIcon";
    dModel.code = @"DPASSEXP";
    dModel.colourCode = @"#B28036";
    [dashBoardItemArr addObject:dModel];
    dModel = [[webClipModel alloc]init];
    dModel.title = @"Call.Desk";
    dModel.imageName = @"PhoneIcon";
    dModel.code = @"DCALLSERVICE";
    dModel.colourCode = @"#48AF41";
    [dashBoardItemArr addObject:dModel];
    dModel = [[webClipModel alloc]init];
    dModel.title = @"Upgrade.Device";
    dModel.seguaName = @"hometoOkToUpdate";
    dModel.imageName = @"SettingsDashIcon";
    dModel.code = @"DUPGRADEDEVICE";
    dModel.colourCode = @"#5E5A5A";
    [dashBoardItemArr addObject:dModel];
}



@end
