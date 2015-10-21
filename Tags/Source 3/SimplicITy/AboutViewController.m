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
#import "UserInfo.h"
#import <AFNetworking/AFNetworking.h>

#import <MCLocalization/MCLocalization.h>



#define ALERT_FOR_RATING @"Thank you for Rating the App"
#define FEEDBACK_IN_OFFLINE @"Device is not connected to internet. Your feedback will be posted automatically once device connects to internet"


@interface AboutViewController () <postmanDelegate, DBManagerDelegate,RateViewDelegate,UITextViewDelegate, UIWebViewDelegate>
{
    NSString *URLString;
    Postman *postMan;
    DBManager *dbManager;
    UIBarButtonItem *backButton;

    
    NSString *aboutDescription;
    NSString *ucbLogoDocCode;
    NSString *vmokshaLogoDocCode;
    
    CGPoint initialOffsetOfSCrollView;
    UIEdgeInsets initialScollViewInset;
    BOOL reviewBtnIsSelected;
    
    NSInteger yourRatingValue;
    NSInteger totalNoOfUserRated;
    CGFloat averageRating;
    UIFont *describtionFont;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet RateView *rateView;
@property (weak, nonatomic) IBOutlet UIImageView *leftSideImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightSideImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webVIewHeightConst;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
//@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

//@property (weak, nonatomic) IBOutlet UIButton *rateButton;
//@property (weak, nonatomic) IBOutlet UILabel *aboutUsLabel;
//@property (weak, nonatomic) IBOutlet UILabel *averageLabel;
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
@property (weak, nonatomic) IBOutlet UIView *conatinerAvrRating;
@property (weak, nonatomic) IBOutlet UIView *conatinerYourRating;
@property (weak, nonatomic) IBOutlet UIImageView *plusMinusImageView;
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
    self.rateView.halfSelectedImage = [UIImage imageNamed:@"starHalf"];
    self.rateView.quarterSelectedImage = [UIImage imageNamed:@"quarterStar"];
    self.rateView.three4thSelectedImage = [UIImage imageNamed:@"three4thStar"];
    self.rateView.rating = 0;
    self.rateView.editable = NO;
    self.rateView.maxRating = 5;
    

    
    self.yourRatingView.notSelectedImage = [UIImage imageNamed:@"starEmpty.png"];
    self.yourRatingView.fullSelectedImage = [UIImage imageNamed:@"starFull.png"];
    self.yourRatingView.rating = 0;
    self.yourRatingView.editable = YES;
    self.yourRatingView.maxRating = 5;
    self.yourRatingView.delegate = self;
    
    
    if ([[UIDevice currentDevice]userInterfaceIdiom]== UIUserInterfaceIdiomPhone)
    {
        self.avgRateLable.font = [self customFont:16 ofName:MuseoSans_700];
        self.yourRateLbl.font = [self customFont:16 ofName:MuseoSans_700];
        self.avgRatValueLbl.font = [self customFont:30 ofName:MuseoSans_700];
        self.yourRateValueLbl.font = [self customFont:30 ofName:MuseoSans_700];
        self.totalLbl.font = [self customFont:14 ofName:MuseoSans_300];
        self.clickToRateLbl.font = [self customFont:14 ofName:MuseoSans_300];
        
        self.writeReviewLbl.font = [self customFont:16 ofName:MuseoSans_700];
        
        describtionFont = [self customFont:14 ofName:MuseoSans_300];
    }
    else
    {
        self.avgRateLable.font = [self customFont:22 ofName:MuseoSans_700];
        self.yourRateLbl.font = [self customFont:22 ofName:MuseoSans_700];
        self.avgRatValueLbl.font = [self customFont:40 ofName:MuseoSans_700];
        self.yourRateValueLbl.font = [self customFont:40 ofName:MuseoSans_700];
        self.totalLbl.font = [self customFont:18 ofName:MuseoSans_300];
        self.clickToRateLbl.font = [self customFont:18 ofName:MuseoSans_300];
        
        self.writeReviewLbl.font = [self customFont:22 ofName:MuseoSans_700];
        describtionFont = [self customFont:20 ofName:MuseoSans_300];
    }
    
//    self.descriptionTextView.editable = YES;
//    [self.descriptionTextView setFont:describtionFont];
//    self.descriptionTextView.editable = NO;
    
    self.writeReviewAlphaView.layer.cornerRadius = 15;
    self.conatinerAvrRating.layer.cornerRadius = 10;
    self.conatinerYourRating.layer.cornerRadius = 10;

    self.writeReviewTxtView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.writeReviewTxtView.layer.borderWidth = 1;
    
    URLString = ABOUT_DETAILS_API;
    
    postMan = [[Postman alloc] init];
    postMan.delegate = self;
    
    if ([AFNetworkReachabilityManager sharedManager].isReachable)
    {
        
//        [postMan get:[USER_GIVEN_RATING_API stringByAppendingString:@"Corp123"]];
//        [postMan get:[USER_GIVEN_RATING_API stringByAppendingString:[UserInfo sharedUserInfo].cropID]];

        if ([[NSUserDefaults standardUserDefaults]boolForKey:@"aboutus"])
        {
            [self tryUpdateAboutDeatils];
            
        }else
        {
            averageRating = [[NSUserDefaults standardUserDefaults] floatForKey:@"averageRatingKey"];
            totalNoOfUserRated = [[NSUserDefaults standardUserDefaults] integerForKey:@"totalNoOfUSerKey"];

            [self  getData];
        }
    }
    else
    {
        averageRating = [[NSUserDefaults standardUserDefaults] floatForKey:@"averageRatingKey"];
        totalNoOfUserRated = [[NSUserDefaults standardUserDefaults] integerForKey:@"totalNoOfUSerKey"];
        [self  getData];
    }
    
    yourRatingValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"YourRatingKey"];
    self.yourRatingView.rating = yourRatingValue;
    self.yourRateValueLbl.text = [NSString stringWithFormat:@"%li", (long)yourRatingValue];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (IBAction)tickMarkBarBtnAction:(id)sender
{
    [self.view endEditing:YES];
    
    if ([AFNetworkReachabilityManager sharedManager].reachable)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
//        NSString  *parameter = [NSString stringWithFormat:@"{\"request\":{\"CorpId\":\"Corp123\",\"Rating\":\"%@\",\"Feedback\":\"%@\"}}", self.yourRateValueLbl.text, self.writeReviewTxtView.text];
        
        NSString  *parameter = [NSString stringWithFormat:@"{\"request\":{\"CorpId\":\"%@\",\"Rating\":\"%@\",\"Feedback\":\"%@\"}}",  [UserInfo sharedUserInfo].cropID?:@"", self.yourRateValueLbl.text, self.writeReviewTxtView.text];
        
        self.tickMarkBarBtnOutlet.enabled = NO;
        
        NSString *feedBackAPI = [NSString stringWithFormat:@"%@%@",FEEDBACK_API, [UserInfo sharedUserInfo].cropID];
        [postMan post:feedBackAPI withParameters:parameter];
        
        self.writeReviewTxtView.text = @"";
        [self hideWriteReviewTextView];
    }else
    {
        [[NSUserDefaults standardUserDefaults] setObject:self.writeReviewTxtView.text forKey:@"Feedback_Data"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Feedback_Sync"];
        [[NSUserDefaults standardUserDefaults] setInteger:self.yourRatingView.rating forKey:@"YourRatingKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:WARNING_TEXT message:FEEDBACK_IN_OFFLINE delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [noNetworkAlert show];
    }
}

- (void)networkStatusChanged:(AFNetworkReachabilityStatus)status
{
    if (status == AFNetworkReachabilityStatusReachableViaWiFi || status == AFNetworkReachabilityStatusReachableViaWWAN)
    {
        if ([[NSUserDefaults standardUserDefaults]boolForKey:@"Feedback_Sync"])
        {
            NSInteger ratingGive = [[NSUserDefaults standardUserDefaults] integerForKey:@"YourRatingKey"];
            NSString *feedbackData = [[NSUserDefaults standardUserDefaults] objectForKey:@"Feedback_Data"];
            NSString  *parameter = [NSString stringWithFormat:@"{\"request\":{\"CorpId\":\"%@\",\"Rating\":\"%li\",\"Feedback\":\"%@\"}}",  [UserInfo sharedUserInfo].cropID?:@"", (long)ratingGive, feedbackData];
            
            self.tickMarkBarBtnOutlet.enabled = NO;
            
            NSString *feedBackAPI = [NSString stringWithFormat:@"%@%@",FEEDBACK_API, [UserInfo sharedUserInfo].cropID];
            [postMan post:feedBackAPI withParameters:parameter];
            
            self.writeReviewTxtView.text = @"";
            [self hideWriteReviewTextView];
        }
    }
}

- (void)rateView:(RateView *)rateView ratingDidChange:(float)rating
{
    [self.view endEditing:YES];
    if (self.writeReviewTxtView.text.length > 0 || self.yourRatingView.rating > 0)
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
    
    if ([AFNetworkReachabilityManager sharedManager].isReachable)
    {
        [postMan get:AVERAGE_RATING_API];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
     {
         
         [self networkStatusChanged:status];
         
     }];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];

    
//    self.yourRatingView.rating = 0;
//    self.yourRateValueLbl.text = @"0";
    self.writeReviewTxtView.text = @"";
    [self hideWriteReviewTextView];

}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:.3
                     animations:^{
                         
                         self.scrollViewBottomConst.constant = kbSize.height - 56;
                         [self.view layoutIfNeeded];
                         
                     }
                     completion:^(BOOL finished) {
                         
                         [self.scrollView scrollRectToVisible:self.writeReviewTxtView.frame animated:YES];
                         
                     }];
    
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self.scrollViewBottomConst.constant = 0;
//    [self.view layoutIfNeeded];
}

- (void)backBtnAction
{
    [self.tabBarController setSelectedIndex:0];
//    self.writeReviewTxtView.text = @"";
//    [self hideWriteReviewTextView];
}

- (void)tryUpdateAboutDeatils
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *curentLanguage = [MCLocalization sharedInstance].language;
    
    NSString *param = [NSString stringWithFormat:@"{\"request\":{\"LanguageCode\":\"%@\"}}",curentLanguage];
    
//    NSString *parameter = @"{\"request\":{\"LanguageCode\":\"\"}}";
    
    [postMan post:URLString withParameters:param];
}

- (IBAction)writeReviewBtnAction:(id)sender
{
    if (!reviewBtnIsSelected)
    {
        [self showWriteReviewTextView];
    }else
    {
        [self hideWriteReviewTextView];
    }
}


-(void)showWriteReviewTextView
{
    self.writeReviewTxtView.hidden = NO;
    
    [UIView animateWithDuration:.3 animations:^{
        
        self.writeReviewTextFldHeightConst.constant = 100;
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished)
     {
         reviewBtnIsSelected = YES;
         self.plusMinusImageView.image = [UIImage imageNamed:@"minusIcon"];
         [self.scrollView scrollRectToVisible:self.writeReviewTxtView.frame animated:YES];
     }];
}

-(void)hideWriteReviewTextView
{
    [UIView animateWithDuration:.3 animations:^{
        
        self.writeReviewTextFldHeightConst.constant = 0;
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        self.writeReviewTxtView.hidden = YES;
        //             self.writeReviewBtnOutlet.selected = NO;
        
        self.plusMinusImageView.image = [UIImage imageNamed:@"plusIcon"];
        [self.scrollView scrollRectToVisible:self.writeReviewTxtView.frame animated:YES];
        
        reviewBtnIsSelected = NO;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUI
{
    self.rateView.rating = averageRating;

    self.avgRatValueLbl.text = [NSString stringWithFormat:@"%.1f",averageRating];
    self.totalLbl.text = [NSString stringWithFormat:@"%li Total", (long)totalNoOfUserRated];
    self.leftSideImageView.image = [self getimageForDocCode:ucbLogoDocCode];
    
//    self.rightSideImageView.image = [self getimageForDocCode:vmokshaLogoDocCode];
//
    NSString *testString = aboutDescription;

//    self.descriptionTextView.text = testString;
//    
//    self.descriptionTextView.selectable = YES;
//    CGSize expectedSize = [testString boundingRectWithSize:(CGSizeMake(self.descriptionTextView.frame.size.width, 10000))
//                                                   options:NSStringDrawingUsesLineFragmentOrigin
//                                                attributes:@{NSFontAttributeName: describtionFont}
//                                                   context:nil].size;
//    self.descriptionTextView.selectable = NO;
//    self.descriptionHeightConst.constant = expectedSize.height + 25;
    
    CGFloat widthOfWebView = [UIScreen mainScreen].bounds.size.width - 50;
    NSString *sring = [NSString stringWithFormat:@"<div style=\"width: %fpx; word-wrap: break-word\"> <style type='text/css'>img { max-width: %f; width: auto; height: auto; } </style> <style type='text/css'>.wysiwyg-color-black {  color: black;}</style><style type='text/css'>.wysiwyg-color-silver {  color: silver;}</style><style type='text/css'>.wysiwyg-color-gray {  color: gray;}</style><style type='text/css'>.wysiwyg-color-white {  color: white;}</style><style type='text/css'>.wysiwyg-color-maroon {  color: maroon;}</style><style type='text/css'>.wysiwyg-color-red {  color: red;}</style><style type='text/css'>.wysiwyg-color-purple {  color: purple;}</style><style type='text/css'>.wysiwyg-color-fuchsia {  color: fuchsia;}</style><style type='text/css'>.wysiwyg-color-green {  color: green;}</style><style type='text/css'>.wysiwyg-color-lime {  color: lime;}</style><style type='text/css'>.wysiwyg-color-olive {  color: olive;}</style><style type='text/css'>.wysiwyg-color-yellow {  color: yellow;}</style><style type='text/css'>.wysiwyg-color-navy {  color: navy;}</style><style type='text/css'>.wysiwyg-color-blue {  color: blue;}</style><style type='text/css'>.wysiwyg-color-teal {  color: teal;}</style><style type='text/css'>.wysiwyg-color-aqua {  color: aqua;}</style><style type='text/css'>.wysiwyg-color-orange {  color: orange;}</style> %@ </div>",widthOfWebView,widthOfWebView, testString];
    
    self.webView.mediaPlaybackRequiresUserAction=NO;
    [self.webView loadHTMLString:sring baseURL:nil];

    [self.view layoutIfNeeded];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSString *javascript = @"var style = document.createElement(\"style\"); document.head.appendChild(style); style.innerHTML = \"html{-webkit-text-size-adjust: 100%;} body {-webkit-text-size-adjust:100%;}\";var viewPortTag=document.createElement('meta');viewPortTag.id=\"viewport\";viewPortTag.name = \"viewport\";viewPortTag.content = \"width=320; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;\";document.getElementsByTagName('head')[0].appendChild(viewPortTag);";
    [webView stringByEvaluatingJavaScriptFromString:javascript];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    webView.scrollView.scrollEnabled = NO;    // Property available in iOS 5.0 and later
    
    CGFloat height = [[webView stringByEvaluatingJavaScriptFromString:@"document.height"] floatValue];
    self.webVIewHeightConst.constant = height;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if(navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [self performSelector:@selector(updateUI) withObject:nil afterDelay:duration+.1];
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
    
    NSString *feedBackAPI = [NSString stringWithFormat:@"%@%@",FEEDBACK_API, [UserInfo sharedUserInfo].cropID];
    
    if ([urlString isEqualToString:ABOUT_DETAILS_API])
    {
        [self parseResponsedata:response andgetImages:YES];
        [self saveAboutDetailsData:response forURL:urlString];
        
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"aboutus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }else if ([urlString isEqualToString:feedBackAPI])
    {
        [self parseFeedbackData:response];
        
    }else if ([urlString isEqualToString:AVERAGE_RATING_API])
    {
        [self parseAvgRating:response];
        
//    }else
//        if ([urlString isEqualToString:[USER_GIVEN_RATING_API stringByAppendingString:@"Corp123"]])
//    {
//    }else if ([urlString isEqualToString:[USER_GIVEN_RATING_API stringByAppendingString:[UserInfo sharedUserInfo].cropID]]])
//    {
//        [self parseUserGiveRating:response];
//        
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
        if (![[NSUserDefaults standardUserDefaults]boolForKey:@"Feedback_Sync"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SimplicITy Rating" message:ALERT_FOR_RATING delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        
        self.writeReviewTxtView.text = @"";
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Feedback_Sync"];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"Feedback_Data"];
        [[NSUserDefaults standardUserDefaults] setInteger:self.yourRatingView.rating forKey:@"YourRatingKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [postMan get:AVERAGE_RATING_API];
    }
}

- (void)parseAvgRating:(NSData *)response
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];

    if ([json[@"aaData"][@"Success"] boolValue])
    {
        averageRating = [json[@"aaData"][@"AverageRating"][@"AverageRating"] floatValue];
        totalNoOfUserRated = [json[@"aaData"][@"AverageRating"][@"TotalUsersRated"] integerValue];
        [[NSUserDefaults standardUserDefaults] setFloat:averageRating forKey:@"averageRatingKey"];
        [[NSUserDefaults standardUserDefaults] setInteger:totalNoOfUserRated forKey:@"totalNoOfUSerKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self updateUI];
}

- (void)parseUserGiveRating:(NSData *)response
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    if ([json[@"aaData"][@"Success"] boolValue])
    {
        yourRatingValue = [json[@"aaData"][@"Rating"][@"Rating"] integerValue];
    }else
    {
        yourRatingValue = 0;
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
            aboutDescription = aDict[@"Description"];
            ucbLogoDocCode = aDict[@"UCBLogo_DocumentCode"];
            vmokshaLogoDocCode = aDict[@"VmokshaLogo_DocumentCode"];

            if (download || [[NSUserDefaults standardUserDefaults] boolForKey:@"document"])
            {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                
                NSString *imageUrl = [NSString stringWithFormat:RENDER_DOC_API, ucbLogoDocCode];
                [postMan get:imageUrl];
                
                imageUrl = [NSString stringWithFormat:RENDER_DOC_API, vmokshaLogoDocCode];
                [postMan get:imageUrl];
            }
            
            NSString *language = aDict[@"Language"];
            if ([language isEqualToString:@"English"])
            {
                break;
            }
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
    
    [self updateUI];
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
    NSLog(@"File path = %@", filePath);
    
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    
    if (imageData)
    {
        UIImage *tempImage = [UIImage imageWithData:imageData];
        UIImage *image = [UIImage imageWithCGImage:tempImage.CGImage scale:2 orientation:tempImage.imageOrientation] ;
        
        return image;
    }
    
    return nil;
}


//- (void)textViewDidBeginEditing:(UITextView *)textView
//{
//    UIInterfaceOrientation orientaition = [[UIApplication sharedApplication] statusBarOrientation];
//    if (orientaition == UIInterfaceOrientationPortrait || orientaition == UIDeviceOrientationPortraitUpsideDown)
//    {
//        self.scrollViewBottomConst.constant = 195;
//        
//    }else if (orientaition == UIDeviceOrientationLandscapeRight || orientaition == UIDeviceOrientationLandscapeLeft)
//    {
//        if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
//        {
//            self.scrollViewBottomConst.constant = 145;
//        }
//        else
//        {
//            self.scrollViewBottomConst.constant = 350;
//            
//        }    }
//    
//    [self.view layoutIfNeeded];
//    
//    [self.scrollView scrollRectToVisible:textView.frame animated:YES];
//}
//
//- (void)textViewDidEndEditing:(UITextView *)textView
//{
//    self.scrollViewBottomConst.constant = 0;
//    [self.view layoutIfNeeded];
//}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([textView isEqual:self.writeReviewTxtView])
    {
        NSString *expectedString = [textView.text stringByReplacingCharactersInRange:range withString:text];
        
        if (expectedString.length > 0 & self.yourRatingView.rating > 0)
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
