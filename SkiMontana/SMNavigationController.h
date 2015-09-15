//
//  SMNavigationController.h
//  SMTransitionAnimation
//
//  Created by Matt Eiben on 3/15/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMBaseAnimation.h"

@interface SMNavigationController : UINavigationController <UINavigationControllerDelegate>

/**
 Animation for the transition
 */
@property (strong, nonatomic) SMBaseAnimation *animationController;

/**
 Whether interaction should be enabled for transitioning
 */
@property (assign, nonatomic) BOOL interactionEnabled;

/** Inits with rootViewController and transitioning animations
 @param animation Animation for the transition
 @return An instance of SMFancyNavigationController
 */
- (id)initWithRootViewController:(UIViewController *)rootViewController withAnimation:(SMBaseAnimation *)animation;

@end
