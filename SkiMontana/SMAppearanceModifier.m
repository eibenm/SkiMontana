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
    
    //UIEdgeInsets navBarImageInsets = UIEdgeInsetsMake(0.0f, 4.0f, 0.0f, 4.0f);
    //UIImage *navBarImage = [[UIImage imageNamed:@"nav_bg.png"] resizableImageWithCapInsets:navBarImageInsets];
    
    //[[UINavigationBar appearance] setTintColor:[UIColor darkGrayColor]];
    //[[UINavigationBar appearance] setBackgroundImage:navBarImage forBarMetrics:UIBarMetricsDefault];
    
    NSShadow *shadow = [NSShadow new];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    
    [[UINavigationBar appearance] setTranslucent:YES];
    [UINavigationBar appearance].titleTextAttributes = @{
        //NSForegroundColorAttributeName: [UIColor darkGrayColor],
        //NSShadowAttributeName: shadow,
        NSFontAttributeName: [UIFont boldSkiMontanaFontOfSize:20.0f],
    };
    
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    /* UIBarButton Item Customizations */
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSkiMontanaFontOfSize:16.0]}
                                                forState:UIControlStateNormal];
}

@end
