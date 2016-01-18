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

#define NULL_CHECKER(X) ([X isKindOfClass:[NSNull class]] ? nil : X)

@interface LyncConnectionCheckerViewController ()<postmanDelegate>

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
    
    LyncConfigModel *audioUpObj, *audioDownObj, *videoUpObj, *videoDownObj, *screenUpObj, *screenDownObj;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = STRING_FOR_LANGUAGE(@"Ping My Lync");
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    
    self.connectionSpeedLbl.font = [self customFont:20 ofName:MuseoSans_300];
    self.downloadLbl.font = [self customFont:26 ofName:MuseoSans_700];
    self.uploadlbl.font = [self customFont:26 ofName:MuseoSans_700];
    self.connectionResultLbl.font = [self customFont:16 ofName:MuseoSans_700];
    self.AudioLbl.font = [self customFont:16 ofName:MuseoSans_300];
    self.videoLbl.font = [self customFont:16 ofName:MuseoSans_300];
    self.screenShareLbl.font = [self customFont:16 ofName:MuseoSans_300];
    
    fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.#"];
    
    
    
    if ([AFNetworkReachabilityManager sharedManager].isReachable)
    {
        [self callConfigAPI];
        [self callAPI];
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Internet connection is required" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
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
             [MBProgressHUD hideHUDForView:self.view animated:YES];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
         }];
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
                                                 self.uploadlbl.text = [NSString stringWithFormat:@"%@ MB",[fmt stringFromNumber:[NSNumber numberWithFloat:speedInKb/1024]] ];
                                             }else
                                             {
                                                 self.uploadlbl.text = [NSString stringWithFormat:@"%@ KB",[fmt stringFromNumber:[NSNumber numberWithFloat:speedInKb]] ];
                                             }
                                             NSLog(@"file upload Sucess");
                                             
                                             NSData *responseData = [operation responseData];
                                             
                                             NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
                                             NSLog(@"JSOn %@",json);
                                             
                                             NSString *JSONString = json[@"aaData"][@"JSON"];
                                             
                                             NSDictionary *dictFromJSON = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                                             
                                             fileId = dictFromJSON[@"Code"];
                                             docId = [dictFromJSON[@"ID"] intValue];
                                             
                                             [self downloadImageByCode:fileId];
                                             
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                         {
                                             NSLog(@"file upload failure error %@",error);
                                             [hud hide:YES];
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
             self.downloadLbl.text = [NSString stringWithFormat:@"%@ MB",[fmt stringFromNumber:[NSNumber numberWithFloat:speedInKb/1024]] ];
             
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
        
        self.connectionResultLbl.text = STRING_FOR_LANGUAGE(@"Slow- only Audio is recommended");
        
    }else if ((uploadSpeed <= videoUpObj.valueTo && uploadSpeed > videoUpObj.valueFrom) || (downloadSpeed <= videoDownObj.valueTo && downloadSpeed > videoDownObj.valueFrom))
    {
        self.audioView.backgroundColor = [UIColor colorWithRed:.4 green:.7 blue:.2 alpha:1];
        self.videoView.backgroundColor = [UIColor colorWithRed:.8 green:.2 blue:.2 alpha:1];
        self.screenShareView.backgroundColor = [UIColor colorWithRed:.4 green:.7 blue:.2 alpha:1];
        self.connectionResultLbl.text = STRING_FOR_LANGUAGE(@"Average- Audio and View Screen are recommended");
        
    }else if ((uploadSpeed <= screenUpObj.valueTo && uploadSpeed > screenUpObj.valueFrom) || (downloadSpeed <= screenDownObj.valueTo && downloadSpeed > screenDownObj.valueFrom))
    {
        self.audioView.backgroundColor = [UIColor colorWithRed:.4 green:.7 blue:.2 alpha:1];
        self.videoView.backgroundColor = [UIColor colorWithRed:.4 green:.7 blue:.2 alpha:1];
        self.screenShareView.backgroundColor = [UIColor colorWithRed:.4 green:.7 blue:.2 alpha:1];
        
        self.connectionResultLbl.text = STRING_FOR_LANGUAGE(@"Fast- Audio, Video and View Screen are recommended");
        
    }else
    {
        self.audioView.backgroundColor = [UIColor colorWithRed:.8 green:.2 blue:.2 alpha:1];
        self.videoView.backgroundColor = [UIColor colorWithRed:.8 green:.2 blue:.2 alpha:1];
        self.screenShareView.backgroundColor = [UIColor colorWithRed:.8 green:.2 blue:.2 alpha:1];
        
        self.connectionResultLbl.text = STRING_FOR_LANGUAGE(@"Connection Speed");
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
