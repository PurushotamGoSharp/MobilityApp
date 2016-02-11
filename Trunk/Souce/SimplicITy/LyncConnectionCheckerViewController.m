//
//  LyncConnectionCheckerViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/20/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "LyncConnectionCheckerViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "UserInfo.h"
#import "MBProgressHUD.h"
#import "Postman.h"
#import "LyncConfigModel.h"
#import "DBManager.h"

#define NULL_CHECKER(X) ([X isKindOfClass:[NSNull class]] ? nil : X)

@interface LyncConnectionCheckerViewController ()<postmanDelegate, DBManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *connectionSpeedLbl;
@property (weak, nonatomic) IBOutlet UILabel *downloadLbl;
@property (weak, nonatomic) IBOutlet UILabel *uploadlbl;
@property (weak, nonatomic) IBOutlet UILabel *connectionResultLbl;
@property (weak, nonatomic) IBOutlet UILabel *AudioLbl;
@property (weak, nonatomic) IBOutlet UILabel *videoLbl;
@property (weak, nonatomic) IBOutlet UILabel *screenShareLbl;
@property (weak, nonatomic) IBOutlet UIImageView *uploadImageView;
@property (weak, nonatomic) IBOutlet UIImageView *downloadImgView;

@property (weak, nonatomic) IBOutlet UIView *audioView;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIView *screenShareView;
@property (weak, nonatomic) IBOutlet UIButton *RefreshButtonRef;

@end

@implementation LyncConnectionCheckerViewController
{
    AFURLSessionManager *managerrr;
    __block MBProgressHUD *hud;
    NSNumberFormatter *fmt;
    NSDictionary *uploadAndDownloadInfo;
    
    NSString *downloadDirectoryPath;
    NSString *filePath;
    
    __block double totalsizeOfDownloadeswData;
    
    int uploadSpeed, downloadSpeed;
    
    NSString *fileId;
    NSString *requestCode;
    int docId;
    Postman *postman;
    DBManager *dbManager;
    
    LyncConfigModel *audioUpObj, *audioDownObj, *videoUpObj, *videoDownObj, *screenUpObj, *screenDownObj;
    NSString *slowonlyAudio;
    NSString *averageaudioViewScreen;
    NSString *fastaudiovideoviewScreen;
    NSString *alertt;
    NSString *ok;
    NSString *notconnectInternet;
    NSString *kb;
    NSString *mb;


}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    }

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localize) name:MCLocalizationLanguageDidChangeNotification object:nil];
    [self localize];
    
    
    self.connectionSpeedLbl.font = [self customFont:20 ofName:MuseoSans_300];
    self.downloadLbl.font = [self customFont:26 ofName:MuseoSans_700];
    self.uploadlbl.font = [self customFont:26 ofName:MuseoSans_700];
    self.connectionResultLbl.font = [self customFont:16 ofName:MuseoSans_700];
    self.AudioLbl.font = [self customFont:16 ofName:MuseoSans_300];
    self.videoLbl.font = [self customFont:16 ofName:MuseoSans_300];
    self.screenShareLbl.font = [self customFont:16 ofName:MuseoSans_300];
    // Setting the title of login button
    [self.RefreshButtonRef setTitle:STRING_FOR_LANGUAGE(@"Retry") forState:normal];
    //custmize the font of button text
    self.RefreshButtonRef.titleLabel.font = [self customFont:18 ofName:MuseoSans_700];
    self.RefreshButtonRef.layer.cornerRadius = 2;
    
    
    
    
    
    
    
    fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.#"];
    self.connectionResultLbl.text = STRING_FOR_LANGUAGE(@"Connection.Speed");
    
    
    if ([AFNetworkReachabilityManager sharedManager].isReachable)
    {
        if ([AFNetworkReachabilityManager sharedManager].isReachable)
        {
            if ([[NSUserDefaults standardUserDefaults]boolForKey:@"configuration"])
            {
                [self callConfigAPI];
                
            }else
            {
                [self  getData];
            }
            
        }
        else
        {
            [self  getData];
        }
        
        [self callAPI];
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_FOR_ALERT message:notconnectInternet delegate:self cancelButtonTitle:nil otherButtonTitles:OK_FOR_ALERT, nil];
        [alert show];
    }


    
   }
- (IBAction)RefreshButtonAction:(id)sender {

    self.downloadLbl.text = [NSString stringWithFormat:@"%d",0];
    self.uploadlbl.text = [NSString stringWithFormat:@"%d",0];
    [self refreshtapAction];

}


-(void)localize
{
    self.title = STRING_FOR_LANGUAGE(@"Ping.Linc");
    self.connectionSpeedLbl.text = STRING_FOR_LANGUAGE(@"Connection.Speed");
    self.AudioLbl.text = STRING_FOR_LANGUAGE(@"Audio");
    self.videoLbl.text = STRING_FOR_LANGUAGE(@"Video");
    self.screenShareLbl.text = STRING_FOR_LANGUAGE(@"View.Screen");
    
    kb = STRING_FOR_LANGUAGE(@"KB");
    mb = STRING_FOR_LANGUAGE(@"MB");
    slowonlyAudio = STRING_FOR_LANGUAGE(@"Audio.slow");
    averageaudioViewScreen = STRING_FOR_LANGUAGE(@"Audio.Average");
    fastaudiovideoviewScreen = STRING_FOR_LANGUAGE(@"Audio.fast");
    notconnectInternet = STRING_FOR_LANGUAGE(@"Internet.Required");
    alertt = STRING_FOR_LANGUAGE(@"Language.Alert");
    

}



-(void)refreshtapAction
{
    self.videoView.backgroundColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1]; //Gray
    self.audioView.backgroundColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
    self.screenShareView.backgroundColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
    
    
    fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.#"];
    self.connectionResultLbl.text = STRING_FOR_LANGUAGE(@"Connection.Speed");
    
    
    if ([AFNetworkReachabilityManager sharedManager].isReachable)
    {
        if ([AFNetworkReachabilityManager sharedManager].isReachable)
        {
            if ([[NSUserDefaults standardUserDefaults]boolForKey:@"configuration"])
            {
                [self callConfigAPI];
                
            }else
            {
                [self  getData];
            }
            
        }
        else
        {
            [self  getData];
        }
        
        [self callAPI];
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_FOR_ALERT message:notconnectInternet delegate:self cancelButtonTitle:nil otherButtonTitles:OK_FOR_ALERT, nil];
        [alert show];
    }
}








- (void)getData
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate = self;
    }
    
    NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM configarationAPI WHERE API = '%@'", ALL_CONFIG_API];
    if (![dbManager getDataForQuery:queryString])
    {
        if (![AFNetworkReachabilityManager sharedManager].reachable)
        {
            UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:WARNING_TEXT message:INTERNET_IS_REQUIRED_TO_SYNC_DATA delegate:nil cancelButtonTitle:OK_FOR_ALERT otherButtonTitles: nil];
            [noNetworkAlert show];
        }
        
        [self callConfigAPI];
    }
}

- (void)DBManager:(DBManager *)manager gotSqliteStatment:(sqlite3_stmt *)statment
{
    if (sqlite3_step(statment) == SQLITE_ROW)
    {
        NSString *string = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 1)];
        
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        [self parseCOnfigResponse:dict];
    }
}
- (void)callConfigAPI
{
    if (postman == nil)
    {
        postman = [[Postman alloc] init];
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [postman get:ALL_CONFIG_API
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             [self parseCOnfigResponse:responseObject];
             [self saveWebClipsData:[operation responseData] forURL:ALL_CONFIG_API];
             [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"configuration"];
             [[NSUserDefaults standardUserDefaults] synchronize];
             [MBProgressHUD hideHUDForView:self.view animated:YES];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
         }];
}

- (void)saveWebClipsData:(NSData *)response forURL:(NSString *)APILink
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate=self;
    }
    
    NSString *createQuery = @"create table if not exists configarationAPI (API text PRIMARY KEY, data text)";
    [dbManager createTableForQuery:createQuery];
    
    NSMutableString *stringFromData = [[NSMutableString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSRange rangeofString;
    rangeofString.location = 0;
    rangeofString.length = stringFromData.length;
    [stringFromData replaceOccurrencesOfString:@"'" withString:@"''" options:(NSCaseInsensitiveSearch) range:rangeofString];
    
    NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO  configarationAPI (API,data) values ('%@', '%@')", APILink,stringFromData];
    
    [dbManager saveDataToDBForQuery:insertSQL];
}

- (void)parseCOnfigResponse:(NSDictionary *)response
{
    NSArray *configs = response[@"aaData"][@"Configurations"];
    
    for (NSDictionary *dict in configs)
    {
        if ([NULL_CHECKER(dict[@"ParentCode"]) isEqualToString:@"Lync Checker"])
        {
            LyncConfigModel *config = [[LyncConfigModel alloc] init];
            config.code = dict[@"Code"];
            config.valueFrom = [dict[@"ValueFrom"] floatValue];
            config.valueTo = [dict[@"ValueTo"] floatValue];
            
            if ([config.code isEqualToString:@"AUDUPL"])
            {
                audioUpObj = config;
            }else if ([config.code isEqualToString:@"AUDDLL"])
            {
                audioDownObj = config;

            }else if ([config.code isEqualToString:@"VIDUPL"])
            {
                videoUpObj = config;

            }else if ([config.code isEqualToString:@"VIDDLL"])
            {
                videoDownObj = config;

            }else if ([config.code isEqualToString:@"VSCUPL"])
            {
                screenUpObj = config;

            }else if ([config.code isEqualToString:@"VSCDLL"])
            {
                screenDownObj = config;
            }
        }
    }
}

-(void)callAPI
{
    [self.RefreshButtonRef setEnabled:NO];
    [self.RefreshButtonRef setBackgroundColor:[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1]];

    NSString *pathOfPlist = [[NSBundle mainBundle] pathForResource:@"UploadAndDownloadInfo" ofType:@"plist"];
    uploadAndDownloadInfo = [NSDictionary dictionaryWithContentsOfFile:pathOfPlist];
    
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    
    downloadDirectoryPath = [NSString stringWithFormat:@"%@/Downloads/", documentsDirectoryPath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:downloadDirectoryPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:downloadDirectoryPath withIntermediateDirectories:NO attributes:nil error:nil];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    managerrr = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"image1Mb" ofType:@"jpg"];
    NSURL *imgUrlPath = [NSURL fileURLWithPath:path];
    
    NSLog(@"Path Of Image %@",imgUrlPath);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFJSONRequestSerializer *requresrSerializer = [AFJSONRequestSerializer serializer];
    [requresrSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    manager.requestSerializer = requresrSerializer;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"multipart/form-data"];
    
    NSString *corpId = [UserInfo sharedUserInfo].cropID;
    
    requestCode = [NSString stringWithFormat:@"%@%@",corpId,[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"]];
    
    //    NSString *request = [NSString stringWithFormat:@"{\"FileName\":\"image1Mb.jpg\",\"DocumentTypeCode\":\"EL3DGO\",\"RequestType\":\"MobileLyncChecker\",\"RequestCode\":\"%@\",\"UserID\":1,\"AuditEventDescription\":\"Document ( image1Mb.jpg )  Uploaded\",\"RequestId\":2,\"EntityDescription\":\"Mobile Lync Checker\",\"UserName\":\"undefined undefined undefined\"}",requestCode];
    
    
    
    
    NSString *request = [NSString stringWithFormat:@"{\"FileName\":\"%@\",\"DocumentTypeCode\":\"%@\",\"RequestType\":\"%@\",\"RequestCode\":\"%@\",\"UserID\":%i,\"AuditEventDescription\":\"%@\",\"RequestId\":%i,\"EntityDescription\":\"%@\",\"UserName\":\"%@\"}",uploadAndDownloadInfo[@"fileName"],uploadAndDownloadInfo[@"documentTypeCode"],uploadAndDownloadInfo[@"requestType"], requestCode, [uploadAndDownloadInfo[@"userId"] intValue], uploadAndDownloadInfo[@"auditEventDescription"],[uploadAndDownloadInfo[@"requestId"] intValue], uploadAndDownloadInfo[@"entityDescription"], uploadAndDownloadInfo[@"userName"]];
    
    NSDictionary *parameter = @{@"request": request};
    NSDate *startTime ;
    __block double totalsizeOfData;
    
    startTime = [NSDate date];
    
    hud = [MBProgressHUD showHUDAddedTo:self.uploadImageView animated:YES];
    hud.color = [UIColor clearColor];
    hud.activityIndicatorColor = [UIColor blackColor];
    NSLog(@"%@", UPLOAD_FILE_API);
    AFHTTPRequestOperation *operation = [manager POST:UPLOAD_FILE_API parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
                                         {
                                             [formData appendPartWithFileURL:imgUrlPath name:@"files" error:nil];
                                             
                                         } success:^(AFHTTPRequestOperation *operation, id responseObject)
                                         {
                                             
                                             NSDate *enddate = [NSDate date];
                                             //                                             [MBProgressHUD hideAllHUDsForView:self.uploadImageView animated:YES];
                                             [hud hide:YES];
                                             
                                             NSTimeInterval seconds =   [enddate timeIntervalSinceDate:startTime];
                                             //        transfer_speed = bytes_transferred / ( current_time - start_time)
                                             double speed = totalsizeOfData/seconds;
                                             
                                             double speedInKb =   speed/1024;
                                             
                                             uploadSpeed = speedInKb;
                                             
                                             if (speedInKb >=1000)
                                             {
                                                 self.uploadlbl.text = [NSString stringWithFormat:@"%@ %@",[fmt stringFromNumber:[NSNumber numberWithFloat:speedInKb/1024]],mb ];
                                             }else
                                             {
                                                 self.uploadlbl.text = [NSString stringWithFormat:@"%@ %@",[fmt stringFromNumber:[NSNumber numberWithFloat:speedInKb]],kb ];
                                             }
                                             NSLog(@"file upload Sucess");
                                             
                                             NSData *responseData = [operation responseData];
                                             
                                             NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
                                             NSLog(@"JSOn %@",json);
                                             
                                             NSString *JSONString = json[@"aaData"][@"JSON"];
                                             
//                                             if (JSONString)
//                                             {
                                                 NSDictionary *dictFromJSON = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                                                 
                                                 fileId = dictFromJSON[@"Code"];
                                                 docId = [dictFromJSON[@"ID"] intValue];
                                                 
                                                 [self downloadImageByCode:fileId];
//                                             }
                                             
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                         {
                                             NSLog(@"file upload failure error %@",error);
                                             [hud hide:YES];
                                         
                                             [self buttonColourAccordingtotheme];
                                             [self.RefreshButtonRef setEnabled:YES];
                                         
                                         
                                         }];
    
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite)
     {
         float progress = ((float)totalBytesWritten) / totalBytesExpectedToWrite;
         //                 NSLog(@"status %f",progress);
         //         NSLog(@"Wrote %lld/%lld", totalBytesWritten, totalBytesExpectedToWrite);
         totalsizeOfData = totalBytesExpectedToWrite;
     }];
}

-(void)downloadImageByCode:(NSString*)code
{
    hud = [MBProgressHUD showHUDAddedTo:self.downloadImgView animated:YES];
    hud.color = [UIColor clearColor];
    hud.activityIndicatorColor = [UIColor blackColor];
    
    NSString *urlWithCode = [NSString stringWithFormat:@"%@%@",DOWNLOAD_FILE_API,code];
    NSURL *URL = [NSURL URLWithString:urlWithCode];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    filePath = [self filePathForURLString:URL];
    NSDate  *starteTime = [NSDate date];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         [hud hide:YES];
         
         NSLog(@"Successfully downloaded file to %@", filePath);
         
         NSDate  *endTime = [NSDate date];
         
         NSTimeInterval seconds =   [endTime timeIntervalSinceDate:starteTime];
         
         //        transfer_speed = bytes_transferred / ( current_time - start_time)
         double speed = totalsizeOfDownloadeswData/seconds;
         
         double speedInKb =   speed/1024;
         
         downloadSpeed = speedInKb;
         
         if (speedInKb >=1000)
         {
             self.downloadLbl.text = [NSString stringWithFormat:@"%@ %@",[fmt stringFromNumber:[NSNumber numberWithFloat:speedInKb/1024]] ,mb];
             
         }else
         {
             self.downloadLbl.text = [NSString stringWithFormat:@"%@ KB",[fmt stringFromNumber:[NSNumber numberWithFloat:speedInKb]]];
         }
         
         //         NSString *parameterToDelete = [NSString stringWithFormat:@"{\"request\":{\"docid\":%i,\"fileid\":\"%@\",\"RequestId\":2,\"RequestCode\":\"%@\",\"UserName\":\"undefined undefined undefined\",\"AuditEventDescription\":\"Document ( image1Mb.jpg ) Deleted\",\"EntityDescription\":\"Mobile Lync Checker\"}}",(int)docId,fileId,requestCode];
         
         NSString *parameterToDelete = [NSString stringWithFormat:@"{\"request\":{\"docid\":%i,\"fileid\":\"%@\",\"RequestId\":%i,\"RequestCode\":\"%@\",\"UserName\":\"%@\",\"AuditEventDescription\":\"%@\",\"EntityDescription\":\"%@\"}}",(int)docId,fileId,[uploadAndDownloadInfo[@"requestId"] intValue],requestCode, uploadAndDownloadInfo[@"userName"], uploadAndDownloadInfo[@"auditEventDescription"], uploadAndDownloadInfo[@"entityDescription"]];
         
         [self deleteAfterDownloadWithParameter:parameterToDelete];
         [self enableAndDisable];
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [hud hide:YES];
         UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@",error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil ];
         [alert show];
         [self buttonColourAccordingtotheme];
         [self.RefreshButtonRef setEnabled:YES];
         
     }];
    [operation start];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        float progress = ((float)totalBytesRead) / totalBytesExpectedToRead;
        NSLog(@"status %f",progress);
        totalsizeOfDownloadeswData = totalBytesExpectedToRead;
    }];
}

- (void)deleteAfterDownloadWithParameter:(NSString*)parameter
{
//    Postman *postman = [[Postman alloc] init];
    postman.delegate = self;
    [postman post:DELETE_FILE_API withParameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"File is Deleted sucessfully");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"File is not Deleted");
     }];
}

- (void)enableAndDisable
{
    
    if ((uploadSpeed <= audioUpObj.valueTo && uploadSpeed > audioUpObj.valueFrom) || (downloadSpeed <= audioDownObj.valueTo && (downloadSpeed > audioDownObj.valueFrom)) )
    {
        self.audioView.backgroundColor = [UIColor colorWithRed:.4 green:.7 blue:.2 alpha:1]; //Blue
        self.videoView.backgroundColor = [UIColor colorWithRed:.8 green:.2 blue:.2 alpha:1]; //Gray
        self.screenShareView.backgroundColor = [UIColor colorWithRed:.8 green:.2 blue:.2 alpha:1]; //Gray
        self.connectionResultLbl.text = slowonlyAudio;
        
    }else if ((uploadSpeed <= screenUpObj.valueTo && uploadSpeed > screenUpObj.valueFrom) || (downloadSpeed <= screenDownObj.valueTo && downloadSpeed > screenDownObj.valueFrom))
    {
        self.audioView.backgroundColor = [UIColor colorWithRed:.4 green:.7 blue:.2 alpha:1];
        self.videoView.backgroundColor = [UIColor colorWithRed:.8 green:.2 blue:.2 alpha:1];
        self.screenShareView.backgroundColor = [UIColor colorWithRed:.4 green:.7 blue:.2 alpha:1];
        self.connectionResultLbl.text = averageaudioViewScreen;
        
    }else if ((uploadSpeed > videoUpObj.valueFrom) || (downloadSpeed > videoDownObj.valueFrom))
    {
        self.audioView.backgroundColor = [UIColor colorWithRed:.4 green:.7 blue:.2 alpha:1];
        self.videoView.backgroundColor = [UIColor colorWithRed:.4 green:.7 blue:.2 alpha:1];
        self.screenShareView.backgroundColor = [UIColor colorWithRed:.4 green:.7 blue:.2 alpha:1];
        self.connectionResultLbl.text = fastaudiovideoviewScreen;
        
    }else
    {
        self.audioView.backgroundColor = [UIColor colorWithRed:.8 green:.2 blue:.2 alpha:1];
        self.videoView.backgroundColor = [UIColor colorWithRed:.8 green:.2 blue:.2 alpha:1];
        self.screenShareView.backgroundColor = [UIColor colorWithRed:.8 green:.2 blue:.2 alpha:1];
        
        self.connectionResultLbl.text = STRING_FOR_LANGUAGE(@"Connection.Speed");
    }

    [self.RefreshButtonRef setEnabled:YES];
    [self buttonColourAccordingtotheme];

}


-(void)buttonColourAccordingtotheme
{
    NSInteger index = [[NSUserDefaults standardUserDefaults]integerForKey:BACKGROUND_THEME_VALUE];
    if (index == 0) {
        [self.RefreshButtonRef setBackgroundColor:[UIColor colorWithRed:.13 green:.31 blue:.46 alpha:1]];
    }
    else if (index == 1)
    {
        [self.RefreshButtonRef setBackgroundColor:[UIColor colorWithRed:.55 green:.7 blue:.31 alpha:1]];
        
    }
    else if (index ==2)
    {
        [self.RefreshButtonRef setBackgroundColor:[UIColor colorWithRed:.9 green:.45 blue:.23 alpha:1]];
        
    }
    else if (index == 3)
    {
        [self.RefreshButtonRef setBackgroundColor:[UIColor colorWithRed:.76 green:.06 blue:.29 alpha:1]];
    }
    
    


}





- (NSString *)filePathForURLString:(NSURL *)url
{
    NSString *filename = @"image";
    NSLog(@"Filename: %@", filename);
    return [NSString stringWithFormat:@"%@/%@", downloadDirectoryPath, filename];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)postman:(Postman *)postman gotSuccess:(NSData *)response forURL:(NSString *)urlString
{
    
}

- (void)postman:(Postman *)postman gotFailure:(NSError *)error forURL:(NSString *)urlString
{
    
}

@end
