//
//  SliderView.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/18/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "SliderView.h"

@interface SliderView () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SliderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self initiateView];
    }
    
    return self;
}

- (id)init
{
    id view = [[[NSBundle mainBundle] loadNibNamed:@"SliderView" owner:nil options:nil] lastObject];
    [(SliderView *)view initiateView];
    
    return view;
}

- (void)initiateView
{
    
}


@end
