//
//  SMAboutThisAppViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 11/2/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import "SMAboutThisAppViewController.h"

@interface SMAboutThisAppViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation SMAboutThisAppViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(dismissViewController)];
    
    (self.navigationItem).leftBarButtonItem = backButton;
    
    self.title = @"About This App";
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
