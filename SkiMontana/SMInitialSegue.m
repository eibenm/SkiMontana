//
//  SMInitialSegue.m
//  SkiMontana
//
//  Created by Matt Eiben on 3/1/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMInitialSegue.h"

@implementation SMInitialSegue

- (void) perform
{
    UIViewController *src = (UIViewController *) self.sourceViewController;
    UINavigationController *dst = (UINavigationController *) self.destinationViewController;
    
    void (^animations)(void) = ^(void) {
        [src.navigationController setNavigationBarHidden:NO];
        [src.navigationController setViewControllers:dst.viewControllers animated:NO];
    };
    
    [UIView transitionWithView:src.navigationController.view
                      duration:0.6
                       options:UIViewAnimationOptionTransitionFlipFromBottom
                    animations:animations
                    completion:nil];
}


@end
