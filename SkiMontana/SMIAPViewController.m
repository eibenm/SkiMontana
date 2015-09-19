//
//  SMIAPViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 9/19/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import "SMIAPViewController.h"

@interface SMIAPViewController () <UINavigationBarDelegate>

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) UINavigationItem *navItem;

@end

@implementation SMIAPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissViewController)];
    self.navItem = [[UINavigationItem alloc] initWithTitle:@"Purchase Ski Bozeman"];
    [self.navItem setLeftBarButtonItem:backButton];
    [self.navigationBar setItems:[NSArray arrayWithObject:self.navItem] animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIBarPositioningDelegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    if ([bar isKindOfClass:[UINavigationBar class]]) {
        return UIBarPositionTopAttached;
    }
    return UIBarPositionAny;
}

@end
