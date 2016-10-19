//
//  SMRouteMapViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 5/7/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMRouteMapViewController.h"
#import "CLLocationHelper.h"
#import "SMIAPHelper.h"
#import "Mapbox.h"

#import "SMMapAttributionViewController.h"

SMCoordinateBounds const worldBounds = (SMCoordinateBounds){(CLLocationCoordinate2D){-85, -180}, (CLLocationCoordinate2D){85, 180}};
CLLocationCoordinate2D const bozemanCoords = (CLLocationCoordinate2D){45.682145, -111.046954};

@interface SMRouteMapViewController() <UINavigationBarDelegate, RMMapViewDelegate>

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *mapViewContainer;
@property (strong, nonatomic) RMMBTilesSource *tileSource;
@property (strong, nonatomic) RMMapView *mapView;
@property (strong, nonatomic) UINavigationItem *navItem;
@property (strong, nonatomic) NSSet *gpsObjects;

@property (assign, nonatomic) SMCoordinateBounds areaBounds;
@property (assign, nonatomic) SMCoordinateBounds coordinateBounds;

@end

@implementation SMRouteMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setAttributionButton];
    
    self.navigationBar.delegate = self;
    self.gpsObjects = self.skiRoute.ski_route_gps;
    
    NSArray *mbtilesArray = [self.skiRoute.mbtiles componentsSeparatedByString:@"."];

    // Setting up Navigation Bar
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissViewController)];
    self.navItem = [[UINavigationItem alloc] initWithTitle:self.skiRoute.name_route];
    self.navItem.leftBarButtonItem = backButton;
    [self.navigationBar setItems:@[self.navItem] animated:NO];
    
    // Setting up Mapbox
    [RMConfiguration sharedInstance].accessToken = MAPBOX_ACCESS_TOKEN;
    NSURL *tileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:mbtilesArray.firstObject ofType:mbtilesArray.lastObject]];
    self.tileSource = [[RMMBTilesSource alloc] initWithTileSetURL:tileUrl];
    self.mapView = [[RMMapView alloc] initWithFrame:self.mapViewContainer.bounds andTilesource:self.tileSource];
    self.mapView.delegate = self;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.mapView.adjustTilesForRetinaDisplay = YES;
    self.mapView.showsUserLocation = YES;
    self.mapView.showLogoBug = NO;
    self.mapView.hideAttribution = YES;
    [self.mapViewContainer addSubview:self.mapView];
    self.mapView.layer.opacity = 0;
    
    // Parsing bounds out of route bounds strings
    NSArray *boundsNortheast = [self.skiRoute.bounds_northeast componentsSeparatedByString:@","];
    NSArray *boundsSouthwest = [self.skiRoute.bounds_southwest componentsSeparatedByString:@","];
    NSCharacterSet *whitespaceCharSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    CLLocationCoordinate2D southwest = CLLocationCoordinate2DMake(
        [boundsSouthwest.firstObject stringByTrimmingCharactersInSet:whitespaceCharSet].floatValue,
        [boundsSouthwest.lastObject stringByTrimmingCharactersInSet:whitespaceCharSet].floatValue
    );
    
    CLLocationCoordinate2D northeast = CLLocationCoordinate2DMake(
        [boundsNortheast.firstObject stringByTrimmingCharactersInSet:whitespaceCharSet].floatValue,
        [boundsNortheast.lastObject stringByTrimmingCharactersInSet:whitespaceCharSet].floatValue
    );
    
    self.areaBounds = SMCoordinateBoundsMake(southwest, northeast);
    self.coordinateBounds = [self getMarkerBoundingBox];
    
    [self.mapView zoomWithLatitudeLongitudeBoundsSouthWest:self.areaBounds.southwest northEast:self.areaBounds.northeast animated:NO];
    
    // Setting up marker annotation
    for (Gps *gps in self.gpsObjects) {
        NSString *title = [NSString stringWithFormat:@"Waypoint: %@", gps.waypoint];
        NSString *subtitle = [NSString stringWithFormat:@"Lat: %@, Lon: %@", gps.lat_dms, gps.lon_dms];
        CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(gps.lat.floatValue, gps.lon.floatValue);
        RMAnnotation *annotation = [[RMAnnotation alloc] initWithMapView:self.mapView coordinate:coords andTitle:title];
        annotation.subtitle = subtitle;
        [self.mapView addAnnotation:annotation];
    }
    
    /*
    // NSLogging
    
    NSLog(@"Native tile bounds of '%@':\n\tSouthwest - Lat: %f, Lon: %f,\n\tNortheast - Lat: %f, Lon: %f",
        self.tileSource.shortName,
        self.tileSource.latitudeLongitudeBoundingBox.southWest.latitude,
        self.tileSource.latitudeLongitudeBoundingBox.southWest.longitude,
        self.tileSource.latitudeLongitudeBoundingBox.northEast.latitude,
        self.tileSource.latitudeLongitudeBoundingBox.northEast.longitude
    );
    
    NSLog(@"Native tile zooms: Max zoom: %f, Min zoom: %f",
        self.tileSource.maxZoom,
        self.tileSource.minZoom
    );
    
    NSLog(@"Bounds of ski area %@:\n\tSouthwest - Lat: %f, Lon: %f,\n\tNortheast - Lat: %f, Lon: %f",
        self.skiRoute.name_route,
        self.areaBounds.southwest.latitude,
        self.areaBounds.southwest.longitude,
        self.areaBounds.northeast.latitude,
        self.areaBounds.northeast.longitude
    );
    */
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    LocationServiceStatus status = [CLLocationHelper checkLocationServiceStatus];
    
    switch (status) {
        case LocationServiceDisabled: [self showLocationServicesAlert]; break;
        case LocationServiceEnabled: break;
        default: break;
    }
    
    self.navItem.rightBarButtonItem = [[RMUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    self.navItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:0.120 green:0.550 blue:0.670 alpha:1.000];
    self.mapView.userTrackingMode = RMUserTrackingModeNone;
    
    // Setting zoom around markers ... setting to max zoom of tileset if overzoomed
    [self.mapView zoomWithLatitudeLongitudeBoundsSouthWest:self.coordinateBounds.southwest northEast:self.coordinateBounds.northeast animated:NO];
    float newZoom = self.mapView.zoom - 0.5f;
    self.mapView.zoom = (newZoom < self.tileSource.maxZoom ? newZoom : self.tileSource.maxZoom);
    
    BOOL purchased = [SMIAPHelper checkInAppMemoryPurchasedState];
    
    // If app is either trial version or purchased, don't contain files to area bounds
    if (IS_TRIAL == YES || purchased == YES) {
        [self.mapView setConstraintsSouthWest:self.tileSource.latitudeLongitudeBoundingBox.southWest
                                    northEast:self.tileSource.latitudeLongitudeBoundingBox.northEast];
    } else {
        [self.mapView setConstraintsSouthWest:self.areaBounds.southwest
                                    northEast:self.areaBounds.northeast];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.mapView.layer.opacity = 1.0f;
    }];
}

- (SMCoordinateBounds)getMarkerBoundingBox
{
    float minLat = 900.0;
    float minLon = 900.0;
    float maxLat = -900.0;
    float maxLon = -900.0;
    
    for (Gps *gps in self.gpsObjects) {
        minLat = MIN(minLat, gps.lat.floatValue);
        minLon = MIN(minLon, gps.lon.floatValue);
        maxLat = MAX(maxLat, gps.lat.floatValue);
        maxLon = MAX(maxLon, gps.lon.floatValue);
    }
    
    CLLocationCoordinate2D southwest = CLLocationCoordinate2DMake(minLat, minLon);
    CLLocationCoordinate2D northeast = CLLocationCoordinate2DMake(maxLat, maxLon);
        
    SMCoordinateBounds bounds = SMCoordinateBoundsMake(southwest, northeast);
    
    return bounds;
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)showLocationServicesAlert
{
    NSString *message = [NSString stringWithFormat:@"To re-enable, please go to Settings and turn on Location Service for %@.", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"]];
    
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"Location Service Disabled" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSURL *settingsUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:settingsUrl]) {
            [[UIApplication sharedApplication] openURL:settingsUrl];
        }
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    
    [alertView addAction:settingsAction];
    [alertView addAction:okAction];
    
    [self presentViewController:alertView animated:YES completion:nil];
}

#pragma mark - RMMapViewDelegate

- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    if (annotation.isUserLocationAnnotation) {
        return nil;
    }
    
    RMMarker *marker = [[RMMarker alloc] initWithMapboxMarkerImage:@"skiing" tintColor:[UIColor colorWithRed:0.120 green:0.550 blue:0.670 alpha:1.000]];
    marker.canShowCallout = YES;
    return marker;
}

- (void)mapView:(RMMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"Failed to locaiton user with error: %@", error.localizedDescription);
}

/*
- (void)mapView:(RMMapView *)mapView didUpdateUserLocation:(RMUserLocation *)userLocation
{
    NSLog(@"Lat: %f, Lon: %f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
}
*/

/*
- (void)singleTapOnMap:(RMMapView *)myMapView at:(CGPoint)point
{
    NSLog(@"Tapped Lat: %f, Lon: %f", [myMapView pixelToCoordinate:point].latitude, [myMapView pixelToCoordinate:point].longitude);
    NSLog(@"Zoom Level: %f", myMapView.zoom);
}
*/

#pragma mark - UIBarPositioningDelegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    if ([bar isKindOfClass:[UINavigationBar class]]) {
        return UIBarPositionTopAttached;
    }
    return UIBarPositionAny;
}

#pragma mark - Attribution

- (void)setAttributionButton
{
    UIButton *attributionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [attributionButton setTitle:@"Legend" forState:UIControlStateNormal];
    attributionButton.titleLabel.font = [UIFont boldSkiMontanaFontOfSize:20.0f];
    [attributionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    attributionButton.layer.shadowColor = [UIColor blackColor].CGColor;
    attributionButton.layer.shadowOffset = CGSizeMake(0, 0);
    attributionButton.layer.shadowRadius = 3.0f;
    attributionButton.layer.shadowOpacity = 0.8f;
    attributionButton.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin);
    [attributionButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [attributionButton addTarget:self action:@selector(showAttribution:) forControlEvents:UIControlEventTouchUpInside];
    attributionButton.frame = CGRectMake(
        self.view.bounds.size.width - attributionButton.bounds.size.width - 8,
        self.view.bounds.size.height - attributionButton.bounds.size.height - 8,
        attributionButton.bounds.size.width,
        attributionButton.bounds.size.height
    );
    
    [self.view addSubview:attributionButton];
    
    NSString *bottomFormatString = @"V:[attributionButton]-bottomSpacing-[bottomLayoutGuide]";
    NSString *rightFormatString = @"H:[attributionButton]-rightSpacing-|";
    
    NSDictionary *views = @{
        @"attributionButton": attributionButton,
        @"bottomLayoutGuide": self.bottomLayoutGuide
    };
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:bottomFormatString options:kNilOptions metrics:@{ @"bottomSpacing" : @(8) } views:views]];
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:rightFormatString options:kNilOptions metrics:@{ @"rightSpacing" : @(8) } views:views]];
}

- (void)showAttribution:(id)sender
{
    SMMapAttributionViewController *attributionViewController = [[SMMapAttributionViewController alloc] initWithMapView:self.mapView];
    attributionViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:attributionViewController animated:YES completion:nil];
}

@end
