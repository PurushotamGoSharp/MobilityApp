//
//  MessageDetailViewController.h
//  SimplicITy
//
//  Created by Vmoksha on 03/12/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "messageModle.h"
#import "NewsContentModel.h"

@interface MessageDetailViewController : CustomColoredViewController
{
    
}
@property(nonatomic,strong)NewsContentModel *newsContent;
@property(nonatomic,strong )NSString *categoryName;


@property (strong,nonatomic)messageModle *mesgModel;
@property (strong,nonatomic)NSString *newsDetail;

@end
