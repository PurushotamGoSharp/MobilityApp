//
//  CEPanAnimationController.m
//  TransitionsDemo
//
//  Created by Alvin Zeng on 01/08/2014.
//  Copyright (c) 2014 Alvin Zeng. All rights reserved.
//

#import "CEPanAnimationController.h"

@implementation CEPanAnimationController

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    self.duration = .3;
    // Add the toView to the container
    UIView* containerView = [transitionContext containerView];
    [containerView addSubview:toView];
    toView.frame = CGRectMake(self.reverse ? -screenWidth/2 : screenWidth, toView.frame.origin.y, toView.frame.size.width, toView.frame.size.height);
    
    self.reverse ? [containerView sendSubviewToBack:toView] : [containerView bringSubviewToFront:toView];
    
    if (self.reverse)
    {
        fromView.layer.borderWidth = 1;
        fromView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }else
    {
        toView.layer.borderWidth = 1;
        toView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    
    // animate
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration
                          delay:0
                        options:(self.reverse ? UIViewAnimationOptionCurveEaseIn: UIViewAnimationOptionCurveEaseOut)
                     animations:^{
                         
                         fromView.frame = CGRectMake(!self.reverse ? -screenWidth/2 : screenWidth, fromView.frame.origin.y, fromView.frame.size.width, fromView.frame.size.height);
                         toView.frame = CGRectMake(0, toView.frame.origin.y, toView.frame.size.width, toView.frame.size.height);
                         
                     }
                     completion:^(BOOL finished) {
                         
                         fromView.layer.borderWidth = 0;
                         fromView.layer.borderColor = [UIColor blackColor].CGColor;
                         toView.layer.borderWidth = 0;
                         toView.layer.borderColor = [UIColor blackColor].CGColor;
                         
                         if ([transitionContext transitionWasCancelled]) {
                             
                             toView.frame = CGRectMake(0, toView.frame.origin.y, toView.frame.size.width, toView.frame.size.height);
                             fromView.frame = CGRectMake(0, fromView.frame.origin.y, fromView.frame.size.width, fromView.frame.size.height);
                             
                         } else {
                             // reset from- view to its original state
                             [fromView removeFromSuperview];
                             fromView.frame = CGRectMake(!self.reverse ? -screenWidth/2 : screenWidth, fromView.frame.origin.y, fromView.frame.size.width, fromView.frame.size.height);
                             toView.frame = CGRectMake(0, toView.frame.origin.y, toView.frame.size.width, toView.frame.size.height);
                         }
                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                     }];
    
}

@end
