//
//  UIFont+SkiMontana.h
//  SkiMontana
//
//  Created by Gneiss Software on 2/22/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "UIFont+SkiMontana.h"

@implementation UIFont (SkiMontana)

+ (UIFont *)skiMontanaFontOfSize:(CGFloat)pointSize
{
    return [UIFont fontWithName:@"Avenir-Roman" size:pointSize];
}

+ (UIFont *)boldSkiMontanaFontOfSize:(CGFloat)pointSize
{
    return [UIFont fontWithName:@"Avenir-Heavy" size:pointSize];
}

+ (UIFont *)mediumSkiMontanaFontOfSize:(CGFloat)pointSize
{
    return [UIFont fontWithName:@"Avenir-Medium" size:pointSize];
}

@end
