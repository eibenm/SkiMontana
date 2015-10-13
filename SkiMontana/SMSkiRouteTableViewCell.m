//
//  SMSkiRouteTableViewCell.m
//  SkiMontana
//
//  Created by Matt Eiben on 3/5/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMSkiRouteTableViewCell.h"

@interface SMSkiRouteTableViewCell ()

@property (strong, nonatomic) CALayer *backgroundLayer;

@end

@implementation SMSkiRouteTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //[self drawBackground];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        //[self drawBackground];
    }
    return self;
}

- (void)drawBackground
{
    if (!_backgroundLayer) {
        _backgroundLayer = [CALayer layer];
        [_backgroundLayer setCornerRadius:4.5f];
        [_backgroundLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
        [_backgroundLayer setOpacity:0.5f];
        [_backgroundLayer setZPosition:-1];
        [self.layer insertSublayer:_backgroundLayer below:self.layer];
    }
}

- (void)layoutSubviews
{
    [_backgroundLayer setFrame:CGRectInset(self.bounds, 5, 5)];
    [super layoutSubviews];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (highlighted) {
        [_backgroundLayer setOpacity:0.65f];
    }
    else {
        [_backgroundLayer setOpacity:0.5f];
    }
    
    [super setHighlighted:highlighted animated:animated];
}
    
@end
