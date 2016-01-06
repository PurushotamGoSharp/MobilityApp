//
//  DownloadManager.m
//  SimplicITy
//
//  Created by Varghese Simon on 2/6/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "DownloadManager.h"
#import <AFNetworking/AFNetworking.h>
#import "FileLoadViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"

@interface DownloadManager () <UIAlertViewDelegate>

@end

@implementation DownloadManager
{
    AFURLSessionManager *manager;
    NSString *downloadDirectoryPath;
    NSString *filePath;
}

+ (instancetype)sharedDownloadManager
{
    static DownloadManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        _sharedManager = [[DownloadManager alloc] init];
        
    });
    
    return _sharedManager;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    
    downloadDirectoryPath = [NSString stringWithFormat:@"%@/Downloads/", documentsDirectoryPath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:downloadDirectoryPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:downloadDirectoryPath withIntermediateDirectories:NO attributes:nil error:nil];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
}

- (void)downloadFromURLString:(NSString *)URLString
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = @"Downloading";
    
    NSURL *URL = [NSURL URLWithString:URLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    filePath = [self filePathForURLString:URL];

//    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request
//                                                                     progress:nil
//                                                                  destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
//                                                                      
//                                                                      NSString *filePath = [downloadDirectoryPath stringByAppendingString:[response suggestedFilename]];
//
//                                                                      NSLog(@"first file path = %@", filePath);
//                                                                      
//                                                                      if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
//                                                                      {
//                                                                          NSLog(@"File already exists");
//                                                                      }
//                                                                      
//                                                                      return [NSURL URLWithString:filePath];
//                                                                  }
//                                                            completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
//                                                                
//                                                                NSLog(@"%@", error);
//                                                                NSLog(@"file path = %@", filePath);
//                                                                
//                                                            }];
//    
//    [downloadTask resume];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [hud hide:YES];

        NSLog(@"Successfully downloaded file to %@", filePath);
//        UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@""
//                                                               message:@"Downloading is finished"
//                                                              delegate:self
//                                                     cancelButtonTitle:@"OK"
//                                                     otherButtonTitles:nil];
//        [successAlert show];
        
        [self loadDownloadedFile];
        
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         
//                                         UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"Error!" message:[NSString stringWithFormat:@"%@",error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil ];
//                                         [alert show];
                                         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString]];

                                         [hud hide:YES];

                                         
                                     }];
    [operation start];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        
        float progress = ((float)totalBytesRead) / totalBytesExpectedToRead;
        NSLog(@"status %f",progress);
        hud.progress = progress;
        
        // self.progressView.progress = progress;
        
    }];

}

- (NSString *)filePathForURLString:(NSURL *)url
{
    NSString *filename = url.lastPathComponent;
    NSLog(@"Filename: %@", filename);
    
    
    return [NSString stringWithFormat:@"%@/%@", downloadDirectoryPath, filename];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self loadDownloadedFile];
}

- (void)loadDownloadedFile
{
    UIStoryboard *storyboard;
    if ([ UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    }else
    {
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    }
    
    UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"FileLoadVCStoryboardID"];
    FileLoadViewController *fileLoadVC = navController.viewControllers[0];
    fileLoadVC.pathOfFile = filePath;
    UINavigationController *rootVC = (UINavigationController *) [(AppDelegate *) [UIApplication sharedApplication].delegate window].rootViewController;
    
    NSLog(@"TOp viewcontroller = %@", NSStringFromClass([rootVC.topViewController class]));
    [rootVC.topViewController presentViewController:navController
                                           animated:YES
                                         completion:^{
                                             
                                         }];
}

@end
