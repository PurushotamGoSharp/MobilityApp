//
//  SelectDateTableViewCell.m
//  SimplicITy
//
//  Created by Varghese Simon on 4/16/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "SelectDateTableViewCell.h"

@implementation SelectDateTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)daetPickerValueChanged:(UIDatePicker *)sender
{
    [self.delegate selectedCell:self timeChanged:self.datePicker];
}

@end
