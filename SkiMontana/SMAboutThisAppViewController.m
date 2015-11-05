//
//  SMAboutThisAppViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 11/2/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import "SMAboutThisAppViewController.h"
#import "SMTutorialPageViewController.h"

@interface SMAboutThisAppViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation SMAboutThisAppViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(dismissViewController)];
    UIBarButtonItem *tutorialButton = [[UIBarButtonItem alloc] initWithTitle:@"Tutorial" style:UIBarButtonItemStyleDone target:self action:@selector(presentTutorialPageViewController)];
    
    (self.navigationItem).leftBarButtonItem = backButton;
    (self.navigationItem).rightBarButtonItem = tutorialButton;
    
    self.title = @"About This App";
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)presentTutorialPageViewController
{
    SMTutorialPageViewController *tutorialViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"tutorialPageViewController"];
    [self.navigationController pushViewController:tutorialViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
