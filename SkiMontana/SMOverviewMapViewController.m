//
//  SMOverviewMapViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 10/28/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import "SMOverviewMapViewController.h"
#import "CLLocationHelper.h"
#import "Mapbox.h"

@interface SMOverviewMapViewController () <RMMapViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *mapViewContainer;
@property (strong, nonatomic) RMMBTilesSource *tileSource;
@property (strong, nonatomic) RMMapView *mapView;

@end

@implementation SMOverviewMapViewController 

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(dismissViewController)];
    (self.navigationItem).leftBarButtonItem = backButton;
    self.title = @"Overview Map";
    
    // Setting up Mapbox
    [RMConfiguration sharedInstance].accessToken = MAPBOX_ACCESS_TOKEN;
    NSURL *tileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"overviewMap" ofType:@"mbtiles"]];
    self.tileSource = [[RMMBTilesSource alloc] initWithTileSetURL:tileUrl];
    self.mapView = [[RMMapView alloc] initWithFrame:self.mapViewContainer.bounds andTilesource:self.tileSource];
    (self.mapView).delegate = self;
    (self.mapView).autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    (self.mapView).adjustTilesForRetinaDisplay = YES;
    (self.mapView).showsUserLocation = YES;
    (self.mapView).showLogoBug = NO;
    (self.mapView).hideAttribution = YES;
    [self.mapViewContainer addSubview:self.mapView];
    (self.mapView.layer).opacity = 0;
    [self.mapView setZoom:18.0f atCoordinate:CLLocationCoordinate2DMake(45.75, -111.0) animated:NO];
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    
    self.navigationItem.rightBarButtonItem = [[RMUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:0.120 green:0.550 blue:0.670 alpha:1.000];
    (self.mapView).userTrackingMode = RMUserTrackingModeNone;
    
    [UIView animateWithDuration:0.25 animations:^{
        (self.mapView.layer).opacity = 1.0f;
    }];
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

@end
