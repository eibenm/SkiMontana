//
//  SMDataLoading.m
//  SkiMontana
//
//  Created by Matt Eiben on 9/13/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMDataLoading.h"

static NSString *labelLookingForUpdate = @"Looking for update";
static NSString *labelFoundUpdate = @"Found update!";
static NSString *labelLoadingNewData = @"App is loading new data!";

@implementation SMDataLoading

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"SMDataLoading" owner:self options:nil];
        NSDictionary *views = @{@"loadingView":self.view};
        [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.view];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[loadingView]|" options:kNilOptions metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[loadingView]|" options:kNilOptions metrics:nil views:views]];
                
        //NSLog(@"%@", self.view.constraints);
        //NSLog(@"%@", self.constraints);
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"SMDataLoading" owner:self options:nil];
        [self addSubview:self.view];
    }
    return self;
}

- (void)setLabelLookingForUpdate
{
    [self.loadingLabel setText:labelLookingForUpdate];
}

- (void)setLabelFoundUpdate
{
    [self.loadingLabel setText:labelLoadingNewData];
}

- (void)setLabelUpdatingApp
{
    [self.loadingLabel setText:labelLoadingNewData];
}

@end
