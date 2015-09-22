//
//  SMAreaOverviewViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 3/15/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMAreaOverviewViewController.h"

@interface SMAreaOverviewViewController() <UINavigationBarDelegate>

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (strong, nonatomic) IBOutlet UILabel *labelAreaTitle;
@property (strong, nonatomic) IBOutlet UIImageView *imageMapView;
@property (strong, nonatomic) IBOutlet UITextView *textViewDescription;
@property (strong, nonatomic) IBOutlet UIView *viewImages;

@end

@implementation SMAreaOverviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBar.delegate = self;
    
    // Setting up Back Button on Nav Bar
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissViewController)];
    UINavigationItem *navItem = [UINavigationItem new];
    [navItem setLeftBarButtonItem:backButton];
    [self.navigationBar setItems:@[navItem] animated:NO];
    
    [self.labelAreaTitle setText:self.skiArea.name_area];
    [self.textViewDescription setText:self.skiArea.conditions];
    
    [self.textViewDescription.textContainer setLineFragmentPadding:0];
    [self.textViewDescription setTextContainerInset:UIEdgeInsetsZero];
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
