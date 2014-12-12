//
//  SettingViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 10/12/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "SettingViewController.h"
#import "LanguageViewController.h"
#import "LocationViewController.h"

@interface SettingViewController ()<UITableViewDataSource,UITableViewDelegate,languagesSettingdelegate,LocationSettingdelegate >
{
   NSArray  *arrOfTableViewData, *arrOfImages ;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Settings";
    
    arrOfTableViewData = @[@"Language",@"Location"];
    arrOfImages = @[@"language.png",@"lacation.png"];
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"language_segue"])
    {
        UINavigationController *navController = segue.destinationViewController;
        LanguageViewController *lang = navController.viewControllers[0];
        lang.delegate =self;
    }else
    {
        UINavigationController *navController = segue.destinationViewController;
        LocationViewController *locationVC = navController.viewControllers[0];
        locationVC.delegate = self;

        
    }
}

#pragma mark UITableViewDataSource methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrOfTableViewData count];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:100];
    imageView.image = [UIImage imageNamed:arrOfImages[indexPath.row]];
    
    UILabel *titleLable = (UILabel *)[cell viewWithTag:200];
    titleLable.text = arrOfTableViewData[indexPath.row];
    
    UILabel *languageLabel = (UILabel *)[cell viewWithTag:201];
    
    if (indexPath.row == 0) {
        languageLabel.text = @"Dutch";

    }else
    {
        languageLabel.text = @"Belgium";

    }
   

    return cell;
}

#pragma mark UITableViewDelegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0)
    {
        [self performSegueWithIdentifier:@"language_segue" sender:self];

    }
    else
    {
        [self performSegueWithIdentifier:@"location_segue" sender:self];

    }
    
}


#pragma mark

-(void)selectedLanguageis:(NSString *)language
{
    UITableViewCell *languageCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    UILabel *languageLabel = (UILabel *)[languageCell viewWithTag:201];
    languageLabel.text = language;
}

-(void)selectedLocationIs:(NSString *)location
{
    UITableViewCell *languageCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UILabel *languageLabel = (UILabel *)[languageCell viewWithTag:201];
    languageLabel.text = location;

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