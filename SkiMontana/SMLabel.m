//
//  SMLabel.m
//  SkiMontana
//
//  Created by Matt Eiben on 10/28/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import "SMLabel.h"

@implementation SMLabel

- (void)drawTextInRect:(CGRect)rect
{
    CGSize shadowOffset = self.shadowOffset;
    UIColor *textColor = self.textColor;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 3);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    CGContextSetTextDrawingMode(context, kCGTextStroke);
    self.textColor = [UIColor whiteColor];
    [super drawTextInRect:rect];
    
    CGContextSetTextDrawingMode(context, kCGTextFill);
    self.textColor = textColor;
    self.shadowOffset = CGSizeZero;
    [super drawTextInRect:rect];
    
    self.shadowOffset = shadowOffset;
}

@end
