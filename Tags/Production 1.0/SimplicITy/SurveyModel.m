//
//  SurveyModel.m
//  SimplicITy
//
//  Created by Varghese Simon on 2/16/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "SurveyModel.h"

@implementation SurveyModel
- (instancetype)init
{
    self = [super init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cleanMemory)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    return self;
}

- (void)cleanMemory
{
    NSLog(@"Dealloc images");
    self.image = nil;
}

@end
