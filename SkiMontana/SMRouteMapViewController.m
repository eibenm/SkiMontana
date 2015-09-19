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

SMCoordinateBounds const worldBounds = (SMCoordinateBounds){(CLLocationCoordinate2D){-85, -180}, (CLLocationCoordinate2D){85, 180}};
CLLocationCoordinate2D const bozemanCoords = (CLLocationCoordinate2D){45.682145, -111.046954};

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
    
    //+ (NSString *)pathForBundleResourceNamed:(NSString *)name ofType:(NSString *)extension;
    
    NSURL *tileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"bridgerRange" ofType:@"mbtiles"]];
    RMMBTilesSource *tileSource = [[RMMBTilesSource alloc] initWithTileSetURL:tileUrl];
    //RMMapboxSource *tileSource = [[RMMapboxSource alloc] initWithMapID:@"mapbox.streets"];
    self.mapView = [[RMMapView alloc] initWithFrame:self.mapViewContainer.bounds andTilesource:tileSource];
    [self.mapView setDelegate:self];
    [self.mapView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [self.mapView setAdjustTilesForRetinaDisplay:YES];
    [self.mapView setShowsUserLocation:YES];
    [self.mapView setZoom:4];
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(38.910003,-77.015533)];
    [self.mapView setHideAttribution:YES];
    [self.mapViewContainer addSubview:self.mapView];
        
    NSLog(@"Native bounds of '%@' tile layer:", tileSource.shortName);
    NSLog(@"Southwest - Lat: %f, Lon: %f", tileSource.latitudeLongitudeBoundingBox.southWest.latitude, tileSource.latitudeLongitudeBoundingBox.southWest.longitude);
    NSLog(@"Northeast - Lat: %f, Lon: %f", tileSource.latitudeLongitudeBoundingBox.northEast.latitude, tileSource.latitudeLongitudeBoundingBox.northEast.longitude);
    NSLog(@"Max zoom: %f, Min zoom: %f", tileSource.maxZoom, tileSource.minZoom);
    
    // This temporarily unlocks the tile bounds constraints.
    [self.mapView setConstraintsSouthWest:worldBounds.southwest
                                northEast:worldBounds.northeast];
    
    // Setting up marker annotation
    for (Gps *gps in self.gpsObjects) {
        NSString *title = [NSString stringWithFormat:@"Waypoint: %@", gps.waypoint];
        NSString *subtitle = [NSString stringWithFormat:@"Lat: %@, Lon: %@", gps.lat_dms, gps.lon_dms];
        CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(gps.lat.floatValue, gps.lon.floatValue);
        RMAnnotation *annotation = [[RMAnnotation alloc] initWithMapView:self.mapView coordinate:coords andTitle:title];
        [annotation setSubtitle:subtitle];
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
            [self.mapView setZoom:12.0f atCoordinate:bozemanCoords animated:YES];
            break;
        }
            
        case LocationServiceEnabled:
        {
#if TARGET_IPHONE_SIMULATOR
            // Center on Bozeman
            [self.mapView setZoom:12.0f atCoordinate:bozemanCoords animated:YES];
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
    
    RMMarker *marker = [[RMMarker alloc] initWithMapboxMarkerImage:@"skiing" tintColor:[UIColor colorWithRed:0.120 green:0.550 blue:0.670 alpha:1.000]];
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
