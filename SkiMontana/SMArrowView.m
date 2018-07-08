//
//  SMArrowView.m
//  SkiMontana
//
//  Created by Matt Eiben on 10/6/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import "SMArrowView.h"

@interface SMArrowView()

@property (nonatomic, assign) SMArrowType arrowType;
@property (nonatomic, assign) NSInteger stroke;
@property (nonatomic, strong) UIColor *color;

@end

@implementation SMArrowView

- (instancetype)initWithFrame:(CGRect)frame arrowType:(SMArrowType)arrowType color:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        self.arrowType = arrowType;
        self.color = color;
        self.stroke = 2;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    
    if (self.arrowType == SMArrowUp) {
        CGContextMoveToPoint(context, CGRectGetMinX(rect) + self.stroke, CGRectGetMaxY(rect) - self.stroke);
        CGContextAddLineToPoint(context, CGRectGetMidX(rect), CGRectGetMinY(rect) + self.stroke);
        CGContextAddLineToPoint(context, CGRectGetMaxX(rect) - self.stroke, CGRectGetMaxY(rect) - self.stroke);
    }
    
    if (self.arrowType == SMArrowDown) {
        CGContextMoveToPoint(context, CGRectGetMinX(rect) + self.stroke, CGRectGetMinY(rect) + self.stroke);
        CGContextAddLineToPoint(context, CGRectGetMidX(rect), CGRectGetMaxY(rect) - self.stroke);
        CGContextAddLineToPoint(context, CGRectGetMaxX(rect) - self.stroke, CGRectGetMinY(rect) + self.stroke);
    }
    
    if (self.arrowType == SMArrowRight) {
        CGContextMoveToPoint(context, CGRectGetMinX(rect) + self.stroke, CGRectGetMinY(rect) + self.stroke);
        CGContextAddLineToPoint(context, CGRectGetMaxX(rect) - self.stroke, CGRectGetMidY(rect));
        CGContextAddLineToPoint(context, CGRectGetMinX(rect) + self.stroke, CGRectGetMaxY(rect) - self.stroke);
    }
    
    if (self.arrowType == SMArrowLeft) {
        CGContextMoveToPoint(context, CGRectGetMaxX(rect) - self.stroke, CGRectGetMinY(rect) + self.stroke);
        CGContextAddLineToPoint(context, CGRectGetMinX(rect) + self.stroke, CGRectGetMidY(rect));
        CGContextAddLineToPoint(context, CGRectGetMaxX(rect) - self.stroke, CGRectGetMaxY(rect) - self.stroke);
    }
    
    CGContextSetStrokeColorWithColor(context, self.color.CGColor);
    CGContextSetLineWidth(context, (CGFloat)self.stroke);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 4, [UIColor colorWithWhite:0.8 alpha:0.6].CGColor);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

@end
