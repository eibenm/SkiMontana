//
//  RSSHeaderView.m
//  SkiMontana
//
//  Created by Matt Eiben on 10/23/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import "RSSHeaderView.h"

@interface RSSHeaderView()

@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UILabel *label;

@property (strong, nonatomic) NSMutableArray *constraints;
@property (strong, nonatomic) CALayer *bottomBorder;

@end

@implementation RSSHeaderView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

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
    [[NSBundle mainBundle] loadNibNamed:@"RSSHeaderView" owner:self options:nil];
    [self addSubview:self.view];
    (self.view).translatesAutoresizingMaskIntoConstraints = NO;
    
    // Adding baseline to view
    CGRect rect = self.view.frame;
    self.bottomBorder = [CALayer layer];
    (self.bottomBorder).frame = CGRectMake(0, CGRectGetHeight(rect) - 2.5f, CGRectGetWidth(rect), 5.0f);
    (self.bottomBorder).backgroundColor = [UIColor grayColor].CGColor;
    (self.bottomBorder).masksToBounds = NO;
    (self.bottomBorder).shadowOpacity = 0.4;
    (self.bottomBorder).shadowRadius = 3.0f;
    (self.bottomBorder).shadowOffset = CGSizeMake(0, 2);
    
    [self.view.layer addSublayer:self.bottomBorder];
    
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

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    (self.bottomBorder).frame = CGRectMake(0, CGRectGetHeight(rect) - 2.5f, CGRectGetWidth(rect), 5.0f);
}

@end