//
//  UIColor+FromHex.m
//  SkiMontana
//
//  Created by Matt Eiben on 3/15/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "UIColor+FromHex.h"

@implementation UIColor (FromHex)

+ (UIColor *)colorwithHexString:(NSString *)hexStr alpha:(CGFloat)alpha;
{
    //-----------------------------------------
    // Convert hex string to an integer
    //-----------------------------------------
    unsigned int hexint = 0;
    
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    [scanner scanHexInt:&hexint];
    
    //-----------------------------------------
    // Create color object, specifying alpha
    //-----------------------------------------
    return [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                           green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                            blue:((CGFloat) (hexint & 0xFF))/255
                           alpha:alpha];
}

@end
