//
//  TikcetCategoryViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/15/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "TikcetCategoryViewController.h"

@interface TikcetCategoryViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancleBarBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TikcetCategoryViewController
{
    NSInteger selectedRow;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self selectTableViewCell];
    
    NSLog(@"from %@",self.orderItemDiffer);
    
//    if ([self.orderItemDiffer isEqualToString:@"orderList"])
//    {
//        self.title = @"Items";
//        
//    }else
//    {
//        self.title = @"Services";
//    }

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localize) name:MCLocalizationLanguageDidChangeNotification object:nil];
    [self localize];

}



-(void)localize
{

    self.title = STRING_FOR_LANGUAGE(@"ITSOS.Services");
     [self.navigationItem.leftBarButtonItem setTitle:STRING_FOR_LANGUAGE(@"Cancel")];
    
}







- (void)selectTableViewCell
{
    if (self.selectedCategory == nil)
    {
        return;
    }
    
    for (int i = 0; i < [self.categoryArray count]; i++)
    {
        CategoryModel *model = self.categoryArray[i];
        
        if ([model.categoryCode isEqualToString:self.selectedCategory.categoryCode])
        {
            selectedRow = i;
        }
    }
    
    [self.tableView reloadData];
}

- (IBAction)cancelBtnAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.categoryArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
     UILabel *label = (UILabel *)[cell viewWithTag:100];
   
    label.font=[self customFont:16 ofName:MuseoSans_700];

    CategoryModel *category = self.categoryArray[indexPath.row];

    label.text = category.categoryName;
    
    label.highlightedTextColor = [UIColor whiteColor];

    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [self barColorForIndex:selectedRow];
    [cell setSelectedBackgroundView:bgColorView];
    
    if (indexPath.row == selectedRow && self.selectedCategory != nil)
    {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:(UITableViewScrollPositionNone)];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.delegate selectedCategory:self.categoryArray[indexPath.row]];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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
