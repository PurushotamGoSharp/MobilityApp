//
//  UINavigationController+CustomOrientation.m
//  SimplicITy
//
//  Created by Vmoksha on 02/04/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "UINavigationController+CustomOrientation.h"

@implementation UINavigationController (CustomOrientation)

-(NSUInteger)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

-(BOOL)shouldAutorotate
{
    return YES;
}

@end
