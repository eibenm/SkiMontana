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

#import "SMMapAttributionViewController.h"

@interface SMOverviewMapViewController () <RMMapViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *mapViewContainer;
@property (strong, nonatomic) RMMBTilesSource *tileSource;
@property (strong, nonatomic) RMMapView *mapView;

@end

@implementation SMOverviewMapViewController 

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setAttributionButton];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(dismissViewController)];
    self.navigationItem.leftBarButtonItem = backButton;
    self.title = @"Overview Map";
    
    // Setting up Mapbox
    [RMConfiguration sharedInstance].accessToken = MAPBOX_ACCESS_TOKEN;
    NSURL *tileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"overviewMap" ofType:@"mbtiles"]];
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
    [self.mapView setZoom:10.5f atCoordinate:CLLocationCoordinate2DMake(45.72, -110.80) animated:NO];
    RMSphericalTrapezium boundingBox = self.tileSource.latitudeLongitudeBoundingBox;
    [self.mapView setConstraintsSouthWest:boundingBox.southWest northEast:boundingBox.northEast];
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
    self.mapView.userTrackingMode = RMUserTrackingModeNone;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.mapView.layer.opacity = 1.0f;
    }];
}

- (void)showLocationServicesAlert
{
    NSString *message = [NSString stringWithFormat:@"To re-enable, please go to Settings and turn on Location Service for %@.", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"]];
    
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"Location Service Disabled" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSURL *settingsUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:settingsUrl]) {
            [[UIApplication sharedApplication] openURL:settingsUrl options:@{} completionHandler:nil];
        }
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    
    [alertView addAction:settingsAction];
    [alertView addAction:okAction];
    
    [self presentViewController:alertView animated:YES completion:nil];
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
        @"bottomLayoutGuide": self.view.safeAreaLayoutGuide.bottomAnchor
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
