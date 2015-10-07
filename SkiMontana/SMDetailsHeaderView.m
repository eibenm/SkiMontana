//
//  SMDetailsHeaderView.m
//  SkiMontana
//
//  Created by Matt Eiben on 9/8/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMDetailsHeaderView.h"

@implementation SMDetailsHeaderView

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // Adding border to bottom of view
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor] );
    CGContextSetLineWidth(context, 4.0);
    CGContextStrokePath(context);
    
    // Setting route title text shadow
    self.routeTitle.layer.shadowColor = [UIColor blackColor].CGColor;
    self.routeTitle.layer.shadowRadius = 2.0f;
    self.routeTitle.layer.shadowOpacity = 0.8f;
    self.routeTitle.layer.shadowOffset = CGSizeZero;
    self.routeTitle.layer.masksToBounds = NO;
    
    // Setting area title text shadow
    self.areaTitle.layer.shadowColor = [UIColor blackColor].CGColor;
    self.areaTitle.layer.shadowRadius = 2.0f;
    self.areaTitle.layer.shadowOpacity = 0.8f;
    self.areaTitle.layer.shadowOffset = CGSizeZero;
    self.areaTitle.layer.masksToBounds = NO;
}

@end
