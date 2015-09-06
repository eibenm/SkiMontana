//
//  SMRouteMapViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 5/7/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMRouteMapViewController.h"
#import "CLLocationHelper.h"
#import "Mapbox.h"

@interface SMRouteMapViewController() <UINavigationBarDelegate, RMMapViewDelegate>

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *mapViewContainer;
@property (strong, nonatomic) RMMapView *mapView;
@property (strong, nonatomic) UINavigationItem *navItem;

@end

@implementation SMRouteMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBar.delegate = self;
    
    // Setting up Back Button on Nav Bar
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissViewController)];
    self.navItem = [UINavigationItem new];
    [self.navItem setLeftBarButtonItem:backButton];
    [self.navigationBar setItems:[NSArray arrayWithObject:self.navItem] animated:NO];
    
    [[RMConfiguration sharedInstance] setAccessToken:MAPBOX_ACCESS_TOKEN];
    RMMapboxSource *tileSource = [[RMMapboxSource alloc] initWithMapID:@"mapbox.streets"];
    self.mapView = [[RMMapView alloc] initWithFrame:self.mapViewContainer.bounds andTilesource:tileSource];
    self.mapView.delegate = self;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.mapView.adjustTilesForRetinaDisplay = YES;
    self.mapView.showsUserLocation = YES;
    self.mapView.zoom = 4;
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake(38.910003,-77.015533);
    [self.mapViewContainer addSubview:self.mapView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
 
    LocationServiceStatus status = [CLLocationHelper checkLocationServiceStatus];
    switch (status) {
        case LocationServiceDisabled:
        {
            [self showLocationServicesAlert];
            [self.mapView setZoom:12.0f atCoordinate:CLLocationCoordinate2DMake(45.682145, -111.046954) animated:YES];
            break;
        }
            
        case LocationServiceEnabled:
        {
#if TARGET_IPHONE_SIMULATOR
            [self.mapView setZoom:12.0f atCoordinate:CLLocationCoordinate2DMake(45.682145, -111.046954) animated:YES];
            break;
#else
            float userLat = self.mapView.userLocation.location.coordinate.latitude;
            float userLon = self.mapView.userLocation.location.coordinate.longitude;
            [self.mapView setZoom:12.0f atCoordinate:CLLocationCoordinate2DMake(userLat, userLon) animated:YES];
            break;
#endif
        }
            
        default: break;
    }
    
    [self.navItem setRightBarButtonItem:[[RMUserTrackingBarButtonItem alloc] initWithMapView:self.mapView]];
    [self.navItem.rightBarButtonItem setTintColor:[UIColor colorWithRed:0.120 green:0.550 blue:0.670 alpha:1.000]];
    [self.mapView setUserTrackingMode:RMUserTrackingModeNone];
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
    [[[UIAlertView alloc] initWithTitle:@"Location Service Disabled"
                                message:@"To re-enable, please go to Settings and turn on Location Service for Ski Montana."
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

#pragma mark - RMMapViewDelegate

- (void)mapView:(RMMapView *)mapView didUpdateUserLocation:(RMUserLocation *)userLocation
{
    //NSLog(@"Lat: %f, Lon: %f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
}

- (void)mapView:(RMMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"Failed to locaiton user with error: %@", error.localizedDescription);
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
