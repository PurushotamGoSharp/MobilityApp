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
                    NSMutableString *textValue = [adict[@"Name"] mutableCopy];
                    [textValue replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:NSCaseInsensitiveSearch range:(NSMakeRange(0, textValue.length))];

                    if (isFirst) {
                        jsonString =[NSString stringWithFormat:@"\"%@\":\"%@\"",adict[@"UserFriendlyCode"],textValue];
                        isFirst = NO;
                    } else {
                        jsonString =[NSString stringWithFormat:@",\"%@\":\"%@\"",adict[@"UserFriendlyCode"],textValue];
                    }
                    mainJsonString = [mainJsonString stringByAppendingString:jsonString];
                }
            }
            NSString *jsonStringmain =[NSString stringWithFormat:@"{\%@}",mainJsonString];
//            NSLog(@"%@",jsonStringmain);
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
        [self readLanguageFileFromDocumentDirectory:YES];
    
    } else {
        [self.delegate failourResponseDelegateMethod];
    }

}



-(void)readLanguageFileFromDocumentDirectory:(BOOL)callingFromAPI
{
    NSString *langCode =  [[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedLanguageCode"];
    NSFileManager *fmngr = [[NSFileManager alloc] init];
    self.languageUrlPairs = [[NSMutableDictionary alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // grab all the files in the documents dir
    NSString *destinationPath = [documentsDirectory stringByAppendingPathComponent:@"Languages"];
    
    NSArray *allFiles = [fmngr contentsOfDirectoryAtPath:destinationPath error:nil];
    // filter the array for only json files
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
    NSArray *jsonFiles = [allFiles filteredArrayUsingPredicate:fltr];
    NSString *names = nil;
    // use fast enumeration to iterate the array and delete the files
    for (NSString *aJsonFile in jsonFiles)
    {
        NSString *fileNm = [destinationPath stringByAppendingPathComponent:aJsonFile];
        names = [aJsonFile stringByDeletingPathExtension];
        NSURL *filePathUrl = [NSURL fileURLWithPath:fileNm];
        [self.languageUrlPairs setObject:filePathUrl forKey:names];
    }
   
    
//    NSLog(@"Dict %@",[self.languageUrlPairs allKeys]);
    [MCLocalization loadFromLanguageURLPairs:self.languageUrlPairs defaultLanguage:@"en"];
    [MCLocalization sharedInstance].noKeyPlaceholder = @"[No '{key}' in '{language}']";
    [MCLocalization sharedInstance].language = langCode;

    if (callingFromAPI)
    {
        [self.delegate successResponseDelegateMethod];
    }
    NSString *seedKeyForLang = [NSString stringWithFormat:@"uilabel,%@", langCode];
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:seedKeyForLang];

}






@end
