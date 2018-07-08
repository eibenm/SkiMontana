//
//  SMLayerAnimation.h
//  SMTransitionAnimation
//
//  Created by Matt Eiben on 3/5/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMBaseAnimation.h"

/**
 Types of layer animation
 */
typedef NS_ENUM(NSInteger, SMLayerAnimationType) {
    SMLayerAnimationCover,
    SMLayerAnimationReveal
};

@interface SMLayerAnimation : SMBaseAnimation

/** Inits with specific layer type.
 @param type Type of layer animation.
 @return An instance of SMLayerAnimation with the specified type.
 */
- (instancetype)initWithType:(SMLayerAnimationType)type;

@end
