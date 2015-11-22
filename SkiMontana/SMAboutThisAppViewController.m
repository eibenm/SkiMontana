//
//  SMAboutThisAppViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 11/2/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import "SMAboutThisAppViewController.h"
#import "SMGlossaryTableViewController.h"

static NSString *gneisssoftware = @"http://www.gneisssoftware.com";
static NSString *bozemanSkiGuide = @"http://bozemanskiguide.com";
static NSString *email = @"mailto:ty@gneisssoftware.com?cc=matt@gneisssoftware.com&subject=Ski Bozeman Support";
static NSString *privacyPolicy = @"http://www.gneisssoftware.com/privacy";
static NSString *manageSubscriptionsUrl = @"https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions";

@interface SMAboutThisAppViewController ()

- (IBAction)didClickViewGneisssoftware:(id)sender;
- (IBAction)didClickViewBozemanSkiGuide:(id)sender;
- (IBAction)didClickEmailTyAtGneisssoftware:(id)sender;
- (IBAction)didClickViewPrivacyPolicy:(id)sender;
- (IBAction)didClickManageSubscriptions:(id)sender;

@end

@implementation SMAboutThisAppViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(dismissViewController)];
    UIBarButtonItem *glossaryButton = [[UIBarButtonItem alloc] initWithTitle:@"Glossary" style:UIBarButtonItemStyleDone target:self action:@selector(presentGlossaryViewController)];
    
    self.navigationItem.leftBarButtonItem = backButton;
    self.navigationItem.rightBarButtonItem = glossaryButton;
    self.title = @"About This App";
        
    // View for background color (opaque white mask)
    UIView *backgroundColorView = [[UIView alloc]initWithFrame:self.view.frame];
    backgroundColorView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    [self.view addSubview:backgroundColorView];
    [self.view sendSubviewToBack:backgroundColorView];
    
    // Background imageview
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RouteInfoBackground"]];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImageView.frame = self.view.frame;
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    
    // Setting autolayout constraints for background views
    [backgroundColorView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [backgroundImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *backgroundColorViews = NSDictionaryOfVariableBindings(backgroundColorView);
    NSDictionary *backgroundImageViews = NSDictionaryOfVariableBindings(backgroundImageView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundColorView]|" options:kNilOptions metrics:nil views:backgroundColorViews]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundColorView]|" options:kNilOptions metrics:nil views:backgroundColorViews]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundImageView]|" options:kNilOptions metrics:nil views:backgroundImageViews]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundImageView]|" options:kNilOptions metrics:nil views:backgroundImageViews]];
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)presentGlossaryViewController
{
    SMGlossaryTableViewController *glossaryViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"glossaryTableViewController"];
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:nil action:nil];
    (self.navigationItem).backBarButtonItem = newBackButton;
    [self.navigationController pushViewController:glossaryViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)didClickViewGneisssoftware:(id)sender
{
    NSURL *gneisssoftwareUrl = [NSURL URLWithString:gneisssoftware];
    if ([[UIApplication sharedApplication] canOpenURL:gneisssoftwareUrl]) {
        [[UIApplication sharedApplication] openURL:gneisssoftwareUrl];
    }
}

- (IBAction)didClickViewBozemanSkiGuide:(id)sender
{
    NSURL *bozemanSkiGuideUrl = [NSURL URLWithString:bozemanSkiGuide];
    if ([[UIApplication sharedApplication] canOpenURL:bozemanSkiGuideUrl]) {
        [[UIApplication sharedApplication] openURL:bozemanSkiGuideUrl];
    }
}

- (IBAction)didClickEmailTyAtGneisssoftware:(id)sender
{
    NSString *emailUrl = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *developerSuppport = [NSURL URLWithString:emailUrl];
    [[UIApplication sharedApplication] openURL:developerSuppport];
}

- (IBAction)didClickViewPrivacyPolicy:(id)sender
{
    NSURL *privacyPolicyUrl = [NSURL URLWithString:privacyPolicy];
    if ([[UIApplication sharedApplication] canOpenURL:privacyPolicyUrl]) {
        [[UIApplication sharedApplication] openURL:privacyPolicyUrl];
    }
}

- (IBAction)didClickManageSubscriptions:(id)sender
{
    NSURL *manageUrl = [NSURL URLWithString:manageSubscriptionsUrl];
    if ([[UIApplication sharedApplication] canOpenURL:manageUrl]) {
        [[UIApplication sharedApplication] openURL:manageUrl];
    }
}

@end
