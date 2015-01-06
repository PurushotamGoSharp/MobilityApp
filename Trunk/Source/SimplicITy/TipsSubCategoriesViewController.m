//
//  TipsSubCategoriesViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/10/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "TipsSubCategoriesViewController.h"
#import "TipDetailsViewController.h"
#import "TipModel.h"

@interface TipsSubCategoriesViewController () <UITableViewDataSource, UITableViewDelegate, postmanDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TipsSubCategoriesViewController
{
    NSMutableArray *subCategoriesCollection;
    
    Postman *postMan;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.parentCategory;
    
    [self tryToUpdateCategories];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)tryToUpdateCategories
{
    subCategoriesCollection = [[NSMutableArray alloc] init];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *URLString = [NSString stringWithFormat:@"http://simplicitytst.ripple-io.in/%@/Tips", self.parentCode];
    
    postMan = [[Postman alloc] init];
    postMan.delegate = self;
    [postMan get:URLString];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [subCategoriesCollection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    UILabel *label = (UILabel *) [cell viewWithTag:100];
    
    TipModel *tip = subCategoriesCollection[indexPath.row];
    label.text = tip.question;

    label.font = [self customFont:16 ofName:MuseoSans_700];
    [label sizeToFit];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TipModel *tip = subCategoriesCollection[indexPath.row];
    NSDictionary *attributes = @{NSFontAttributeName: [self customFont:16 ofName:MuseoSans_700]};
    
    CGFloat maxWidthAllowed = self.view.frame.size.width - 16 - 33;
    
//    if ([[UIApplication sharedApplication] statusBarOrientation] != UIInterfaceOrientationPortrait)
//    {
//        maxWidthAllowed = self.view.frame.size.height - 16 - 33;
//    }
    
    CGRect expectedSizeOfLabel = [tip.question boundingRectWithSize:(CGSizeMake(maxWidthAllowed, 10000))
                                                            options:(NSStringDrawingUsesLineFragmentOrigin)
                                                         attributes:attributes
                                                            context:nil];
    
    CGFloat expectedHeightOfCell = expectedSizeOfLabel.size.height + 24;
    NSLog(@"%f", expectedHeightOfCell);
    return expectedHeightOfCell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TipsSubToDetailsSegue"])
    {
        TipDetailsViewController *tipDetailsVC = (TipDetailsViewController *)segue.destinationViewController;
        tipDetailsVC.tipModel =  subCategoriesCollection[[self.tableView indexPathForSelectedRow].row];
    }
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation {
    
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            //load the portrait view
        }
            
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            //load the landscape view
        }
            break;
        case UIInterfaceOrientationUnknown:break;
    }
    
    [self.tableView reloadData];
}

#pragma mark
#pragma mark: postmanDelegate
- (void)postman:(Postman *)postman gotSuccess:(NSData *)response
{
    [self parseResponseData:response];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)parseResponseData:(NSData *)response
{
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
    
    [self.tableView reloadData];
}

- (void)postman:(Postman *)postman gotFailure:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}


@end
