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
static CGFloat maxOffsetDiff = 46.0f;

@interface SMDetailsViewController() <UITableViewDelegate, UITableViewDataSource, UIDocumentInteractionControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet SMDetailsHeaderView *headerView;

@property (nonatomic, strong) UIDocumentInteractionController *docController;
@property (nonatomic, strong) UIImageView *kmlImage;
@property (nonatomic, strong) UILabel *kmlLabel;

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
    
    (self.headerView.areaTitle).text = self.nameArea;
    (self.headerView.routeTitle).text = self.skiRoute.name_route;
    
    self.headerView.layer.zPosition = 2;
    self.offsetStartingY = self.headerView.frame.size.height;
    self.maxOffsetY = self.headerView.frame.size.height - maxOffsetDiff;
    self.routeTopContraintHeight = self.headerView.routeTitleTopConstaint.constant;
    
    (self.tableView).contentInset = UIEdgeInsetsMake(self.offsetStartingY, 0, 0, 0);
    (self.headerView).backgroundColor = [UIColor colorwithHexString:@"#0000ff" alpha:0.7];
    
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    return 7;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0: cellIdentifier = @"map"; break;
        case 1: cellIdentifier = @"overview"; break;
        case 2: cellIdentifier = @"avalanche"; break;
        case 3: cellIdentifier = @"content"; break;
        case 4: cellIdentifier = @"getting_there"; break;
        case 5: cellIdentifier = @"directions"; break;
        case 6: cellIdentifier = @"kml"; break;
    }
    
    SMDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[SMDetailsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.6f alpha:0.2];
    
    if ([cellIdentifier isEqualToString:@"map"]) {
        (cell.imageMapBackground).image = [UIImage imageNamed:self.skiRoute.name_route];
    }
    else if ([cellIdentifier isEqualToString:@"content"]) {
        (cell.labelElevation).text = [NSString stringWithFormat:@"Elevation Gain: %@ ft", self.skiRoute.elevation_gain];
        (cell.labelVertical).text = [NSString stringWithFormat:@"Vertical: %@", self.skiRoute.vertical];
        (cell.labelSlope).text = [NSString stringWithFormat:@"Aspects: %@", self.skiRoute.aspects];
        (cell.labelDistance).text = [NSString stringWithFormat:@"Distance: ~%@ mi", self.skiRoute.distance];
        (cell.labelSnowfall).text = [NSString stringWithFormat:@"Snowfall: %@", self.skiRoute.snowfall];
        (cell.labelAvalanche).text = [NSString stringWithFormat:@"Terrain Danger: %@", self.skiRoute.avalanche_danger];
        (cell.labelSkierTraffic).text = [NSString stringWithFormat:@"Skier Traffic: %@", self.skiRoute.skier_traffic];
    }
    else if ([cellIdentifier isEqualToString:@"overview"]) {
        (cell.labelOverviewInformation).text = self.skiRoute.overview;
    }
    else if ([cellIdentifier isEqualToString:@"avalanche"]) {
        (cell.labelAvalancheInformation).text = self.skiRoute.avalanche_info;
    }
    else if ([cellIdentifier isEqualToString:@"getting_there"]) {
        (cell.labelDirectionsInformation).text = self.skiRoute.directions;
    }
    else if ([cellIdentifier isEqualToString:@"directions"]) {
        nil;
    }
    else if ([cellIdentifier isEqualToString:@"kml"]) {
        // Add KML Image
        self.kmlImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"EllisKML"]];
        (self.kmlImage).contentMode = UIViewContentModeScaleAspectFill;
        (self.kmlImage).translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:self.kmlImage];
        NSDictionary *imageViews = @{ @"kmlImage": self.kmlImage };
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[kmlImage]|" options:kNilOptions metrics:nil views:imageViews]];
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[kmlImage]|" options:kNilOptions metrics:nil views:imageViews]];
        [self.kmlImage addConstraint:[NSLayoutConstraint constraintWithItem:self.kmlImage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:240.0f]];
        
        // Add KML Label
        self.kmlLabel = [UILabel new];
        (self.kmlLabel).text = @"View KML";
        (self.kmlLabel).textColor = [UIColor whiteColor];
        (self.kmlLabel).font = [UIFont fontWithName:@"Avenir Book" size:16.0f];
        (self.kmlLabel).translatesAutoresizingMaskIntoConstraints = NO;
        (self.kmlLabel).autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin);
        [cell.contentView addSubview:self.kmlLabel];
        NSDictionary *labelViews = @{ @"kmlLabel":self.kmlLabel };
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[kmlLabel]" options:kNilOptions metrics:nil views:labelViews]];
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[kmlLabel]-8-|" options:kNilOptions metrics:nil views:labelViews]];
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
        case 0: height = 180; break;
        case 1: height = 188; break;
        case 3: height = 350; break;
        case 2: height = 350; break;
        case 4: height = 350; break;
        case 5: height = 44; break;
        case 6: height = 240; break;
        default: break;
    }
    
    return height;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMDetailsTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // If the map cell is selected, animate and then push to the next view controller
    if ([cell.reuseIdentifier isEqualToString:@"map"]) {
        CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        pulseAnimation.duration = 0.2f;
        pulseAnimation.toValue = @1.1f;
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
                [cell.mapTapLabel.layer removeAnimationForKey:pulseAnimation.keyPath];
            }];
        }];
        [cell.imageMapBackground.layer addAnimation:pulseAnimation forKey:pulseAnimation.keyPath];
        [cell.mapTapLabel.layer addAnimation:pulseAnimation forKey:pulseAnimation.keyPath];
    }
    
    // Open up appropriate mapping App for directions to parking lot
    if ([cell.reuseIdentifier isEqualToString:@"directions"]) {
        NSSet *gpsPoints = (self.skiRoute).ski_route_gps;
        
        double latitude = 40.0f;
        double longitude = -180.0f;
        
        for (Gps *gps in gpsPoints) {
            if ([gps.waypoint isEqualToString:@"Parking"]) {
                latitude = gps.lat.doubleValue;
                longitude = gps.lon.doubleValue;
            }
        }
        
        // Google Maps: https://developers.google.com/maps/documentation/ios-sdk/urlscheme?hl=en
        // Apple Maps: https://developer.apple.com/library/ios/featuredarticles/iPhoneURLScheme_Reference/MapLinks/MapLinks.html
        
        NSURL *googleUrl = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?saddr=&daddr=%f,%f&directionsmode=driving&views=satellite", latitude, longitude]];
        NSURL *appleMapsUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.apple.com/?daddr=%f,%f&dirflg=d&t=h", latitude, longitude]];
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
            [[UIApplication sharedApplication] openURL:googleUrl];
        }
        else {
            [[UIApplication sharedApplication] openURL:appleMapsUrl];
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    // Open KMZ in Google Earth
    if ([cell.reuseIdentifier isEqualToString:@"kml"]) {
        CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        pulseAnimation.duration = 0.2f;
        pulseAnimation.toValue = @1.1f;
        pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        pulseAnimation.fillMode = kCAFillModeForwards;
        pulseAnimation.removedOnCompletion = NO;
        pulseAnimation.autoreverses = YES;
        [CATransaction setCompletionBlock:^{
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgoogleearth://"]]) {
                NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:self.skiRoute.name_route withExtension:@"kmz"];
                self.docController = [UIDocumentInteractionController interactionControllerWithURL:fileUrl];
                [self.docController presentOpenInMenuFromRect:self.view.bounds inView:self.view animated:YES];
            }
            else {
                [self showNeedGoogleEarthAlert];
            }
            [(self.kmlImage).layer removeAnimationForKey:pulseAnimation.keyPath];
            [(self.kmlLabel).layer removeAnimationForKey:pulseAnimation.keyPath];
        }];
        [(self.kmlImage).layer addAnimation:pulseAnimation forKey:pulseAnimation.keyPath];
        [(self.kmlLabel).layer addAnimation:pulseAnimation forKey:pulseAnimation.keyPath];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)showNeedGoogleEarthAlert
{
    NSString *message = [NSString stringWithFormat:@"The Google Earth app is needed to view KML files from %@.", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"]];
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"Google Earth" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *googleEarthAction = [UIAlertAction actionWithTitle:@"Get Google Earth" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSURL *itunesGoogleEarthLink = [NSURL URLWithString:@"https://itunes.apple.com/us/app/google-earth/id293622097?mt=8"];
        if ([[UIApplication sharedApplication] canOpenURL:itunesGoogleEarthLink]) {
            [[UIApplication sharedApplication] openURL:itunesGoogleEarthLink];
        }
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    
    [alertView addAction:googleEarthAction];
    [alertView addAction:okAction];
    
    [self presentViewController:alertView animated:YES completion:nil];
}

// This is needed on ios8
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell layoutIfNeeded];
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
    
    if (offsetDiff < (-1 * maxOffsetDiff)) {
        self.tableView.contentInset = UIEdgeInsetsMake(self.maxOffsetY, 0, 0, 0);
        self.headerView.headerViewHeight.constant = self.maxOffsetY;
        self.headerView.routeTitleTopConstaint.constant = self.routeTopContraintHeight - (maxOffsetDiff * scalingFactor);
        self.headerView.areaTitle.layer.opacity = 0;
    }
    else if (offsetDiff > 0) {
        self.tableView.contentInset = UIEdgeInsetsMake(self.offsetStartingY, 0, 0, 0);
        self.headerView.headerViewHeight.constant = self.offsetStartingY;
        self.headerView.routeTitleTopConstaint.constant = self.routeTopContraintHeight;
        self.headerView.areaTitle.layer.opacity = 1.0f;
    }
    else {
        self.tableView.contentInset = UIEdgeInsetsMake(ABS(offset), 0, 0, 0);
        self.headerView.headerViewHeight.constant = ABS(offset);
        self.headerView.routeTitleTopConstaint.constant = self.routeTopContraintHeight - (ABS(offsetDiff) * scalingFactor);
        self.headerView.areaTitle.layer.opacity = 1 - (ABS(offsetDiff) / 20); // Going opaque over the first 20 points
    }
}

#pragma mark - Navigation

/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showMap"]) {
        SMDetailsViewController *thisViewController = (SMDetailsViewController *) self;
        SMRouteMapViewController *modalController = segue.destinationViewController;
        SMSlideAnimation *layerAnimation = [[SMSlideAnimation alloc] initWithType:SMSlideAnimationFromRight];
        thisViewController.animationController = layerAnimation;
        modalController.transitioningDelegate = self.transitioningDelegate;
        modalController.skiRoute = self.skiRoute;
    }
}
*/
@end