//
//  TicketsListCell.m
//  SimplicITy
//
//  Created by Varghese Simon on 12/11/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "TicketsListCell.h"

@interface TicketsListCell ()
@property (weak, nonatomic) IBOutlet UIView *colorCodeView;
@property (weak, nonatomic) IBOutlet UILabel *ticketHeadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *agentAssignedLabel;

@property (weak, nonatomic) IBOutlet UILabel *noOfDaysBeforeRaised;

@end

@implementation TicketsListCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
