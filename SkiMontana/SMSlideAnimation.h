//
//  SMBounceAnimation.h
//  SMTransitionAnimation
//
//  Created by Matt Eiben on 3/5/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMBaseAnimation.h"

/**
 Types of sliding animation
 */
typedef NS_ENUM (NSInteger, SMSlideAnimationType){
    SMSlideAnimationFromLeft,
    SMSlideAnimationFromRight,
    SMSlideAnimationFromTop,
    SMSlideAnimationFromBottom
};

@interface SMSlideAnimation : SMBaseAnimation

/**
 Velocity of the sliding.
 */
@property (assign, nonatomic) CGFloat velocity;

/**
 Damping of the sliding.
 */
@property (assign, nonatomic) CGFloat damping;

/** Inits with specific sliding type.
 @param type sliding direction.
 @return An instance of SMBounceAnimation with the specified bouncing direction.
 */
- (instancetype) initWithType:(SMSlideAnimationType)type;

@end
