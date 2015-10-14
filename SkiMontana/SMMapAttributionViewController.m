//
//  SMMapAttributionViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 10/13/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import "SMMapAttributionViewController.h"
#import "RMMapView.h"

@interface RMMapView (RMAttributionViewControllerPrivate)

@property (nonatomic, assign) UIViewController *viewControllerPresentingAttribution;

@end

#pragma mark -

@interface SMMapAttributionViewController ()

@property (nonatomic, weak) RMMapView *mapView;

@end

#pragma mark -

@implementation SMMapAttributionViewController

- (id)initWithMapView:(RMMapView *)mapView
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _mapView = mapView;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = @"Map Legend";
    
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
    
    UIImageView *legendView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"legend"]];
    
    NSLog(@"%@", NSStringFromCGRect(legendView.frame));
    NSLog(@"%@", NSStringFromCGRect(self.view.bounds));
    
    [legendView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [legendView setContentMode:UIViewContentModeScaleAspectFit];
    
    CGFloat spacing;
    
    if (CGRectGetWidth(legendView.frame) < CGRectGetWidth(self.view.bounds) ||
        CGRectGetHeight(legendView.frame) < CGRectGetHeight(self.view.bounds))
    {
        CGFloat widthDiff = CGRectGetWidth(self.view.bounds) - CGRectGetWidth(legendView.frame);
        CGFloat heightDiff = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(legendView.frame);
        spacing = MIN(ABS(widthDiff), ABS(heightDiff));
        
        NSLog(@"%f", widthDiff);
        NSLog(@"%f", heightDiff);
    }
    else
    {
        spacing = 30.0f;
    }
    
    NSLog(@"%f", spacing);
    
    [legendView setFrame:CGRectInset(self.view.bounds, spacing, spacing)];
    [self.view addSubview:legendView];
    NSDictionary *views = @{ @"legendView" : legendView };
    NSDictionary *metrics = @{ @"spacing": [NSNumber numberWithFloat:spacing] };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spacing-[legendView]-spacing-|" options:kNilOptions metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spacing-[legendView]-spacing-|" options:kNilOptions metrics:metrics views:views]];
};






























@end
