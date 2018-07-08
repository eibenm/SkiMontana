//
//  SMRouteMapViewController.h
//  SkiMontana
//
//  Created by Matt Eiben on 5/7/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMDataManager.h"
#import <CoreLocation/CLLocation.h>

typedef struct {
    CLLocationCoordinate2D southwest;
    CLLocationCoordinate2D northeast;
} SMCoordinateBounds;

static inline SMCoordinateBounds SMCoordinateBoundsMake(CLLocationCoordinate2D southwest, CLLocationCoordinate2D northeast)
{
    SMCoordinateBounds bounds;
    bounds.southwest = southwest;
    bounds.northeast = northeast;
    return bounds;
}

@interface SMRouteMapViewController : UIViewController

@property (strong, nonatomic) SkiRoutes *skiRoute;

@end
