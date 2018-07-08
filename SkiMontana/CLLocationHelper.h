//
//  SMFileManager.h
//  SkiMontana
//
//  Created by Gneiss Software on 5/18/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSInteger, LocationServiceStatus) {
    LocationServiceEnabled,
    LocationServiceDisabled
};

@interface CLLocationHelper : NSObject

+ (LocationServiceStatus)checkLocationServiceStatus;

@end
