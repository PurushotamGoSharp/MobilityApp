//
//  AboutViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 27/01/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "AboutViewController.h"
#import "DBManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "RateView.h"

#define FEEDBACK_API @"http://simplicitytst.ripple-io.in/Rating/Corp123"

#define ALERT_FOR_RATING @"Thank you for Rating the App"


@interface AboutViewController () <postmanDelegate, DBManagerDelegate,RateViewDelegate,UITextViewDelegate>
{
    UIBarButtonItem *backButton;
    NSString *URLString;
    Postman *postMan;
    DBManager *dbManager;
    
    NSString *aboutDescription;
    NSString *ucbLogoDocCode;
    NSString *vmokshaLogoDocCode;
    
    CGPoint initialOffsetOfSCrollView;
    UIEdgeInsets initialScollViewInset;
    BOOL reviewBtnIsSelected;
    
    CGFloat averageRating;
    UIFont *describtionFont;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet RateView *rateView;
@property (weak, nonatomic) IBOutlet UIImageView *leftSideImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightSideImageView;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *rateButton;
@property (weak, nonatomic) IBOutlet UILabel *aboutUsLabel;
@property (weak, nonatomic) IBOutlet UILabel *averageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionHeightConst;

@property (weak, nonatomic) IBOutlet RateView *yourRatingView;

@property (weak, nonatomic) IBOutlet UILabel *avgRateLable;
@property (weak, nonatomic) IBOutlet UILabel *yourRateLbl;
@property (weak, nonatomic) IBOutlet UILabel *avgRatValueLbl;
@property (weak, nonatomic) IBOutlet UILabel *yourRateValueLbl;
@property (weak, nonatomic) IBOutlet UILabel *totalLbl;
@property (weak, nonatomic) IBOutlet UILabel *clickToRateLbl;

@property (weak, nonatomic) IBOutlet UIView *writeReviewAlphaView;

@property (weak, nonatomic) IBOutlet UITextView *writeReviewTxtView;
@property (weak, nonatomic) IBOutlet UIButton *writeReviewBtnOutlet;
@property (weak, nonatomic) IBOutlet UILabel *writeReviewLbl;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *writeReviewTextFldBtmConst;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *tickMarkBarBtnOutlet;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *writeReviewTextFldHeightConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomConst;
@end

@implementation AboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [back setImage:[UIImage imageNamed:@"back_Arrow"] forState:UIControlStateNormal];
    [back setTitle:@"Home" forState:UIControlStateNormal];
    back.titleLabel.font = [self customFont:16 ofName:MuseoSans_700];
    
    back.imageEdgeInsets = UIEdgeInsetsMake(0, -45, 0, 0);
    back.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
    back.frame = CGRectMake(0, 0,80, 30);
    
    [back setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [back  addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    backButton = [[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.rateView.notSelectedImage = [UIImage imageNamed:@"starEmpty.png"];
    self.rateView.fullSelectedImage = [UIImage imageNamed:@"starFull.png"];
    self.rateView.rating = 0;
    self.rateView.editable = NO;
    self.rateView.maxRating = 5;
    
    self.descriptionTextView.editable = YES;
    describtionFont = [self customFont:14 ofName:MuseoSans_300];
    [self.descriptionTextView setFont:describtionFont];
    self.descriptionTextView.editable = NO;

    self.rateButton.titleLabel.font = [self customFont:16 ofName:MuseoSans_700];
    self.aboutUsLabel.font = [self customFont:16 ofName:MuseoSans_700];
    
    self.rateButton.layer.cornerRadius = 10;
    
    
    self.yourRatingView.notSelectedImage = [UIImage imageNamed:@"starEmpty.png"];
    // self.rateView.halfSelectedImage = [UIImage imageNamed:@"kermit_half.png"];
    self.yourRatingView.fullSelectedImage = [UIImage imageNamed:@"starFull.png"];
    self.yourRatingView.rating = 0;
    self.yourRatingView.editable = YES;
    self.yourRatingView.maxRating = 5;
    self.yourRatingView.delegate = self;
    
    
    self.avgRateLable.font = [self customFont:16 ofName:MuseoSans_700];
    self.yourRateLbl.font = [self customFont:16 ofName:MuseoSans_700];
    self.avgRatValueLbl.font = [self customFont:30 ofName:MuseoSans_700];
    self.yourRateValueLbl.font = [self customFont:30 ofName:MuseoSans_700];
    self.totalLbl.font = [self customFont:14 ofName:MuseoSans_300];
    self.clickToRateLbl.font = [self customFont:14 ofName:MuseoSans_300];
    
    self.writeReviewLbl.font = [self customFont:16 ofName:MuseoSans_700];


    self.writeReviewAlphaView.layer.cornerRadius = 15;
    self.writeReviewTxtView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.writeReviewTxtView.layer.borderWidth = 1;
    
    URLString = ABOUT_DETAILS_API;
    
    postMan = [[Postman alloc] init];
    postMan.delegate = self;
    
    if ([AFNetworkReachabilityManager sharedManager].isReachable)
    {
        if ([[NSUserDefaults standardUserDefaults]boolForKey:@"aboutus"])
        {
            [self tryUpdateAboutDeatils];
            
        }else
        {
            averageRating = [[NSUserDefaults standardUserDefaults] integerForKey:@"averageRatingKey"];
            [self  getData];
        }
    }
    else
    {
        averageRating = [[NSUserDefaults standardUserDefaults] integerForKey:@"averageRatingKey"];
        [self  getData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (IBAction)tickMarkBarBtnAction:(id)sender
{
    [self.view endEditing:YES];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

//    self.writeReviewTxtView.text = @"Nice";
    
    
//    NSString *parameter = @"{\"request\":{\"CorpId\":\"Corp123\",\"Rating\":\"2\",\"Feedback\":\"Good\"}}";
    
  NSString  *parameter = [NSString stringWithFormat:@"{\"request\":{\"CorpId\":\"Corp123\",\"Rating\":\"%@\",\"Feedback\":\"%@\"}}", self.yourRateValueLbl.text, self.writeReviewTxtView.text];
    
    [postMan post:FEEDBACK_API withParameters:parameter];
    
    self.yourRatingView.rating = 0;
    self.yourRateValueLbl.text = @"0";
}

- (void)rateView:(RateView *)rateView ratingDidChange:(float)rating
{
    [self.view endEditing:YES];
    if (self.writeReviewTxtView.text.length > 0 && self.yourRatingView.rating > 0)
    {
        self.tickMarkBarBtnOutlet.enabled = YES;
    }else
    {
        self.tickMarkBarBtnOutlet.enabled = NO;
    }
    
    self.yourRateValueLbl.text = [NSString stringWithFormat:@"%i",(int)rating];
}

- (void)viewWillAppear:(BOOL)animated
{
    reviewBtnIsSelected = NO;
    
    [super viewWillAppear:animated];
    
    [self updateUI];
    
    [self.rateButton setBackgroundColor:[self barColorForIndex:[[NSUserDefaults standardUserDefaults] integerForKey:BACKGROUND_THEME_VALUE]]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
    
    self.yourRatingView.rating = 0;
    self.yourRateValueLbl.text = @"0";

}

- (void)backBtnAction
{
    [self.tabBarController setSelectedIndex:0];
}

- (void)tryUpdateAboutDeatils
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *parameter = @"{\"request\":{\"LanguageCode\":\"\"}}";
    [postMan post:URLString withParameters:parameter];
    
    [postMan get:AVERAGE_RATING_API];
}

- (IBAction)writeReviewBtnAction:(id)sender
{
    if (!reviewBtnIsSelected)
    {
        self.writeReviewTxtView.hidden = NO;
        
        [UIView animateWithDuration:.3 animations:^{
            
            self.writeReviewTextFldHeightConst.constant = 75;
            [self.view layoutIfNeeded];
            
        } completion:^(BOOL finished)
         {
             reviewBtnIsSelected = YES;
         }];
    }else
    {
        [UIView animateWithDuration:.3 animations:^
         {
             self.writeReviewTextFldHeightConst.constant = 0;
             [self.view layoutIfNeeded];
             
         } completion:^(BOOL finished) {
             self.writeReviewTxtView.hidden = YES;
//             self.writeReviewBtnOutlet.selected = NO;
             
             reviewBtnIsSelected=NO;
         }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUI
{
    self.rateView.rating = averageRating;
    self.avgRatValueLbl.text = [NSString stringWithFormat:@"%.1f",averageRating];
    
//    self.leftSideImageView.image = [self getimageForDocCode:ucbLogoDocCode];
//    self.rightSideImageView.image = [self getimageForDocCode:vmokshaLogoDocCode];
//
    NSString *testString = aboutDescription;
    self.descriptionTextView.text = testString;
    
    self.descriptionTextView.selectable = YES;
    CGSize expectedSize = [testString boundingRectWithSize:(CGSizeMake(self.descriptionTextView.frame.size.width, 10000))
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName: describtionFont}
                                                   context:nil].size;
    self.descriptionTextView.selectable = NO;

    self.descriptionHeightConst.constant = expectedSize.height + 20;
    [self.view layoutIfNeeded];
}

- (void)orientationChanged:(NSNotification *)notification
{
    [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation
{
    [self hideKeyboard:nil];
    [self updateUI];
}

#pragma mark
#pragma mark postmanDelegate

- (void)postman:(Postman *)postman gotSuccess:(NSData *)response forURL:(NSString *)urlString
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    if ([urlString isEqualToString:ABOUT_DETAILS_API])
    {
        [self parseResponsedata:response andgetImages:YES];
        [self saveAboutDetailsData:response forURL:urlString];
        
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"aboutus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }else if ([urlString isEqualToString:FEEDBACK_API])
    {
        [self parseFeedbackData:response];
        
    }else if ([urlString isEqualToString:AVERAGE_RATING_API])
    {
        [self parseAvgRating:response];
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
    [self updateUI];
}

- (void)parseFeedbackData:(NSData *)response
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    NSLog(@"FeedBack %@",json);
    
    NSDictionary *suecss = json[@"aaData"];
    
    if ([suecss[@"Success"] boolValue])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!" message:ALERT_FOR_RATING delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)parseAvgRating:(NSData *)response
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];

    if ([json[@"aaData"][@"Success"] boolValue])
    {
        averageRating = [json[@"aaData"][@"AverageRating"][@"AverageRating"] integerValue];
        [[NSUserDefaults standardUserDefaults] setInteger:averageRating forKey:@"averageRatingKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self updateUI];
}

- (void)parseResponsedata:(NSData *)response andgetImages:(BOOL)download
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    NSArray *arr = json[@"aaData"][@"AboutUs"];
    
    for (NSDictionary *aDict in arr)
    {
        if ([aDict[@"Status"] boolValue])
        {
            if (download || [[NSUserDefaults standardUserDefaults] boolForKey:@"document"])
            {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                aboutDescription = aDict[@"Description"];
                
                ucbLogoDocCode = aDict[@"UCBLogo_DocumentCode"];
                NSString *imageUrl = [NSString stringWithFormat:RENDER_DOC_API, ucbLogoDocCode];
                [postMan get:imageUrl];
                
                vmokshaLogoDocCode = aDict[@"VmokshaLogo_DocumentCode"];
                imageUrl = [NSString stringWithFormat:RENDER_DOC_API, vmokshaLogoDocCode];
                [postMan get:imageUrl];
            }
        }
        
        NSString *language = aDict[@"Language"];
        if ([language isEqualToString:@"English"])
        {
            break;
        }
    }
    
    [self updateUI];
}

- (void)saveAboutDetailsData:(NSData *)response forURL:(NSString *)APILink
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate=self;
    }
    
    NSString *createQuery = @"create table if not exists aboutDetails (API text PRIMARY KEY, data text)";
    [dbManager createTableForQuery:createQuery];
    
    NSMutableString *stringFromData = [[NSMutableString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSRange rangeofString;
    rangeofString.location = 0;
    rangeofString.length = stringFromData.length;
    [stringFromData replaceOccurrencesOfString:@"'" withString:@"''" options:(NSCaseInsensitiveSearch) range:rangeofString];
    
    NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO  aboutDetails (API,data) values ('%@', '%@')", APILink,stringFromData];
    
    [dbManager saveDataToDBForQuery:insertSQL];
}

- (void)getData
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate=self;
    }
    
    NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM aboutDetails WHERE API = '%@'", URLString];
    if (![dbManager getDataForQuery:queryString])
    {
        if (![AFNetworkReachabilityManager sharedManager].reachable)
        {
            UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:WARNING_TEXT message:INTERNET_IS_REQUIRED_TO_SYNC_DATA delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [noNetworkAlert show];
        }
        
        [self tryUpdateAboutDeatils];
    }
}

#pragma mark
#pragma mark DBManagerDelegate
- (void)DBManager:(DBManager *)manager gotSqliteStatment:(sqlite3_stmt *)statment
{
    if (sqlite3_step(statment) == SQLITE_ROW)
    {
        NSString *string = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 1)];
        
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        
        [self parseResponsedata:data andgetImages:NO];
    }
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
    
    [self updateUI];
}

- (UIImage *)getimageForDocCode:(NSString *)docCode
{
    NSString *pathToDoc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [pathToDoc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@@2x.png", docCode]];
    
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    
    if (imageData)
    {
        UIImage *tempImage = [UIImage imageWithData:imageData];
        UIImage *image = [UIImage imageWithCGImage:tempImage.CGImage scale:2 orientation:tempImage.imageOrientation] ;
        
        return image;
    }
    
    return nil;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    UIInterfaceOrientation orientaition = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientaition == UIInterfaceOrientationPortrait || orientaition == UIDeviceOrientationPortraitUpsideDown)
    {
        self.scrollViewBottomConst.constant = 180;
        
    }else if (orientaition == UIDeviceOrientationLandscapeRight || orientaition == UIDeviceOrientationLandscapeLeft)
    {
        self.scrollViewBottomConst.constant = 130;
    }
    
    [self.view layoutIfNeeded];
    
    [self.scrollView scrollRectToVisible:textView.frame animated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.scrollViewBottomConst.constant = 0;
    [self.view layoutIfNeeded];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([textView isEqual:self.writeReviewTxtView])
    {
        NSString *expectedString = [textView.text stringByReplacingCharactersInRange:range withString:text];
        
        if (expectedString.length > 0 && self.yourRatingView.rating > 0)
        {
            self.tickMarkBarBtnOutlet.enabled = YES;
        }else
        {
            self.tickMarkBarBtnOutlet.enabled = NO;
        }
    }

    return YES;
}

- (IBAction)hideKeyboard:(UIView *)sender
{
    [self.view endEditing:YES];
}

@end
