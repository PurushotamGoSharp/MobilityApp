//
//  ADExpirationViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/19/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "ADExpirationViewController.h"
#import "UserInfo.h"
#import <MBProgressHUD/MBProgressHUD.h>
//#import <WatchConnectivity/WatchConnectivity.h>


#define DAYS_LEFT_FOR_PASSWORD_EXPIRES @"DaysLeftForPasswordExpairs"
#define IPHONE_6_CROPID  @""
#import "NSDateFormatter+Locale.h"

@interface ADExpirationViewController () <NSURLConnectionDelegate>
@property (weak, nonatomic) IBOutlet UILabel *passwordToolLabel;
@property (weak, nonatomic) IBOutlet UILabel *numOfDaysLeftLbl;
@property (weak, nonatomic) IBOutlet UILabel *dayleftForpasswordExpPlaceholder;

@end

@implementation ADExpirationViewController
{
    UIBarButtonItem *backButton;
    NSString *dayString;
    NSDictionary *serverConfig;
    UIButton *back;
}

- (void)viewDidLoad
{
   // interfaceClassObj=[[InterfaceController alloc]init];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([AFNetworkReachabilityManager sharedManager].isReachable)
    {
        serverConfig = [[UserInfo sharedUserInfo] getServerConfig];
        NSString *cropID;
        NSString *urlString;
        if (serverConfig != nil)
        {
            cropID = (NSString *)serverConfig[@"corpID"];
           urlString = [LDAP_URL stringByAppendingString:cropID];
        }
        else
        {
            urlString = [LDAP_URL stringByAppendingString:IPHONE_6_CROPID];
        }
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        
        NSURLConnection *connections = [[NSURLConnection alloc] initWithRequest:req delegate:self];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    else
    {
        self.numOfDaysLeftLbl.text = [[NSUserDefaults standardUserDefaults] objectForKey:DAYS_LEFT_FOR_PASSWORD_EXPIRES];
        
//        UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:@"Warning !" message:@"The device is not connected to internet. For checking \"Days Left  for Password Expiry\" Internet connection is required" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [noNetworkAlert show];
        


    }

    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localize) name:MCLocalizationLanguageDidChangeNotification object:nil];
    [self localize];
   
    
}

-(void)localize
{
    self.title = STRING_FOR_LANGUAGE(@"Password_Expiry");
  [back setTitle:STRING_FOR_LANGUAGE(@"Home") forState:UIControlStateNormal];
    self.passwordToolLabel.text = STRING_FOR_LANGUAGE(@"Password.Tool");
    self.dayleftForpasswordExpPlaceholder.text = STRING_FOR_LANGUAGE(@"Days.Expiry");
    [back sizeToFit];

}



- (void)backBtnAction
{
//    [self.tabBarController setSelectedIndex:0];
    //    self.writeReviewTxtView.text = @"";
    //    [self hideWriteReviewTextView];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)identity:(SecIdentityRef *)identity andCertificate:(SecCertificateRef *)certificate forPKC12Data:(NSData *)certData withPassphrase:(NSString *)passphrase
{
    // bridge the import data to foundation objects
    CFStringRef importPassphrase = (__bridge CFStringRef)passphrase;
    CFDataRef importData = (__bridge CFDataRef)certData;
    
    // create dictionary of options for the PKCS12 import
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { importPassphrase };
    CFDictionaryRef importOptions = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    
    // create array to store our import results
    CFArrayRef importResults = CFArrayCreate(NULL, 0, 0, NULL);
    OSStatus pkcs12ImportStatus = errSecSuccess;
    pkcs12ImportStatus = SecPKCS12Import(importData, importOptions, &importResults);
    
    // check if import was successful
    if (pkcs12ImportStatus == errSecSuccess)
    {
        CFDictionaryRef identityAndTrust = CFArrayGetValueAtIndex (importResults, 0);
        
        // retrieve the identity from the certificate imported
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue (identityAndTrust, kSecImportItemIdentity);
        *identity = (SecIdentityRef)tempIdentity;
        
        // extract the certificate from the identity
        SecCertificateRef tempCertificate = NULL;
        OSStatus certificateStatus = errSecSuccess;
        certificateStatus = SecIdentityCopyCertificate (*identity, &tempCertificate);
        *certificate = (SecCertificateRef)tempCertificate;
    }else
    {
        NSLog(@"Status is %d", (int)pkcs12ImportStatus);
    }
    
    // clean up
    if (importOptions)
    {
        CFRelease(importOptions);
    }
}

#pragma mark:
#pragma mark NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    
    NSString *certPath = [[NSBundle mainBundle] pathForResource:@"cert" ofType:@"p12"];
    NSData *certData = [[NSData alloc] initWithContentsOfFile:certPath];
    
    SecIdentityRef identity = NULL;
    SecCertificateRef certificate = NULL;
    
    [self identity:&identity
              andCertificate:&certificate
                forPKC12Data:certData
              withPassphrase:@"test"];
    
    NSURLCredential *credential = [NSURLCredential credentialWithIdentity:identity
                                                             certificates:@[(__bridge id)certificate] persistence:NSURLCredentialPersistencePermanent];
    if (credential)
    {
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
    }else
    {
        NSLog(@"Error in credential");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"Success....");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"string %@ ",string);
    
    [self parseresponseData:data];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return YES;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:STRING_FOR_LANGUAGE(@"Error")
                                                  message:STRING_FOR_LANGUAGE(@"Contact.Administrator")
                                                 delegate:self
                                        cancelButtonTitle:OK_FOR_ALERT
                                        otherButtonTitles:nil];
    
    [alert show];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    
}

-(void)parseresponseData:(NSData *)data
{
//    NSDate *currentDate = [NSDate date];
    
    //    NSCalendar *cal = [NSCalendar currentCalendar];
    //    NSLog(@"%@", [NSTimeZone knownTimeZoneNames]);
    
//    NSDateFormatter *formater = [[NSDateFormatter alloc] initWithSafeLocale];
    
//    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSInteger daysLeftToExpire = [json[@"password-expires-days"] integerValue];

    NSLog(@"%@",json);
    self.numOfDaysLeftLbl.text = [NSString stringWithFormat:@"%li",(long) daysLeftToExpire];
    NSLog(@"days left ids.....%@",self.numOfDaysLeftLbl.text);
    
//
//    NSString *dateInString = json[@"password-expires"];
//    
//    NSDate *passwordExpiresDate = [formater dateFromString:dateInString];
//    
//    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:currentDate toDate:passwordExpiresDate options:0];
//    
//    NSLog(@"Password Expires Date is %@ and current Date is %@",passwordExpiresDate,currentDate);
//    
//    NSLog(@"The difference between from date and to date is %ld days and %ld hours and %ld minute and %ld second",(long)components.day,(long)components.hour,(long)components.minute,(long)components.second);
//    
//   NSInteger daysLeft =  MAX(0, components.day);
//    NSLog(@"%li",(long)daysLeft);
    

//   
//    NSString *dayLeft = [self.numOfDaysLeftLbl text];
//   
//    
////    [[NSUserDefaults standardUserDefaults] setObject:self.numOfDaysLeftLbl.text forKey:DAYS_LEFT_FOR_PASSWORD_EXPIRES];
////    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//    
//     serverConfig = [[UserInfo sharedUserInfo] getServerConfig];
//    
//    NSUserDefaults *myDefaults = [[NSUserDefaults alloc]
//                                  initWithSuiteName:@"group.com.ucb.app.SimplicITy"];
//    
//     serverConfig= [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"corpID"];
//    
//   // NSDictionary *retrievedDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"DicKey"];
//    [myDefaults setObject:serverConfig forKey:@"dayLeft"];
//     NSLog (@"myDict has been set");
//    
//    [myDefaults synchronize];
////
//    NSLog(@"Data Saved");
////    
////    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
////    NSDictionary* my_dict = [NSDictionary dictionaryWithObject: @"value" forKey: @"key"];
////    [defaults setObject: my_dict forKey: @"myDict"];
////    NSLog (@"myDict has been set");
}


- (IBAction)paswordSelfServiceBtnPressed:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://mdm2.ucb.com/psynch/docs/en-us/indexf.html"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController popViewControllerAnimated:YES];
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
