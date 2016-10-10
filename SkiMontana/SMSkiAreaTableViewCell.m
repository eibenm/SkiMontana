//
//  SMSkiAreaTableViewCell.m
//  SkiMontana
//
//  Created by Matt Eiben on 3/5/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMSkiAreaTableViewCell.h"

@interface SMSkiAreaTableViewCell()

@end

@implementation SMSkiAreaTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if ([self.reuseIdentifier isEqualToString:@"SkiArea"]) {
            [self drawBackground];
        }
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        if ([self.reuseIdentifier isEqualToString:@"SkiArea"]) {
            [self drawBackground];
        }
    }
    return self;
}

- (void)drawBackground
{
    if (!self.areaBackgroundLayer) {
        self.areaBackgroundLayer = [UIView new];
        (self.areaBackgroundLayer).backgroundColor = [UIColor blackColor];
        (self.areaBackgroundLayer.layer).opacity = 0.5f;
        [self addSubview:self.areaBackgroundLayer];
        [self sendSubviewToBack:self.areaBackgroundLayer];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    (self.areaBackgroundLayer).frame = CGRectMake(5, 5, CGRectGetWidth(self.bounds) - 10, CGRectGetHeight(self.bounds));
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [UIView animateWithDuration:0.2 animations:^{
        (self.areaBackgroundLayer.layer).opacity = (highlighted ? 0.65f : 0.5f);
    }];
}

@end
