//
//  LanguageViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 11/12/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "LanguageViewController.h"

@interface LanguageViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray  *arrOfLanguageData;
    UILabel *titleLable;
    NSIndexPath* lastIndexPath;
    NSInteger selectedRow;

}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation LanguageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    arrOfLanguageData = @[@"English",@"Dutch",@"German",@"Franch",@"German",@"Spanish",@"Japanese"];

}

- (IBAction)cancelBtnPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneBtnPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSString *selectedlanguage = arrOfLanguageData[[self.tableView indexPathForSelectedRow].row];
    [self.delegate selectedLanguageis:selectedlanguage];
}

#pragma mark UITableViewDataSource methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrOfLanguageData count];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    
    titleLable = (UILabel *)[cell viewWithTag:100];
    titleLable.text = arrOfLanguageData[indexPath.row];
    titleLable.highlightedTextColor = [UIColor whiteColor];
    
//    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [self barColorForIndex:selectedRow];
    [cell setSelectedBackgroundView:bgColorView];

    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark UITableViewDelegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRow = indexPath.row;

//    UIView *bgColorView = [[UIView alloc] init];
//    bgColorView.backgroundColor = [UIColor redColor];
//    [cell setSelectedBackgroundView:bgColorView];
    
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    
//    UITableViewCell* newCell = [tableView cellForRowAtIndexPath:indexPath];
//    int newRow = [indexPath row];
//    
//    int oldRow = (lastIndexPath != nil) ? [lastIndexPath row] : -1;
//    
//    if(newRow != oldRow)
//    {
//        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
//        UITableViewCell* oldCell = [tableView cellForRowAtIndexPath:lastIndexPath];
//        oldCell.accessoryType = UITableViewCellAccessoryNone;
//        lastIndexPath = indexPath;
//    }
    
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
