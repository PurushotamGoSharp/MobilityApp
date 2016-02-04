//
//  LanguageChangerClass.m
//  SimplicITy
//
//  Created by Saurabh on 2/3/16.
//  Copyright © 2016 Vmoksha. All rights reserved.
//

#import "LanguageChangerClass.h"
#import "Postman.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface LanguageChangerClass()<postmanDelegate>
{
    Postman *postMan;
    NSString *mainJsonString;
}
@end



@implementation LanguageChangerClass





-(void)changeLanguageWithCode:(NSString*)langCode
{
    postMan = [[Postman alloc] init];
    postMan.delegate = self;
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",LANGUAGE_CHANGE_API,langCode];
    
    [postMan get:urlString success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *responseData =[operation responseData];
        NSDictionary *responseDict =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        //[self.delegate responseDictionaryForLanguage:responseDict];
      [self parsingMethodForResponseOflanguage:responseDict andlangCode:langCode];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     [self.delegate failourResponseDelegateMethod];
    }];
    
}

-(void)parsingMethodForResponseOflanguage:(NSDictionary *)responseDict andlangCode:(NSString *)langCode
{
    NSDictionary *responseDictionary = responseDict;
    if ([responseDictionary[@"aaData"][@"Success"]boolValue]) {
        BOOL isFirst;
        isFirst = YES;
        NSArray *mainArr = responseDict[@"aaData"][@"UILabels"];
        {
            mainJsonString = [[NSString alloc]init];
            for (NSMutableDictionary *adict in mainArr) {
                if ([adict[@"Status"]boolValue]) {
                    NSString *jsonString;
                    if (isFirst) {
                        jsonString =[NSString stringWithFormat:@"\"%@\":\"%@\"",adict[@"UserFriendlyCode"],adict[@"Name"]];
                        isFirst = NO;
                    } else {
                        jsonString =[NSString stringWithFormat:@",\"%@\":\"%@\"",adict[@"UserFriendlyCode"],adict[@"Name"]];
                    }
                    mainJsonString = [mainJsonString stringByAppendingString:jsonString];
                }
            }
            NSString *jsonStringmain =[NSString stringWithFormat:@"{\%@}",mainJsonString];
            NSLog(@"%@",jsonStringmain);
            [self createFolderinDocument:langCode andJsonString:jsonStringmain];
        }
    }
    else
    {
        [self.delegate failourResponseDelegateMethod];
    }
}

-(void)createFolderinDocument:(NSString *)langCode andJsonString:(NSString *)jsonString
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/Languages"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
    }
    NSString *filePath =[dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json",langCode]];
    [jsonString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (fileExists) {
        [self.delegate successResponseDelegateMethod];
    } else {
        [self.delegate failourResponseDelegateMethod];
    }

}








@end
