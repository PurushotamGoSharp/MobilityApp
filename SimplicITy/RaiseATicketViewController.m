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
@property (weak, nonatomic) IBOutlet UIView *tipViewOutlet;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *listBarBtnOutlet;
@property (weak, nonatomic) IBOutlet UILabel *CategoryTitleOutlet;
@property (weak, nonatomic) IBOutlet UILabel *tipsLableOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *bulbImgOutlet;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceBetweenimpactAndServiceConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceServiceToImpactConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lowRightCOnstraint;

@end

@implementation RaiseATicketViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arrOfPickerViewData = @[@"Critical",@"High",@"Medium",@"Low"];
    arrOfcolur = @[[UIColor redColor],[UIColor orangeColor],[UIColor yellowColor],[UIColor colorWithRed:.37 green:.72 blue:.38 alpha:1]];
    self.textView.placeholder = @"Describe your request here.";
    self.pickerContainerViewOutlet.layer.cornerRadius = 5;
    
    if ([self.orderDiffer isEqualToString:@"orderBtnPressed"])
    {
        
        self.title = @"Place an Order";
        self.tipViewOutlet.hidden = YES;
        self.CategoryTitleOutlet.text = @"Items";
        self.selectedCategorylabel.text = @"Select a item";
        self.navigationItem.leftBarButtonItems = @[];
        
        self.spaceBetweenimpactAndServiceConstant.constant = 220;
        self.spaceServiceToImpactConstant.constant = 2;

    }
    else
    {
        self.spaceServiceToImpactConstant.constant = -3;

        self.title = @"Raise a Ticket";

    }
}

- (IBAction)saveBtnPressed:(id)sender
{
    NSString *alertMessage;
    
    if ([self.orderDiffer isEqualToString:@"orderBtnPressed"])
    {
        alertMessage = @"Your Order has been saved !";
    }
    else
    {
        alertMessage = @"Your Ticket has been saved !";
    }
    
    UIAlertView *saveAlestView = [[UIAlertView alloc] initWithTitle:@"Alert!" message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [saveAlestView show];

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    self.bulbImgOutlet.animationImages =
//    [NSArray arrayWithObjects:[UIImage imageNamed:@"alert_tip"],[UIImage imageNamed:@"alert_tip1"],nil];
//    self.bulbImgOutlet.animationDuration = 1;
//    self.bulbImgOutlet.animationRepeatCount = 1000;
//    [self.bulbImgOutlet startAnimating];
    
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
        viewForImage.frame = CGRectMake(10, 5, 20, 20);
        viewForImage.layer.cornerRadius = 10;
        
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
    UITableViewCell *cell = nil;
    
    if ([self.orderDiffer isEqualToString:@"orderBtnPressed"] && indexPath.row == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SliderCell" forIndexPath:indexPath];
        UISlider *sliderOutlet = (UISlider *)[cell viewWithTag:300];
        [sliderOutlet setThumbImage:[self imageForSLiderThumb:roundf(sliderOutlet.value)] forState:(UIControlStateNormal)];
        [sliderOutlet addTarget:self action:@selector(sliderValueChanged:) forControlEvents:(UIControlEventValueChanged)];
        return cell;
    }else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    }
    
    if (![self.orderDiffer isEqualToString:@"orderBtnPressed"] && (indexPath.row == 1))
    {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
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
        colourForline.backgroundColor = [UIColor colorWithRed:.37 green:.72 blue:.38 alpha:1];
        colourForRect.backgroundColor = [UIColor colorWithRed:.37 green:.72 blue:.38 alpha:1];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 1 && [self.orderDiffer isEqualToString:@"orderBtnPressed"])
    {
        return;
    }
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1 && [self.orderDiffer isEqualToString:@"orderBtnPressed"])
    {
        return 200;
    }
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
        if ([self.orderDiffer isEqualToString:@"orderBtnPressed"])
        {
            ticketCategoryVC.orderItemDiffer = @"orderItemsData";
        }
    }
}

- (void)selectedTicket:(NSString *)tickt
{
    self.selectedCategorylabel.text = tickt;
    self.selectedCategorylabel.textColor = [UIColor lightGrayColor];
}

-(void)selectedTips:(NSString *)tip
{
    self.tipsLableOutlet.text = tip;
}

- (void)sliderValueChanged:(UISlider *)slider
{
    UILabel *critical;
    UILabel *high;
    UILabel *medium;
    UILabel *low;
    
    if ([self.orderDiffer isEqualToString:@"orderBtnPressed"]) {
        UITableViewCell *impactCell = [self.tableViewOutlet cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        

        low = (UILabel *)[impactCell viewWithTag:10];
        medium = (UILabel *)[impactCell viewWithTag:20];
        high = (UILabel *)[impactCell viewWithTag:30];
        critical = (UILabel *)[impactCell viewWithTag:40];

    }
    
    slider.value = roundf(slider.value);
    
    [slider setThumbImage:[self imageForSLiderThumb:roundf(slider.value)] forState:(UIControlStateNormal)];

    if (slider.value == 3 )
    {
        [slider setTintColor:([UIColor redColor])];
        
        low.textColor = [UIColor lightGrayColor];
        medium.textColor = [UIColor lightGrayColor];
        high.textColor = [UIColor lightGrayColor];
        critical.textColor = [UIColor blackColor];

    }else if (slider.value == 2)
    {
        [slider setTintColor:([UIColor orangeColor])];
        
        low.textColor = [UIColor lightGrayColor];
        medium.textColor = [UIColor lightGrayColor];
        high.textColor = [UIColor blackColor];
        critical.textColor = [UIColor lightGrayColor];
        
    }else if (slider.value == 1)
    {
        [slider setTintColor:([UIColor yellowColor])];
        
        low.textColor = [UIColor lightGrayColor];
        medium.textColor = [UIColor blackColor];
        high.textColor = [UIColor lightGrayColor];
        critical.textColor = [UIColor lightGrayColor];
    } if (slider.value ==0)
    {
        low.textColor = [UIColor blackColor];
        medium.textColor = [UIColor lightGrayColor];
        high.textColor = [UIColor lightGrayColor];
        critical.textColor = [UIColor lightGrayColor];
    }
}

- (UIImage *)imageForSLiderThumb:(NSInteger)value
{
    switch (value)
    {
        case 0:
            return [UIImage imageNamed:@"greenCirlce"];
            break;
            
        case 1:
            return [UIImage imageNamed:@"YellowCircle"];
            break;
            
        case 2:
            return [UIImage imageNamed:@"OrangeCircle"];
            break;
            
        case 3:
            return [UIImage imageNamed:@"RedCircle"];
            break;
            
        default:
            break;
    }
    return nil;
}

@end
