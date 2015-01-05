//
//  TipsCategoryViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/4/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "TipsCategoryViewController.h"
#import "TipsSubCategoriesViewController.h"

@interface TipsCategoryViewController () <UITableViewDataSource, UITableViewDelegate, postmanDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TipsCategoryViewController
{
    UIBarButtonItem *backButton;
    Postman *postMan;
    
    NSMutableArray *tipscategoryArray;
    
    NSArray *combinedDicts; //contains dicts with code and tips category.
    
   // __weak IBOutlet UILabel *TipsCategory;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setImage:[UIImage imageNamed:@"back_Arrow"] forState:UIControlStateNormal];
    [back setTitle:@"Home" forState:UIControlStateNormal];
    
    back.titleLabel.font = [UIFont systemFontOfSize:17];
    back.imageEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
    back.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
    back.frame = CGRectMake(0, 0,80, 30);

    [back setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [back  addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    backButton = [[UIBarButtonItem alloc] initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self tryToUpdateCategories];
}

- (void)backBtnAction
{
    [self.tabBarController setSelectedIndex:0];
}

- (void)tryToUpdateCategories
{
    NSString *parameterString;
    parameterString = @"{\"request\":{\"Name\":\"\",\"GenericSearchViewModel\":{\"Name\":\"\"}}}";
    
    tipscategoryArray = [[NSMutableArray alloc] init];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *URLString = @"http://simplicitytst.ripple-io.in/Search/TipsGroup";
    
    postMan = [[Postman alloc] init];
    postMan.delegate = self;
    [postMan post:URLString withParameters:parameterString];
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
    return [tipscategoryArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell" forIndexPath:indexPath];
    
    UILabel *label = (UILabel *)[cell viewWithTag:100];
    label.text = tipscategoryArray[indexPath.row];
    
   
    label.font=[self customFont:16 ofName:MuseoSans_700];
    
    [label sizeToFit];
    [cell layoutIfNeeded];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSString *)codeForTipCategory:(NSString *)category
{
    for (NSDictionary *aDict in combinedDicts)
    {
        if ([aDict[@"Name"] isEqualToString:category])
        {
            return aDict[@"Code"];
        }
    }
    
    return nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TipsCatToSubcatSegue"])
    {
        TipsSubCategoriesViewController *tipsSubVC = (TipsSubCategoriesViewController *)segue.destinationViewController;
        tipsSubVC.parentCategory = tipscategoryArray[[self.tableView indexPathForSelectedRow].row];
        tipsSubVC.parentCode = [self codeForTipCategory:tipsSubVC.parentCategory];
    }
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
    
    combinedDicts = json[@"aaData"][@"GenericSearchViewModels"];
    
    for (NSDictionary *aDict in combinedDicts)
    {
        if ([aDict[@"Status"] boolValue])
        {
            [tipscategoryArray addObject:aDict[@"Name"]];
        }
    }
    
    [self.tableView reloadData];
}

- (void)postman:(Postman *)postman gotFailure:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

@end
