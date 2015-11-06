//
//  SMAboutThisAppViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 11/2/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import "SMAboutThisAppViewController.h"
#import "SMGlossaryTableViewController.h"

@interface SMAboutThisAppViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation SMAboutThisAppViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(dismissViewController)];
    UIBarButtonItem *glossaryButton = [[UIBarButtonItem alloc] initWithTitle:@"Glossary" style:UIBarButtonItemStyleDone target:self action:@selector(presentGlossaryViewController)];
    
    (self.navigationItem).leftBarButtonItem = backButton;
    (self.navigationItem).rightBarButtonItem = glossaryButton;
    
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

@end
