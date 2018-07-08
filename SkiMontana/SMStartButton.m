//
//  SMStartButton.m
//  SkiMontana
//
//  Created by Matt Eiben on 10/21/17.
//  Copyright © 2017 Gneiss Software. All rights reserved.
//

#import "SMStartButton.h"

@implementation SMStartButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor blueColor];
        self.layer.cornerRadius = 8.0f;
        self.layer.borderColor = [UIColor colorWithWhite:0.2f alpha:0.6f].CGColor;
        self.layer.borderWidth = 1.0f;
        [self.layer addSublayer:[self getLayerGradient]];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.backgroundColor = [UIColor blueColor];
        self.layer.cornerRadius = 8.0;
        self.layer.borderColor = [UIColor colorWithWhite:0.2 alpha:0.6].CGColor;
        self.layer.borderWidth = 1.0;
        [self.layer addSublayer:[self getLayerGradient]];
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // performing animation that causes the button to "jump" when tapped
    
    self.transform = CGAffineTransformMakeScale(1.05, 1.05);
    
    [UIView animateWithDuration:0.8
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:6
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{ self.transform = CGAffineTransformIdentity; }
                     completion:nil];
    
    [super touchesBegan:touches withEvent:event];
}

- (CAGradientLayer *) getLayerGradient
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.layer.bounds;
    gradientLayer.colors = @[
         (id)[UIColor colorWithWhite:1.0 alpha:0.5].CGColor,
         (id)[UIColor colorWithWhite:0.4 alpha:0.5].CGColor
     ];
    gradientLayer.locations = @[@0, @0.5, @1.0];
    gradientLayer.cornerRadius = self.layer.cornerRadius;
    gradientLayer.startPoint = CGPointMake(0.5, 0.0);
    gradientLayer.endPoint = CGPointMake(0.5, 1.0);
    
    return gradientLayer;
}

@end
