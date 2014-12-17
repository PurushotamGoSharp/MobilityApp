//
//  RaiseATicketViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/4/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "RaiseATicketViewController.h"
#import "PlaceHolderTextView.h"
#import "TikcetCategoryViewController.h"

@interface RaiseATicketViewController () <UIPickerViewDataSource,UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, TicketCategoryDelegate>
{
    NSArray *arrOfPickerViewData, *arrOfcolur;
    CGPoint initialOffsetOfSCrollView;
    UIEdgeInsets initialScollViewInset;
    
}
@property (weak, nonatomic) IBOutlet UITextView *textFldOutlet;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet PlaceHolderTextView *textView;
@property (weak, nonatomic) IBOutlet UIView *alphaViewOutLet;
@property (weak, nonatomic) IBOutlet UIView *pickerContainerViewOutlet;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerViewOutlet;
@property (weak, nonatomic) IBOutlet UITableView *tableViewOutlet;
@property (weak, nonatomic) IBOutlet UILabel *selectedCategorylabel;

@end

@implementation RaiseATicketViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arrOfPickerViewData = @[@"Low",@"Medium",@"High",@"Critical"];
    arrOfcolur = @[[UIColor greenColor],[UIColor yellowColor],[UIColor orangeColor],[UIColor redColor]];
    self.textView.placeholder = @"Describe you request here.";
    self.pickerContainerViewOutlet.layer.cornerRadius = 5;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.alphaViewOutLet.hidden = YES;
    self.pickerContainerViewOutlet.hidden = YES;
    self.alphaViewOutLet.alpha = 0;
    self.pickerContainerViewOutlet.alpha = 0;

    
    initialOffsetOfSCrollView = self.scrollView.contentOffset;
    initialScollViewInset = self.scrollView.contentInset;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)hideKeyboard:(UIControl *)sender
{
    if (self.scrollView.contentOffset.y >= 100)
    {
//        [self.scrollView setContentInset:initialScollViewInset];
        [self.scrollView setContentOffset:initialOffsetOfSCrollView animated:YES];
    }

    [self.view endEditing:YES];
}

- (IBAction)doneBtnAction:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        self.alphaViewOutLet.alpha = 0;
        self.pickerContainerViewOutlet.alpha = 0;
    } completion:^(BOOL finished) {
        self.alphaViewOutLet.hidden = YES;
        self.pickerContainerViewOutlet.hidden = YES;
    }];

    UITableViewCell *cell = [self.tableViewOutlet cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0 ]];
    UILabel *lable = (UILabel *)[cell viewWithTag:101];
    UIView *colourForline = (UIView *)[cell viewWithTag:102];
    UIView *colourForRect = (UIView *)[cell viewWithTag:103];
    lable.text = arrOfPickerViewData[[self.pickerViewOutlet selectedRowInComponent:0]];
    colourForline.backgroundColor = arrOfcolur[[self.pickerViewOutlet selectedRowInComponent:0]];
    colourForRect.backgroundColor = arrOfcolur[[self.pickerViewOutlet selectedRowInComponent:0]];

}



- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (self.scrollView.contentOffset.y <= 00)
    {
        initialOffsetOfSCrollView = self.scrollView.contentOffset;
        initialScollViewInset = self.scrollView.contentInset;
    }
    
//    [self.scrollView setContentInset:(UIEdgeInsetsMake(100, 0, 0, 0))];
    [self.scrollView setContentOffset:(CGPointMake(0, 100)) animated:YES];
    
}

#pragma mark UIPickerViewDataSource methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [arrOfPickerViewData count];
}

//-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    return arrOfPickerViewData[row];
//}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    
    UIView *containerView;
    UIView *viewForImage;
    UILabel *viewForLable;
    
    if (view == nil)
    {
        containerView = [[UIView alloc] init];
        containerView.frame = CGRectMake(0, 0, self.pickerViewOutlet.frame.size.width, 30);
        
        viewForImage = [[UIView alloc] init];
        viewForImage.frame = CGRectMake(10, 0, 40, 30);
        
        viewForLable = [[UILabel alloc] init];
        viewForLable.frame = CGRectMake(60,0, 100, 30);
        
        [containerView addSubview:viewForImage];
        [containerView  addSubview:viewForLable];
    }
    
    viewForImage.backgroundColor = arrOfcolur[row];
    viewForLable.text = arrOfPickerViewData[row];
    return containerView;
    
}



//- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
//{
//    return 25;
//}

- (IBAction)imapctValueChanged:(UISlider *)sender
{
    sender.value = roundf(sender.value);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    UILabel *header = (UILabel *)[cell viewWithTag:100];
    UILabel *lable = (UILabel *)[cell viewWithTag:101];
    
    UIView *colourForline = (UIView *)[cell viewWithTag:102];
    UIView *colourForRect = (UIView *)[cell viewWithTag:103];

    colourForRect.layer.cornerRadius = 10;
    
    if (indexPath.row == 0)
    {
        header.text = @"Requester";
        lable.text = @"Jean-Pierre";

    }else
    {
        header.text = @"Impact";
        lable.text = @"Low";
        colourForline.backgroundColor = [UIColor greenColor];
        colourForRect.backgroundColor = [UIColor greenColor];
    
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 1)
    {
        self.alphaViewOutLet.hidden = NO;
        self.pickerContainerViewOutlet.hidden = NO;

        [UIView animateWithDuration:.3 animations:^{
            self.alphaViewOutLet.alpha = .6;
            self.pickerContainerViewOutlet.alpha = 1;
//            [self.view layoutIfNeeded];
        } completion:^(BOOL finished)
        {
            
        }];
        
    }
    
}



- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender 
{
    if ([segue.identifier isEqualToString:@"SelectAcategorySegue"])
    {
        UINavigationController *navController = segue.destinationViewController;
        TikcetCategoryViewController *ticketCategoryVC = navController.viewControllers[0];
        ticketCategoryVC.delegate = self;
    }
}

- (void)selectedTicket:(NSString *)tickt
{
    self.selectedCategorylabel.text = tickt;
    self.selectedCategorylabel.textColor = [UIColor blackColor];
}

@end
