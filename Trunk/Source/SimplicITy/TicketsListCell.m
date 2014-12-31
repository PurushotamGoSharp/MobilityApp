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

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentStatusLabel;

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

- (void)setTicketModel:(TicketModel *)ticketModel
{
    _ticketModel = ticketModel;
    
    self.colorCodeView.backgroundColor = ticketModel.colorCode;
    self.ticketHeadingLabel.text = ticketModel.ticketSubject;
    self.agentAssignedLabel.text =  ticketModel.agentName;
    
    NSString * status = [NSString stringWithFormat:@"%@, %@",ticketModel.ticketNum, ticketModel.currentStatus];
    self.currentStatusLabel.text =status;
    self.timeLabel.text = ticketModel.timeStamp;
}

@end
