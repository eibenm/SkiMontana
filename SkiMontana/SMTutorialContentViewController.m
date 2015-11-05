//
//  SMTutorialContentViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 11/4/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import "SMTutorialContentViewController.h"

@interface SMTutorialContentViewController ()

@end

@implementation SMTutorialContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.image]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = self.view.frame;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:imageView];
    NSDictionary *views = @{ @"imageView": imageView };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:kNilOptions metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:kNilOptions metrics:nil views:views]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
