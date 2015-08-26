//
//  SMOverviewMapViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 3/2/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMOverviewMapViewController.h"

@interface SMOverviewMapViewController ()

@end

@implementation SMOverviewMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupBackButton];
}

- (void)setupBackButton
{
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(dismissViewController)];
    [self.navigationItem setLeftBarButtonItem:doneButton];
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
