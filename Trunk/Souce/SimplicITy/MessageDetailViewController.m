//
//  MessageDetailViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 03/12/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "MessageDetailViewController.h"
#import "BadgeNoManager.h"
#import "DBManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "NSString+HTML.h"

@interface MessageDetailViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLable;
@property (weak, nonatomic) IBOutlet UILabel *subjectLable;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;
@property (weak, nonatomic) IBOutlet UILabel *timeLable;
@property (weak, nonatomic) IBOutlet UIWebView *body;

@property (weak, nonatomic) IBOutlet UIView *separator1;
@property (weak, nonatomic) IBOutlet UIView *separator2;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIWebView *webViewOutlet;

@end

@implementation MessageDetailViewController
{
    UIBarButtonItem *backButton;
    DBManager *dbManager;
    CGFloat heightOfWebViewCell;
    UIButton *back;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.nameLable.text = self.mesgModel.name;
//    self.subjectLable.text = self.mesgModel.subject;
//    self.bodyTextView.text = self.mesgModel.body;
//    self.timeLable.text = self.mesgModel.time;

    
    
    back = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [back setImage:[UIImage imageNamed:@"back_Arrow"] forState:UIControlStateNormal];
    
    back.titleLabel.font = [self customFont:16 ofName:MuseoSans_700];
    
//    back.imageEdgeInsets = UIEdgeInsetsMake(0, -35, 0, 0);
//    back.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
//    back.frame = CGRectMake(0, 0,80, 40);
    
    //    back imageEdgeInsets = UIEdgeInsetsMake(<#CGFloat top#>, CGFloat left, <#CGFloat bottom#>, <#CGFloat right#>);
    
    [back setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [back  addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    backButton = [[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = backButton;
    
//    self.nameLable.text = self.categoryName;
//    
//    [self.body loadHTMLString:self.newsContent.newsDetails baseURL:nil ];
//    self.subjectLable.text = self.newsContent.subject;
//    
//    NSDateFormatter *converter = [[NSDateFormatter alloc] init];
//    [converter setDateFormat:@"yyyy/MM/dd, hh:mm: ss a"];
//    self.timeLable.text = [converter stringFromDate:self.newsContent.recivedDate ];
//
//    
//    self.nameLable.font=[self customFont:18 ofName:MuseoSans_700];
//    self.bodyTextView.font=[self customFont:14 ofName:MuseoSans_300];
//    self.timeLable.font=[self customFont:14 ofName:MuseoSans_300];
//    self.subjectLable.font=[self customFont:20 ofName:MuseoSans_300];

    dbManager = [[DBManager alloc] initWithFileName:@"News.db"];
    
    NSString *decodedSrting = [self.newsContent.htmlcontant stringByDecodingHTMLEntities];
//    NSMutableString *mutString = [decodedSrting mutableCopy];
//    [mutString replaceOccurrencesOfString:@"div,h1,h2,h3,h4,li,p,span,td" withString:@"div,li,p,td" options:NSCaseInsensitiveSearch range:(NSMakeRange(0, mutString.length-1))];
//    decodedSrting = mutString;
    [self.webViewOutlet  loadHTMLString:[NSString stringWithFormat:@"<div id ='foo'  style='font-size:14px; font-family:MuseoSans-300; color:#808080';>%@<div>",decodedSrting] baseURL:nil];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
   

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localize) name:MCLocalizationLanguageDidChangeNotification object:nil];
    [self localize];


}

-(void)localize
{
  self.title = STRING_FOR_LANGUAGE(@"News.Details");
 [back setTitle:STRING_FOR_LANGUAGE(@"Back.Survey") forState:UIControlStateNormal];
    [back sizeToFit];
}




- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.newsContent.viewed)
    {
        BadgeNoManager *badgemanager = [[BadgeNoManager alloc] init];
        [self setViewFlagOnDB];
        
        [badgemanager updateBadgeNoFor:self.newsContent.parentCategory
                                withNo:[badgemanager noBadgesFor:self.newsContent.parentCategory afterUpdating:NO]];
    }
}

- (void)setViewFlagOnDB
{
    NSString *query =  [NSString stringWithFormat:@"UPDATE n_%@ set viewedFlag = 1 WHERE newsCode = '%@'", self.newsContent.parentCategory, self.newsContent.newsCode];
    self.newsContent.viewed = YES;
    
    [dbManager saveDataToDBForQuery:query];
}

//- (void)webViewDidStartLoad:(UIWebView *)webView
//{
//    NSString *javascript = @"var style = document.createElement(\"style\"); document.head.appendChild(style); style.innerHTML = \"html{-webkit-text-size-adjust: 100%;} body {-webkit-text-size-adjust:100%;}\";var viewPortTag=document.createElement('meta');viewPortTag.id=\"viewport\";viewPortTag.name = \"viewport\";viewPortTag.content = \"width=320; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;\";document.getElementsByTagName('head')[0].appendChild(viewPortTag);";
//    [webView stringByEvaluatingJavaScriptFromString:javascript];
//}
//
//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    NSString *javascript = @"var style = document.createElement(\"style\"); document.head.appendChild(style); style.innerHTML = \"html{-webkit-text-size-adjust: 100%;} body {-webkit-text-size-adjust:100%;}\";var viewPortTag=document.createElement('meta');viewPortTag.id=\"viewport\";viewPortTag.name = \"viewport\";viewPortTag.content = \"width=320; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;\";document.getElementsByTagName('head')[0].appendChild(viewPortTag);";
//    [webView stringByEvaluatingJavaScriptFromString:javascript];
//    
//    [webView.scrollView setContentSize: CGSizeMake(webView.frame.size.width, webView.scrollView.contentSize.height)];
//    [webView.scrollView setShowsVerticalScrollIndicator:NO];
//    
//}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
//    NSString *javascript = @"var style = document.createElement(\"style\"); document.head.appendChild(style); style.innerHTML = \"html{-webkit-text-size-adjust: 100%;} body {-webkit-text-size-adjust:100%;}\";var viewPortTag=document.createElement('meta');viewPortTag.id=\"viewport\";viewPortTag.name = \"viewport\";viewPortTag.content = \"width=320; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;\";document.getElementsByTagName('head')[0].appendChild(viewPortTag);";
//    [webView stringByEvaluatingJavaScriptFromString:javascript];
//
//    
//    CGRect frame = webView.frame;
//    frame.size.height = 1;
//    webView.frame = frame;
//    CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
//    frame.size = fittingSize;
//    webView.frame = frame;
//    
//    NSLog(@"size: %f, %f", fittingSize.width, fittingSize.height);
//    
//    
//    [self.tableView beginUpdates];
//    
//    CGFloat webViewHeight = webView.scrollView.contentSize.height;
//    heightOfWebViewCell = webViewHeight + 10;
//    webView.scrollView.scrollEnabled = NO;
//    [self.tableView endUpdates];
    
    
//    yourScrollView.contentSize = webView.bounds.size;
}

-(void)backBtnAction
{
    //    [self.tabBarController setSelectedIndex:0];
    [self.navigationController popViewControllerAnimated:YES];
    
}

//-(void)viewWillAppear:(BOOL)animated
//{
//
//}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if(navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    
    return YES;
}

//#pragma mark UITableViewDataSource methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0)
    {
        return 70;
    }else if (indexPath.row == 1)
    {
        return [self heightOfSubjectCell];
        
    }
    else
    {
        return heightOfWebViewCell;
    }
        
}

- (CGFloat)heightOfSubjectCell
{
    NSDictionary *attributes = @{NSFontAttributeName: [self customFont:18 ofName:MuseoSans_300]};
    
    CGFloat maxWidthAllowed = self.view.frame.size.width - 8 - 10;
    
    //    if ([[UIApplication sharedApplication] statusBarOrientation] != UIInterfaceOrientationPortrait)
    //    {
    //        maxWidthAllowed = self.view.frame.size.height - 16 - 33;
    //    }
    
    CGRect expectedSizeOfLabel = [self.newsContent.subject boundingRectWithSize:(CGSizeMake(maxWidthAllowed, 10000))
                                                            options:(NSStringDrawingUsesLineFragmentOrigin)
                                                         attributes:attributes
                                                            context:nil];
    CGFloat expectedHeightOfCell = expectedSizeOfLabel.size.height + 20 + 8 + 11 + 15; // timelabel height = 20
    return expectedHeightOfCell;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];
        UILabel *category = (UILabel *)[cell viewWithTag:100];
        category.text = self.categoryName;
        category.font = [self customFont:18 ofName:MuseoSans_700];

    }else if (indexPath.row == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell2" forIndexPath:indexPath];
        UILabel *sub = (UILabel *)[cell viewWithTag:200];
        sub.text = self.newsContent.subject;
        sub.font = [self customFont:18 ofName:MuseoSans_300];
        
        UILabel *time = (UILabel *)[cell viewWithTag:300];
        
        NSDateFormatter *converter = [[NSDateFormatter alloc] init];
        [converter setDateFormat:@"yyyy/MM/dd, hh:mm: ss a"];
        time.text = [converter stringFromDate:self.newsContent.recivedDate ];
        time.font = [self customFont:14 ofName:MuseoSans_100];;

    }else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell3" forIndexPath:indexPath];
        
        UIWebView *webViewBody = (UIWebView *)[cell viewWithTag:400];
        [webViewBody loadHTMLString:self.newsContent.newsDetails baseURL:nil];
    }
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
