//
//  TipDetailsViewController.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/11/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "TipDetailsViewController.h"

@interface TipDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIView *viewAtIndex0;
@property (weak, nonatomic) IBOutlet UIView *viewAtIndex1;

@property (weak, nonatomic) IBOutlet UITextView *textView1;
@property (weak, nonatomic) IBOutlet UITextView *textView2;

@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end

@implementation TipDetailsViewController
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.parentCategory;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.textView1 setFont:[UIFont systemFontOfSize:15]];
    [self.textView2 setFont:[UIFont systemFontOfSize:15]];
    
    if (self.index == 0)
    {
        self.textView2.text = self.textToDisplay;
        self.viewAtIndex0.hidden = YES;
        self.viewAtIndex1.hidden = NO;
        
        if (self.fileName)
        {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:self.fileName ofType:@"mp4"];
            NSURL *videoURL = [NSURL fileURLWithPath:filePath];
            NSLog(@"File path = %@", filePath);
            self.videoController = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
            self.videoController.movieSourceType = MPMovieSourceTypeFile;
            [self.videoController.view setFrame:CGRectMake(0, 50, 320, 160)];
            self.videoController.controlStyle = MPMovieControlStyleEmbedded;
            self.videoController.fullscreen = NO;
            
            [self.viewAtIndex1 addSubview:self.videoController.view];
            [self.viewAtIndex1 bringSubviewToFront:self.playButton];
            self.playButton.hidden = NO;
        }
        
    }else
    {
        self.textView1.text = self.textToDisplay;
        self.viewAtIndex0.hidden = NO;
        self.viewAtIndex1.hidden = YES;
        
    }
}

- (IBAction)playButton:(UIButton *)sender
{
    self.playButton.hidden = YES;
    NSLog(@"%hhd", self.videoController.isPreparedToPlay);
    [self.videoController prepareToPlay];
    [self.videoController play];
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
