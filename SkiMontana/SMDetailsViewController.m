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
#import "MWPhotoBrowser.h"

static NSString *cellIdentifier;

static CGFloat scalingFactor = 0.3f;
static CGFloat maxOffsetDiff = 46.0f;

@interface SMDetailsViewController() <UITableViewDelegate, UITableViewDataSource, UIDocumentInteractionControllerDelegate, MWPhotoBrowserDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet SMDetailsHeaderView *headerView;

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIDocumentInteractionController *docController;
@property (nonatomic, strong) UIImageView *kmlImage;
@property (nonatomic, strong) UILabel *kmlLabel;
@property (nonatomic, assign) CGFloat offsetStartingY;
@property (nonatomic, assign) CGFloat maxOffsetY;
@property (nonatomic, assign) CGFloat routeTopContraintHeight;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) CAGradientLayer *maskLayer;
@property (nonatomic, assign) BOOL notesExist;

@end

@implementation SMDetailsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    // Adding custom back button
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton addTarget:self action:@selector(dismissViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.backButton setTitle:@"Back" forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    (self.backButton).titleLabel.font = [UIFont boldSkiMontanaFontOfSize:17.0f];
    (self.backButton).translatesAutoresizingMaskIntoConstraints = NO;
    (self.backButton).layer.zPosition = 100.0f;
    [self.backButton sizeToFit];
    [self.view addSubview:self.backButton];
    NSDictionary *views = @{ @"backButton": self.backButton, @"topLayoutGuide": self.topLayoutGuide };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayoutGuide]-1-[backButton]" options:kNilOptions metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[backButton]" options:kNilOptions metrics:nil views:views]];
    
    // Creating mask on route title so it doesn't overflow underneath the back button
    if (!self.maskLayer ) {
        self.maskLayer = [CAGradientLayer layer];
        (self.maskLayer).colors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor, (id)[UIColor whiteColor].CGColor];
        (self.maskLayer).locations = @[@0, @0.13, @0.15, @1.0];
        (self.maskLayer).anchorPoint = CGPointMake(0, 0.25);
        (self.maskLayer).startPoint = CGPointMake(0.0, 0.5);
        (self.maskLayer).endPoint = CGPointMake(1.0, 0.5);
        
        (self.headerView).routeTitle.layer.mask = self.maskLayer;
        //[(self.headerView).routeTitle.layer addSublayer:self.maskLayer];
        (self.headerView).routeTitle.layer.masksToBounds = YES;
    }
    
    [super viewWillAppear:animated];
}

- (void)viewDidLayoutSubviews
{
    (self.maskLayer).bounds = (self.headerView).bounds;
    [super viewDidLayoutSubviews];
}

- (void)dismissViewController
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}

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
    
    self.notesExist = ((self.skiRoute).notes.length == 0) ? NO : YES;
    
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

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // Update header view offset
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
    if (self.notesExist == YES) {
        return 10;
    }
    
    return 9;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.notesExist == YES) {
        switch (indexPath.row) {
            case 0: cellIdentifier = @"map"; break;
            case 1: cellIdentifier = @"overview"; break;
            case 2: cellIdentifier = @"avalanche"; break;
            case 3: cellIdentifier = @"content"; break;
            case 4: cellIdentifier = @"getting_there"; break;
            case 5: cellIdentifier = @"notes"; break;
            case 6: cellIdentifier = @"waypoint_guidance"; break;
            case 7: cellIdentifier = @"kml"; break;
            case 8: cellIdentifier = @"directions"; break;
            case 9: cellIdentifier = @"images"; break;
        }
    }
    else {
        switch (indexPath.row) {
            case 0: cellIdentifier = @"map"; break;
            case 1: cellIdentifier = @"overview"; break;
            case 2: cellIdentifier = @"avalanche"; break;
            case 3: cellIdentifier = @"content"; break;
            case 4: cellIdentifier = @"getting_there"; break;
            case 5: cellIdentifier = @"waypoint_guidance"; break;
            case 6: cellIdentifier = @"kml"; break;
            case 7: cellIdentifier = @"directions"; break;
            case 8: cellIdentifier = @"images"; break;
        }
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
    else if ([cellIdentifier isEqualToString:@"notes"]) {
        (cell.labelNotesInformation).text = self.skiRoute.notes;
    }
    else if ([cellIdentifier isEqualToString:@"waypoint_guidance"]) {
        (cell.labelWaypointGuidanceInformation).text = self.skiRoute.gps_guidance;
    }
    else if ([cellIdentifier isEqualToString:@"kml"]) {
        nil;
    }
    else if ([cellIdentifier isEqualToString:@"directions"]) {
        nil;
    }
    else if ([cellIdentifier isEqualToString:@"images"]) {
        // Add KML Image
        NSString __block *kmlImage;
        NSSet *routeImages = (self.skiRoute).ski_route_images;
        //NSLog(@"%@", routeImages);
        [routeImages enumerateObjectsUsingBlock:^(File *file, BOOL *stop) {
            //NSLog(@"%@", file.filename);
            if ((file.kml_image).boolValue == YES) {
                kmlImage = file.avatar;
                *stop = YES;
            }
        }];
        self.kmlImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kmlImage]];
        (self.kmlImage).contentMode = UIViewContentModeScaleAspectFill;
        (self.kmlImage).translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:self.kmlImage];
        NSDictionary *imageViews = @{ @"kmlImage": self.kmlImage };
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[kmlImage]|" options:kNilOptions metrics:nil views:imageViews]];
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[kmlImage]|" options:kNilOptions metrics:nil views:imageViews]];
        [self.kmlImage addConstraint:[NSLayoutConstraint constraintWithItem:self.kmlImage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:240.0f]];
        
        // Add KML Label
        self.kmlLabel = [UILabel new];
        (self.kmlLabel).text = @"View Route Images";
        (self.kmlLabel).textColor = [UIColor whiteColor];
        (self.kmlLabel).font = [UIFont fontWithName:@"Avenir Book" size:16.0f];
        (self.kmlLabel).layer.shadowColor = [UIColor blackColor].CGColor;
        (self.kmlLabel).layer.shadowRadius = 2.0f;
        (self.kmlLabel).layer.shadowOpacity = 1.0f;
        (self.kmlLabel).layer.shadowOffset = CGSizeZero;
        (self.kmlLabel).layer.masksToBounds = NO;
        (self.kmlLabel).translatesAutoresizingMaskIntoConstraints = NO;
        (self.kmlLabel).autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin);
        [cell.contentView addSubview:self.kmlLabel];
        NSDictionary *labelViews = @{ @"kmlLabel":self.kmlLabel };
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[kmlLabel]-8-|" options:kNilOptions metrics:nil views:labelViews]];
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
    
    if (self.notesExist == YES) {
        switch (indexPath.row) {
            case 0: height = 180.0f; break;
            case 1: height = 188.0f; break;
            case 3: height = 350.0f; break;
            case 2: height = 350.0f; break;
            case 4: height = 350.0f; break;
            case 5: height = 350.0f; break;
            case 6: height = 350.0f; break;
            case 7: height = 44.0f; break;
            case 8: height = 44.0f; break;
            case 9: height = 240.0f; break;
            default: break;
        }
    }
    else {
        switch (indexPath.row) {
            case 0: height = 180.0f; break;
            case 1: height = 188.0f; break;
            case 3: height = 350.0f; break;
            case 2: height = 350.0f; break;
            case 4: height = 350.0f; break;
            case 5: height = 350.0f; break;
            case 6: height = 44.0f; break;
            case 7: height = 44.0f; break;
            case 8: height = 240.0f; break;
            default: break;
        }
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
    
    else if ([cell.reuseIdentifier isEqualToString:@"images"]) {
        NSSet *routeImages = (self.skiRoute).ski_route_images;
        self.photos = [NSMutableArray array];
        for (File *file in routeImages) {
            NSString *assetName = [file.avatar stringByDeletingPathExtension];
            MWPhoto *photo = [MWPhoto photoWithImage:[UIImage imageNamed:assetName]];
            //photo.caption = file.caption;
            [self.photos addObject:photo];
        }
        
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        browser.displayActionButton = NO;
        browser.displayNavArrows = YES;
        browser.displaySelectionButtons = NO;
        browser.zoomPhotosToFill = YES;
        browser.alwaysShowControls = NO;
        browser.enableGrid = NO;
        browser.startOnGrid = NO;
        [browser setCurrentPhotoIndex:0];
        
        // Animated image and label
        CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        pulseAnimation.duration = 0.2f;
        pulseAnimation.toValue = @1.1f;
        pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        pulseAnimation.fillMode = kCAFillModeForwards;
        pulseAnimation.removedOnCompletion = NO;
        pulseAnimation.autoreverses = NO;
        [CATransaction setCompletionBlock:^{
            // Push MWPhotoBrowser Controller
            [self.navigationController pushViewController:browser animated:YES];
            // Remove animation 2 sec after pushed controller .... this is hacky
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [(self.kmlImage).layer removeAnimationForKey:pulseAnimation.keyPath];
                [(self.kmlLabel).layer removeAnimationForKey:pulseAnimation.keyPath];
            });
        }];
        [(self.kmlImage).layer addAnimation:pulseAnimation forKey:pulseAnimation.keyPath];
        [(self.kmlLabel).layer addAnimation:pulseAnimation forKey:pulseAnimation.keyPath];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    // Open up appropriate mapping App for directions to parking lot
    else if ([cell.reuseIdentifier isEqualToString:@"directions"]) {
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
    else if ([cell.reuseIdentifier isEqualToString:@"kml"]) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgoogleearth://"]]) {
            NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:self.skiRoute.name_route withExtension:@"kmz"];
            self.docController = [UIDocumentInteractionController interactionControllerWithURL:fileUrl];
            [self.docController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
        }
        else {
            [self showNeedGoogleEarthAlert];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)showNeedGoogleEarthAlert
{
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"Google Earth" message:@"The Google Earth app is required to use this feature." preferredStyle:UIAlertControllerStyleAlert];
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

#pragma mark - SMPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return (self.photos).count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < (self.photos).count) {
        return self.photos[index];
    }
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index
{
    if (index < (self.photos).count) {
        return self.photos[index];
    }
    return nil;
}

@end