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

#define markerTint [UIColor colorWithRed:0.120 green:0.550 blue:0.670 alpha:1.000]

@interface SMRouteMapViewController() <UINavigationBarDelegate, RMMapViewDelegate>

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *mapViewContainer;
@property (strong, nonatomic) RMMapView *mapView;
@property (strong, nonatomic) UINavigationItem *navItem;
@property (strong, nonatomic) NSSet *gpsObjects;

@end

@implementation SMRouteMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBar.delegate = self;
    self.gpsObjects = self.skiRoute.ski_route_gps;
    
    // Setting up Navigation Bar
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissViewController)];
    self.navItem = [[UINavigationItem alloc] initWithTitle:self.skiRoute.name_route];
    [self.navItem setLeftBarButtonItem:backButton];
    [self.navigationBar setItems:[NSArray arrayWithObject:self.navItem] animated:NO];
    
    // Setting up Mapbox
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
    
    // Setting up marker annotation
    for (Gps *gps in self.gpsObjects) {
        CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(gps.lat.floatValue, gps.lon.floatValue);
        RMAnnotation *annotation = [[RMAnnotation alloc] initWithMapView:self.mapView coordinate:coords andTitle:@"Coordiantes"];
        [annotation setSubtitle:[NSString stringWithFormat:@"Lat: %@, Lon: %@", gps.lat_dms, gps.lon_dms]];
        [self.mapView addAnnotation:annotation];
    }
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
            // Center on Bozeman
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
    
    SMCoordinateBounds bounds = [self getMarkerBoundingBox];
    
    [self.mapView zoomWithLatitudeLongitudeBoundsSouthWest:bounds.southwest northEast:bounds.northeast animated:YES];
    [self.mapView setZoom:self.mapView.zoom - 1.0f];
    
    [self.navItem setRightBarButtonItem:[[RMUserTrackingBarButtonItem alloc] initWithMapView:self.mapView]];
    [self.navItem.rightBarButtonItem setTintColor:[UIColor colorWithRed:0.120 green:0.550 blue:0.670 alpha:1.000]];
    [self.mapView setUserTrackingMode:RMUserTrackingModeNone];
}

- (SMCoordinateBounds)getMarkerBoundingBox
{
    float minLat = 900.0;
    float minLon = 900.0;
    float maxLat = -900.0;
    float maxLon = -900.0;
    
    for (Gps *gps in self.gpsObjects)
    {
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
    [[[UIAlertView alloc] initWithTitle:@"Location Service Disabled"
                                message:@"To re-enable, please go to Settings and turn on Location Service for Ski Montana."
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

#pragma mark - RMMapViewDelegate

- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    if (annotation.isUserLocationAnnotation) {
        return nil;
    }
    
    RMMarker *marker = [[RMMarker alloc] initWithMapboxMarkerImage:@"skiing" tintColor:markerTint];
    marker.canShowCallout = YES;
    return marker;
}

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
