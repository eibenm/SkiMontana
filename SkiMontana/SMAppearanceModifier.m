//
//  SMAppearanceModifier.m
//  SkiMontana
//
//  Created by Matt Eiben on 3/15/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMAppearanceModifier.h"

@implementation SMAppearanceModifier

+ (void)defaultAppearance
{
    /*  Navbar Customizations */
    
    NSShadow *shadow = [NSShadow new];
    shadow.shadowColor = [UIColor colorWithWhite:0 alpha:0.8];
    shadow.shadowBlurRadius = 2.0f;
    shadow.shadowOffset = CGSizeZero;
    
    [UINavigationBar appearance].translucent = YES;
    [UINavigationBar appearance].barStyle = UIBarStyleDefault;
    [UINavigationBar appearance].titleTextAttributes = @{
        NSForegroundColorAttributeName: [UIColor blackColor],
        NSFontAttributeName: [UIFont boldSkiMontanaFontOfSize:20.0f],
    };
    
    /* UIBarButton Item Customizations */
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSkiMontanaFontOfSize:16.0]}
                                                forState:UIControlStateNormal];
}

@end
