//
//  TipDetailsViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/11/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "TipDetailsViewController.h"
#import "DBManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "TipModel.h"
#import "TipsSubCategoriesViewController.h"

@interface TipDetailsViewController () <UIWebViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, postmanDelegate, DBManagerDelegate, TipsSubCategoriesViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
//@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *currentPageNoLabel;

@end

@implementation TipDetailsViewController
{
    NSMutableArray *subCategoriesCollection;
    Postman *postMan;
    NSString *URLString;
    
    DBManager *dbManager;
    NSInteger currentPageNo;
    
    NSString *navBatTitle;
    NSString *cachePath;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.title = self.tipModel.question;
    self.webView.delegate = self;
    
    postMan = [[Postman alloc] init];
    postMan.delegate = self;
    self.currentPageNoLabel.font = [self customFont:14 ofName:MuseoSans_300];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    
    NSLog(@"nav Bar Title is : %@",self.title);
    
//    self.navigationItem.title =self.parentCategory;

    NSArray *cachedirs = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    cachePath = [cachedirs lastObject];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    URLString = [NSString stringWithFormat:TIPS_SUBCATEGORY_API, self.parentCode];
    
    if ([AFNetworkReachabilityManager sharedManager].reachable)
    {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:[self userDefaultKey]])
        {
            [self tryToUpdateCategories];
        }else
        {
            [self getData];
        }
    }else
    {
        [self getData];
    }
    
    self.title =self.parentCategory;

    [self setPageNoLabelFor:currentPageNo];
    
//    NSArray *cachedirs = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString *cachePath = [cachedirs lastObject];
//    
//    CGFloat widthOfWebView = [UIScreen mainScreen].bounds.size.width - 20;
//    NSString *sring = [NSString stringWithFormat:@"<div style=\"width: %fpx; word-wrap: break-word\"> %@ </div>",widthOfWebView,self.tipModel.answer];
//    [self.webView loadHTMLString:sring baseURL:[NSURL URLWithString:cachePath]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
}



- (void)tryToUpdateCategories
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [postMan get:URLString];
}

- (NSString *)userDefaultKey
{
    NSArray *stringArray = @[self.parentCode, self.parentCategory];
    NSString *userDeafultKey = [stringArray componentsJoinedByString:@","];
    return [userDeafultKey lowercaseString];
}

- (void)orientationChanged:(NSNotification *)notification
{
    [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation
{
    [self.collectionView reloadData];
    
    CGFloat widthOfCollectonView = self.collectionView.frame.size.width;
    
    [self.collectionView setContentOffset:(CGPointMake(widthOfCollectonView*currentPageNo, 0)) animated:YES];
    
//    switch (orientation)
//    {
//        case UIInterfaceOrientationPortrait:
//        case UIInterfaceOrientationPortraitUpsideDown:
//        {
//            NSLog(@"UIInterfaceOrientationPortrait");
//            //load the portrait view
//            NSArray *cachedirs = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//            NSString *cachePath = [cachedirs lastObject];
//
//            CGFloat widthOfWebView = [UIScreen mainScreen].bounds.size.width - 40;
//            NSString *sring = [NSString stringWithFormat:@"<div style=\"width: %fpx; word-wrap: break-word\"> %@ </div>",widthOfWebView,self.tipModel.answer];
//            [self.webView loadHTMLString:sring baseURL:[NSURL URLWithString:cachePath]];
//        }
//            break;
//        case UIInterfaceOrientationLandscapeLeft:
//        case UIInterfaceOrientationLandscapeRight:
//        {
//            //load the landscape view
//            NSLog(@"UIInterfaceOrientationLandscapeLeft");
//            NSArray *cachedirs = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//            NSString *cachePath = [cachedirs lastObject];
//            
//            CGFloat widthOfWebView = [UIScreen mainScreen].bounds.size.width - 40;
//            NSString *sring = [NSString stringWithFormat:@"<div style=\"width: %fpx; word-wrap: break-word\"> %@ </div>",widthOfWebView,self.tipModel.answer];
//            [self.webView loadHTMLString:sring baseURL:[NSURL URLWithString:cachePath]];
//        }
//            break;
//        case UIInterfaceOrientationUnknown:break;
//    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSString *javascript = @"var style = document.createElement(\"style\"); document.head.appendChild(style); style.innerHTML = \"html{-webkit-text-size-adjust: 100%;} body {-webkit-text-size-adjust:100%;}\";var viewPortTag=document.createElement('meta');viewPortTag.id=\"viewport\";viewPortTag.name = \"viewport\";viewPortTag.content = \"width=320; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;\";document.getElementsByTagName('head')[0].appendChild(viewPortTag);";
    [webView stringByEvaluatingJavaScriptFromString:javascript];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *javascript = @"var style = document.createElement(\"style\"); document.head.appendChild(style); style.innerHTML = \"html{-webkit-text-size-adjust: 100%;} body {-webkit-text-size-adjust:100%;}\";var viewPortTag=document.createElement('meta');viewPortTag.id=\"viewport\";viewPortTag.name = \"viewport\";viewPortTag.content = \"width=320; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;\";document.getElementsByTagName('head')[0].appendChild(viewPortTag);";
    [webView stringByEvaluatingJavaScriptFromString:javascript];
    
    [webView.scrollView setContentSize: CGSizeMake(webView.frame.size.width, webView.scrollView.contentSize.height)];
    [webView.scrollView setShowsVerticalScrollIndicator:NO];

}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"detailsToListSegue"])
    {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        TipsSubCategoriesViewController *tipsList = navController.viewControllers[0];
        tipsList.listOfTips = subCategoriesCollection;
        tipsList.parentCategory = self.parentCategory;
        tipsList.delegate = self;
        tipsList.curentpageNum = currentPageNo;
//        NSLog(@"curent page Number %i",currentPageNo);
    }
}

- (void)setPageForIndex:(NSInteger)index
{
    if ([subCategoriesCollection count] <= index)
    {
        return;
    }
    
    CGFloat widthOfCollectionView = self.collectionView.frame.size.width;
    CGFloat xOfContentOffset = widthOfCollectionView * index;
    [self.collectionView setContentOffset:CGPointMake(xOfContentOffset, 0) animated:NO];
    [self setPageNoLabelFor:currentPageNo];
}

- (void)setPageNoLabelFor:(NSInteger)pageNo
{
    NSInteger noOfTotalPages = [subCategoriesCollection count];
    if (pageNo >= noOfTotalPages)
    {
        return;
    }
    self.currentPageNoLabel.text = [NSString stringWithFormat:@"%li of %li", (long)pageNo+1, (long)noOfTotalPages];
    
//    TipModel *tip = [[TipModel alloc] init];
//    self.title =tip.question;
}

#pragma mark
#pragma mark: UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [subCategoriesCollection count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionViewCell" forIndexPath:indexPath];
    
    UIWebView *webView = (UIWebView *)[cell viewWithTag:100];
    
    CGFloat widthOfWebView = [UIScreen mainScreen].bounds.size.width - 40;
    TipModel *aTipModel = subCategoriesCollection[indexPath.row];
    NSString *sring = [NSString stringWithFormat:@"<div style=\"width: %fpx; word-wrap: break-word\"> %@ </div>",widthOfWebView, aTipModel.answer];
    [webView loadHTMLString:sring baseURL:[NSURL URLWithString:cachePath]];
    
//    self.title = aTipModel.question;
//   navBatTitle =  self.title;
//    
//    NSLog(@"tip Sub category %@",navBatTitle);
    

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize sizeOfCell = self.collectionView.frame.size;
    
    sizeOfCell = CGSizeMake(sizeOfCell.width - 20, sizeOfCell.height - 20);
    
    return sizeOfCell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.collectionView])
    {
        CGFloat xValueOfContentOffset = self.collectionView.contentOffset.x;
        NSInteger pageNo = roundf(xValueOfContentOffset/self.collectionView.frame.size.width);
        
        [self setPageNoLabelFor:pageNo];
//        currentPageNo = pageNo;
    }
    
//    self.title =self.parentCategory;

//    self.title = navBatTitle;

    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ([scrollView isEqual:self.collectionView])
    {
        CGFloat xValueOfContentOffset = self.collectionView.contentOffset.x;
        NSInteger pageNo = roundf(xValueOfContentOffset/self.collectionView.frame.size.width);
        
        [self setPageNoLabelFor:pageNo];
        currentPageNo = pageNo;
    }
}

#pragma mark
#pragma mark: postmanDelegate
- (void)postman:(Postman *)postman gotSuccess:(NSData *)response forURL:(NSString *)urlString
{
    [self parseResponseData:response];
    [self saveTipsCategory:response];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[self userDefaultKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    //    if (subCategoriesCollection.count <=1)
    //    {
    //        [self performSegueWithIdentifier:@"TipsSubToDetailsSegue" sender:self];
    //    }
}

- (void)parseResponseData:(NSData *)response
{
    subCategoriesCollection = [[NSMutableArray alloc] init];
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    
    NSArray *tips = json[@"aaData"][@"Tips"];
    
    for (NSDictionary *aDict in tips)
    {
        if ([aDict[@"Status"] boolValue])
        {
            TipModel *tip = [[TipModel alloc] init];
            tip.code = aDict[@"Code"];
            
            tip.groupCode = aDict[@"TipsGroupCode"];
            tip.groupName = aDict[@"TipsGroup"];
            
            NSString *JSONString = aDict[@"JSON"];
            NSDictionary *dictFromJSON = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding]
                                                                         options:kNilOptions
                                                                           error:nil];
            tip.question = dictFromJSON[@"Question"];
            tip.answer = dictFromJSON[@"Answer"];
            
            [subCategoriesCollection addObject:tip];
            
        }
    }
    
    [self.collectionView reloadData];
    
}

- (void)postman:(Postman *)postman gotFailure:(NSError *)error forURL:(NSString *)urlString
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)getData
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate = self;
    }
    
    NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM tipCategory WHERE API = '%@'", URLString];
    
    if (![dbManager getDataForQuery:queryString])
    {
        if (![AFNetworkReachabilityManager sharedManager].reachable)
        {
            UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:WARNING_TEXT message:INTERNET_IS_REQUIRED_TO_SYNC_DATA delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [noNetworkAlert show];
        }
        
        [self tryToUpdateCategories];
    }
}

#pragma mark
#pragma mark: DBManagerDelegate
- (void)DBManager:(DBManager *)manager gotSqliteStatment:(sqlite3_stmt *)statment
{
    if (sqlite3_step(statment) == SQLITE_ROW)
    {
        NSString *string = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statment, 1)];
        
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        
        [self parseResponseData:data];
        
    }else if (![AFNetworkReachabilityManager sharedManager].reachable)
    {
        UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:WARNING_TEXT message:INTERNET_IS_REQUIRED_TO_SYNC_DATA delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [noNetworkAlert show];
    }
}

- (void)saveTipsCategory:(NSData *)response
{
    if (dbManager == nil)
    {
        dbManager = [[DBManager alloc] initWithFileName:@"APIBackup.db"];
        dbManager.delegate = self;
    }
    
    NSString *createQuery = @"create table if not exists tipCategory (API text PRIMARY KEY, data text)";
    [dbManager createTableForQuery:createQuery];
    
    NSMutableString *stringFromData = [[NSMutableString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSRange rangeofString;
    rangeofString.location = 0;
    rangeofString.length = stringFromData.length;
    [stringFromData replaceOccurrencesOfString:@"'" withString:@"''" options:(NSCaseInsensitiveSearch) range:rangeofString];
    
    NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO  tipCategory (API,data) values ('%@', '%@')", URLString, stringFromData];
    
    [dbManager saveDataToDBForQuery:insertSQL];
}

#pragma mark
#pragma mark: TipsSubCategoriesViewControllerDelegate

- (void)tipsSub:(TipsSubCategoriesViewController *)tipsSub selectedIndex:(NSInteger)selectedIndex
{
    [self setPageForIndex:selectedIndex];
    currentPageNo = selectedIndex;
    

}

@end
