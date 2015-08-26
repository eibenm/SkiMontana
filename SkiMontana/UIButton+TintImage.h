//
//  UIButton+TintImage.h
//  Jumbler
//
//  Created by Filip Stefansson on 13-10-20.
//  Copyright (c) 2013 Pixby Media AB. All rights reserved.
//

@interface UIButton (TintImage)

-(void)setImageTintColor:(UIColor *)color forState:(UIControlState)state;
-(void)setBackgroundTintColor:(UIColor *)color forState:(UIControlState)state;

- (UIImage *)tintedImageWithColor:(UIColor *)tintColor image:(UIImage *)image;

+(void)tintButtonImages:(NSArray *)buttons withColor:(UIColor *)color forState:(UIControlState)state;
+(void)tintButtonBackgrounds:(NSArray *)buttons withColor:(UIColor *)color forState:(UIControlState)state;

@end
