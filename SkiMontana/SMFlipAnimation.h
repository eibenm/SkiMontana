//
//  SMFlipAnimation.h
//  SMTransitionAnimation
//
//  Created by Matt Eiben on 3/5/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMBaseAnimation.h"

/**
 Types of flip animation
 */
typedef NS_ENUM(NSInteger, SMFlipAnimationType) {
    SMFlipAnimationLeft,
    SMFlipAnimationRight,
    SMFlipAnimationTop,
    SMFlipAnimationBottom
};

@interface SMFlipAnimation : SMBaseAnimation

/** Inits with specific flip type.
 @param type Type of flip animation.
 @return An instance of SMFlipAnimation with the specified type.
 */
- (instancetype)initWithType:(SMFlipAnimationType)type;

@end
