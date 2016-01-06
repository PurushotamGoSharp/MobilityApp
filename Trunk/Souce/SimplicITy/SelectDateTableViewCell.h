//
//  SelectDateTableViewCell.h
//  SimplicITy
//
//  Created by Varghese Simon on 4/16/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SelectDateTableViewCell;

@protocol SelectDateCellDelegate <NSObject>

- (void)selectedCell:(SelectDateTableViewCell *)cell timeChanged:(UIDatePicker *)datePicker;

@end


@interface SelectDateTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) id<SelectDateCellDelegate> delegate;

@end
