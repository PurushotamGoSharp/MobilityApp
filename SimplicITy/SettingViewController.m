//
//  SettingViewController.m
//  SimplicITy
//
//  Created by Vmoksha on 10/12/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "SettingViewController.h"
#import "LanguageViewController.h"

@interface SettingViewController ()<UITableViewDataSource,UITableViewDelegate,languagesSettingdelegate >
{
   NSArray  *arrOfTableViewData, *arrOfImages ;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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

//- (IBAction)changeLanguageBtnPressed:(id)sender
//{
//    arrOfData = arrOfLanguageData;
//    [UIView animateWithDuration:.3 animations:^{
//        self.alphaViewOutlet.alpha=0.3;
//        self.containerViewOutlet.alpha=1;
//        
//    } completion:^(BOOL finished)
//     {
//         self.alphaViewOutlet.hidden= NO;
//         self.containerViewOutlet.hidden= NO;
//         [self.pickerViewOutlet reloadAllComponents];
//     }];
//
//}
//- (IBAction)changeLocationBtnPressed:(id)sender
//{
//    arrOfData = arrOfLocationData;
//    
//    [UIView animateWithDuration:.3 animations:^{
//        self.alphaViewOutlet.alpha=0.3;
//        self.containerViewOutlet.alpha=1;
//        
//    } completion:^(BOOL finished)
//     {
//         self.alphaViewOutlet.hidden= NO;
//         self.containerViewOutlet.hidden= NO;
//         [self.pickerViewOutlet reloadAllComponents];
//     }];
//
//}
//- (IBAction)doneBtnPressed:(id)sender
//{
// 
//    [UIView animateWithDuration:.3 animations:^{
//        self.alphaViewOutlet.alpha=0;
//        self.containerViewOutlet.alpha=0;
//
//    } completion:^(BOOL finished)
//    {
//        self.alphaViewOutlet.hidden= YES;
//        self.containerViewOutlet.hidden= YES;
//    }];
//}

//#pragma mark UIPickerViewDataSource methods
//
//-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
//{
//    return 1;
//}
//
//-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
//{
//    return [arrOfData count];
//}
//-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    return arrOfData[row];
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
