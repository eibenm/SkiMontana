//
//  SMTutorialPageViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 11/4/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import "SMTutorialPageViewController.h"
#import "SMTutorialContentViewController.h"

@interface SMTutorialPageViewController () <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UIView *pageControlBar;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (strong, nonatomic) NSArray *pageImages;

- (IBAction)dismissViewController:(id)sender;

@end

@implementation SMTutorialPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Tutorial";
    
    self.pageImages = @[
        @"_piLE7cySNJp1qVjb5BN_X21S0A7GUTy",
        @"2K8Wqwb0tQCv32P3bJGqB9QpS_WG80CZ",
        @"7ca-fuBQKDVNgA6W3GUUuZI5YP-yGlGj"
    ];
    
    // Create page view controller
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
    (self.pageViewController).dataSource = self;
    
    SMTutorialContentViewController *startingViewController = [self viewControllerAtIndex:0];
    [self.pageViewController setViewControllers:@[startingViewController]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
    
    (self.pageViewController).view.frame = self.view.frame;
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
    
    (self.pageControl).numberOfPages = (self.pageImages).count;
    (self.pageControl).currentPage = 0;
    (self.pageControl).pageIndicatorTintColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.5];
    (self.pageControl).currentPageIndicatorTintColor = [UIColor whiteColor];
    (self.pageControlBar).backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.9];
    (self.view).backgroundColor = [UIColor blackColor];
    
    [self.view bringSubviewToFront:self.pageControlBar];
    [self.view bringSubviewToFront:self.pageControl];
    [self.view bringSubviewToFront:self.dismissButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [super viewWillDisappear:animated];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)dismissViewController:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (SMTutorialContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (((self.pageImages).count == 0) || (index >= (self.pageImages).count)) {
        return nil;
    }
    
    SMTutorialContentViewController *tutorialContentViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"tutorialContentViewController"];
    tutorialContentViewController.image = self.pageImages[index];
    tutorialContentViewController.pageIndex = index;
    
    return tutorialContentViewController;
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((SMTutorialContentViewController *) viewController).pageIndex;
    (self.pageControl).currentPage = index;
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((SMTutorialContentViewController *) viewController).pageIndex;
    (self.pageControl).currentPage = index;
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    if (index == (self.pageImages).count) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

@end
