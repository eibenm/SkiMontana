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

- (instancetype)initWithMapView:(RMMapView *)mapView
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
    
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:1.0];
    
    UIImageView *legendView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"legend"]];
    
    [legendView setTranslatesAutoresizingMaskIntoConstraints:NO];
    legendView.contentMode = UIViewContentModeScaleAspectFit;
    legendView.frame = self.view.bounds;
    
    [self.view addSubview:legendView];
    
    NSDictionary *views = @{ @"legendView" : legendView };
    NSDictionary *metrics = @{ @"spacing": @0.0f };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spacing-[legendView]-spacing-|" options:kNilOptions metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spacing-[legendView]-spacing-|" options:kNilOptions metrics:metrics views:views]];
    
    [self setDoneButton];
};

- (void)setDoneButton
{
    UIButton *attributionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [attributionButton setTitle:@"Done" forState:UIControlStateNormal];
    attributionButton.titleLabel.font = [UIFont boldSkiMontanaFontOfSize:20.0f];
    [attributionButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    attributionButton.layer.shadowColor = [UIColor blackColor].CGColor;
    attributionButton.layer.shadowOffset = CGSizeMake(0, 0);
    attributionButton.layer.shadowRadius = 3.0f;
    attributionButton.layer.shadowOpacity = 0.4f;
    attributionButton.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin);
    [attributionButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [attributionButton addTarget:self action:@selector(legendDismiss:) forControlEvents:UIControlEventTouchUpInside];
    attributionButton.frame = CGRectMake(
        self.view.bounds.size.width - attributionButton.bounds.size.width - 8,
        self.view.bounds.size.height - attributionButton.bounds.size.height - 8,
        attributionButton.bounds.size.width,
        attributionButton.bounds.size.height
    );
    
    [self.view addSubview:attributionButton];
    
    UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
    NSLayoutConstraint *rightConstraint = [attributionButton.rightAnchor constraintEqualToAnchor:guide.rightAnchor constant:-8.0f];
    NSLayoutConstraint *bottomConstraint = [attributionButton.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor constant:0];
    [NSLayoutConstraint activateConstraints:@[rightConstraint, bottomConstraint]];
}

- (void)legendDismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
