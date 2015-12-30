//
//  RSSDataLoadingView.m
//  SkiMontana
//
//  Created by Matt Eiben on 12/29/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import "RSSDataLoadingView.h"

@interface RSSDataLoadingView()

@property (weak, nonatomic) IBOutlet UIView *view;
@property (strong, nonatomic) NSMutableArray *constraints;

@end

@implementation RSSDataLoadingView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.constraints = [[NSMutableArray alloc] init];
    [[NSBundle mainBundle] loadNibNamed:@"RSSDataLoadingView" owner:self options:nil];
    [self addSubview:self.view];
    (self.view).layer.cornerRadius = 4.0f;
    (self.view).translatesAutoresizingMaskIntoConstraints = NO;
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints
{
    [self removeConstraints:self.constraints];
    [self.constraints removeAllObjects];
    if (self.view != nil) {
        NSDictionary *views = @{ @"view" : self.view };
        [self.constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:kNilOptions metrics:nil views:views]];
        [self.constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:kNilOptions metrics:nil views:views]];
        [self addConstraints:self.constraints];
    }
    [super updateConstraints];
}

@end
