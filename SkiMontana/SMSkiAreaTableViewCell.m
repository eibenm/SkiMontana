//
//  SMSkiAreaTableViewCell.m
//  SkiMontana
//
//  Created by Matt Eiben on 3/5/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMSkiAreaTableViewCell.h"

@interface SMSkiAreaTableViewCell() {
    UIView *_headerBackgroundLayer;
}

//@property (strong, nonatomic) UIView *headerBackgroundLayer;

@end

@implementation SMSkiAreaTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //[self drawHeaderBackground];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self drawHeaderBackground];
    }
    return self;
}

- (void)drawHeaderBackground
{
    if (!_headerBackgroundLayer) {
        _headerBackgroundLayer = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, 5, 5)];
        [_headerBackgroundLayer setBackgroundColor:[UIColor blackColor]];
        [_headerBackgroundLayer.layer setCornerRadius:4.5f];
        [_headerBackgroundLayer.layer setOpacity:0.5f];
        [self addSubview:_headerBackgroundLayer];
        [self sendSubviewToBack:_headerBackgroundLayer];
    }
}

- (void)layoutSubviews
{
    [_headerBackgroundLayer setFrame:CGRectInset(self.bounds, 5, 5)];
    [super layoutSubviews];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [UIView animateWithDuration:0.2 animations:^{
        [_headerBackgroundLayer.layer setOpacity:(highlighted ? 0.65f : 0.5f)];
    }];
    [super setHighlighted:highlighted animated:animated];
}

@end
