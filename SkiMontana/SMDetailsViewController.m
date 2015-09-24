//
//  SMDetailsViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 4/26/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMDetailsViewController.h"
#import "SMRouteMapViewController.h"
#import "SMDetailsHeaderView.h"
#import "SMDetailsTableViewCell.h"

#import "SMSlideAnimation.h"

static NSString *cellIdentifier;

static CGFloat scalingFactor = 0.3f;

@interface SMDetailsViewController() <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet SMDetailsHeaderView *headerView;

@property (nonatomic, assign) CGFloat offsetStartingY;
@property (nonatomic, assign) CGFloat maxOffsetY;
@property (nonatomic, assign) CGFloat routeTopContraintHeight;

@end

@implementation SMDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.headerView.areaTitle setText:self.nameArea];
    [self.headerView.routeTitle setText:self.skiRoute.name_route];
    
    self.headerView.layer.zPosition = 2;
    self.offsetStartingY = self.headerView.frame.size.height;
    self.maxOffsetY = 40.0f;
    self.routeTopContraintHeight = self.headerView.routeTitleTopConstaint.constant;
    
    [self.tableView setContentInset:UIEdgeInsetsMake(self.offsetStartingY, 0, 0, 0)];
    [self.headerView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0.8 alpha:0.65]];
    
    // View for background color (opaque white mask)
    UIView *backgroundColorView = [[UIView alloc]initWithFrame:self.view.frame];
    [backgroundColorView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.8]];
    [self.view addSubview:backgroundColorView];
    [self.view sendSubviewToBack:backgroundColorView];

    // Background imageview
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RouteInfoBackground"]];
    [backgroundImageView setContentMode:UIViewContentModeScaleAspectFill];
    [backgroundImageView setFrame:self.view.frame];
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

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self scrollViewDidScroll:self.tableView];
    } completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0: cellIdentifier = @"map"; break;
        case 1: cellIdentifier = @"overview"; break;
        case 2: cellIdentifier = @"avalanche"; break;
        case 3: cellIdentifier = @"content"; break;
        case 4: cellIdentifier = @"directions"; break;
    }
    
    SMDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[SMDetailsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    if ([cellIdentifier isEqualToString:@"map"]) {
        [cell.imageMapBackground setImage:[UIImage imageNamed:@"Cell Bridger Range"]];
    }
    else if ([cellIdentifier isEqualToString:@"content"]) {
        [cell.labelElevation setText:[NSString stringWithFormat:@"Elevation Gain: %@ ft", self.skiRoute.elevation_gain]];
        [cell.labelVertical setText:[NSString stringWithFormat:@"Vertical: %@", self.skiRoute.vertical]];
        [cell.labelSlope setText:[NSString stringWithFormat:@"Aspects: %@", self.skiRoute.aspects]];
        [cell.labelDistance setText:[NSString stringWithFormat:@"Distance: ~%@ mi", self.skiRoute.distance]];
        [cell.labelSnowfall setText:[NSString stringWithFormat:@"Snowfall: %@", self.skiRoute.snowfall]];
        [cell.labelAvalanche setText:[NSString stringWithFormat:@"Terrain Danger: %@", self.skiRoute.avalanche_danger]];
        [cell.labelSkierTraffic setText:[NSString stringWithFormat:@"Skier Traffic: %@", self.skiRoute.skier_traffic]];
    }
    else if ([cellIdentifier isEqualToString:@"overview"]) {
        [cell.labelOverviewInformation setText:self.skiRoute.overview];
    }
    else if ([cellIdentifier isEqualToString:@"avalanche"]) {
        [cell.labelAvalancheInformation setText:self.skiRoute.avalanche_info];
    }
    else if ([cellIdentifier isEqualToString:@"directions"]) {
        [cell.labelDirectionsInformation setText:self.skiRoute.directions];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = UITableViewAutomaticDimension;
    
    switch (indexPath.row) {
        case 0: height = 120; break;
        case 1: height = 188; break;
        case 3: height = 350; break;
        case 2: height = 350; break;
        case 4: height = 350; break;
    }
    
    return height;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMDetailsTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    // If the map cell is selected, animate and then push to the next view controller
    if ([cell.reuseIdentifier isEqualToString:@"map"]) {
        CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        pulseAnimation.duration = 0.2f;
        pulseAnimation.toValue = [NSNumber numberWithFloat:1.1f];
        pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        pulseAnimation.fillMode = kCAFillModeForwards;
        pulseAnimation.removedOnCompletion = NO;
        pulseAnimation.autoreverses = NO;
        [CATransaction setCompletionBlock:^{
            SMDetailsViewController *thisViewController = (SMDetailsViewController *) self;
            SMRouteMapViewController *modalController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"routeMapViewController"];
            SMSlideAnimation *layerAnimation = [[SMSlideAnimation alloc] initWithType:SMSlideAnimationFromRight];
            thisViewController.animationController = layerAnimation;
            modalController.transitioningDelegate = self.transitioningDelegate;
            modalController.skiRoute = self.skiRoute;
            [self presentViewController:modalController animated:YES completion:^{
                [cell.imageMapBackground.layer removeAnimationForKey:pulseAnimation.keyPath];
            }];
        }];
        [cell.imageMapBackground.layer addAnimation:pulseAnimation forKey:pulseAnimation.keyPath];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.y;
    
    CGFloat offsetDiff = (-1.0f * self.offsetStartingY) - offset;
    
    // Adjusting table content inset
    // Adjusting height constraint on header
    // Adjusting labels in header
    // Adjuting opacity of area label
    
    //NSLog(@"%f", offsetDiff);
    
    if (offsetDiff < -80) {
        self.tableView.contentInset = UIEdgeInsetsMake(self.maxOffsetY, 0, 0, 0);
        self.headerView.headerViewHeight.constant = self.maxOffsetY;
        self.headerView.routeTitleTopConstaint.constant = self.routeTopContraintHeight - (80 * scalingFactor);
        self.headerView.areaTitle.layer.opacity = 0;
    }
    else if (offsetDiff > 0) {
        self.tableView.contentInset = UIEdgeInsetsMake(self.offsetStartingY, 0, 0, 0); // 150
        self.headerView.headerViewHeight.constant = self.offsetStartingY;
        self.headerView.routeTitleTopConstaint.constant = self.routeTopContraintHeight;
        self.headerView.areaTitle.layer.opacity = 1.0f;
    }
    else {
        self.tableView.contentInset = UIEdgeInsetsMake(ABS(offset), 0, 0, 0);
        self.headerView.headerViewHeight.constant = ABS(offset);
        self.headerView.routeTitleTopConstaint.constant = self.routeTopContraintHeight - (ABS(offsetDiff) * scalingFactor);
        self.headerView.areaTitle.layer.opacity = 1 - (ABS(offsetDiff) / 50); // Going opaque over the first 50 points
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showMap"]) {
        
        SMDetailsViewController *thisViewController = (SMDetailsViewController *) self;
        SMRouteMapViewController *modalController = [segue destinationViewController];
        SMSlideAnimation *layerAnimation = [[SMSlideAnimation alloc] initWithType:SMSlideAnimationFromRight];
        thisViewController.animationController = layerAnimation;
        modalController.transitioningDelegate = self.transitioningDelegate;
        modalController.skiRoute = self.skiRoute;
        
        /*
        CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        pulseAnimation.duration = 0.3f;
        pulseAnimation.toValue = [NSNumber numberWithFloat:1.1f];
        pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        pulseAnimation.autoreverses = NO;
        [CATransaction setCompletionBlock:^{
            SMDetailsViewController *thisViewController = (SMDetailsViewController *) self;
            SMRouteMapViewController *modalController = [segue destinationViewController];
            SMSlideAnimation *layerAnimation = [[SMSlideAnimation alloc] initWithType:SMSlideAnimationFromRight];
            thisViewController.animationController = layerAnimation;
            modalController.transitioningDelegate = self.transitioningDelegate;
            modalController.skiRoute = self.skiRoute;
        }];
        
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        SMDetailsTableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
        [cell.imageMapBackground.layer addAnimation:pulseAnimation forKey:nil];*/
    }
}

@end