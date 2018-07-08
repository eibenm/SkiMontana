//
//  SMBaseAnimation.m
//  SMTransitionAnimation
//
//  Created by Matt Eiben on 3/5/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMBaseAnimation.h"

@implementation SMBaseAnimation

#pragma mark - Init method

- (id) init
{
    self = [super init];
    if (self) {
        self.animationDuration = 1.0f;
    }
    return self;
}


#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.animationDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *fromView = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view;
    UIView *toView = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view;
    
    [self animateTransition:transitionContext fromView:fromView toView:toView];
}


#pragma mark - Helper methods

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext fromView:(UIView*)fromView toView:(UIView*)toView
{
    
}

- (void)setInteractionEnabled
{
    
}

@end
