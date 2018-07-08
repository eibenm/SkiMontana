//
//  SMSplitViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 5/28/17.
//  Copyright © 2017 Gneiss Software. All rights reserved.
//

#import "SMSplitViewController.h"

@interface SMSplitViewController ()

@end

@implementation SMSplitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;
    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    self.navigationItem.leftItemsSupplementBackButton = YES;
    
    //self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryOverlay;
    //self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAutomatic;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController
{
    return YES;
}

@end
