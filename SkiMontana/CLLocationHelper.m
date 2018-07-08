//
//  SMFileManager.h
//  SkiMontana
//
//  Created by Gneiss Software on 5/18/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "CLLocationHelper.h"

@implementation CLLocationHelper

+ (LocationServiceStatus)checkLocationServiceStatus
{
    if (![CLLocationManager locationServicesEnabled]) {
        return LocationServiceDisabled;
    }
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        return LocationServiceDisabled;
    }
    
    return LocationServiceEnabled;
}

@end
