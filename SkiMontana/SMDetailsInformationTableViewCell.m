//
//  SMDetailsInformationTableViewCell.m
//  SkiMontana
//
//  Created by Matt Eiben on 4/27/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMDetailsInformationTableViewCell.h"

@implementation SMDetailsInformationTableViewCell

// Adding 12 pixel border between cells
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 6.0);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 6.0);
    CGContextStrokePath(context);
}

@end
