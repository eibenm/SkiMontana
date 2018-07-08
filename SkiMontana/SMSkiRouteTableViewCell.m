//
//  SMSkiRouteTableViewCell.m
//  SkiMontana
//
//  Created by Matt Eiben on 3/5/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMSkiRouteTableViewCell.h"

@interface SMSkiAreaTableViewCell()

@end

@implementation SMSkiRouteTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if ([self.reuseIdentifier isEqualToString:@"SkiRoute"]) {
            [self drawBackground];
        }
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        if ([self.reuseIdentifier isEqualToString:@"SkiRoute"]) {
            [self drawBackground];
        }
    }
    return self;
}

- (void)drawBackground
{
    if (!self.routeBackgroundLayer) {
        self.routeBackgroundLayer = [UIView new];
        (self.routeBackgroundLayer).backgroundColor = [UIColor blackColor];
        (self.routeBackgroundLayer.layer).opacity = 0.5f;
        [self addSubview:self.routeBackgroundLayer];
        [self sendSubviewToBack:self.routeBackgroundLayer];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    (self.routeBackgroundLayer).frame = CGRectMake(5, 0, CGRectGetWidth(self.bounds) - 10, CGRectGetHeight(self.bounds));
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [UIView animateWithDuration:0.2 animations:^{
        (self.routeBackgroundLayer.layer).opacity = (highlighted ? 0.65f : 0.5f);
    }];
}

@end
