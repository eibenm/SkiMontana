//
//  SMScaleAnimation.h
//  SMTransitionAnimation
//
//  Created by Matt Eiben on 3/5/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMBaseAnimation.h"

/**
 Types of scale animation
 */

typedef NS_ENUM(NSInteger, SMScaleAnimationType){
    SMScaleAnimationFadeIn,
    SMScaleAnimationDropIn
};

@interface SMScaleAnimation : SMBaseAnimation

/** Inits with specific zooming type.
 @param type Type of scale animation.
 @return An instance of SMScaleAnimation with the specified type.
 */
- (instancetype) initWithType:(SMScaleAnimationType)type;

@end
