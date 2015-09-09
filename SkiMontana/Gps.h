//
//  Gps.h
//  SkiMontana
//
//  Created by Matt Eiben on 9/8/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SkiRoutes;

@interface Gps : NSManagedObject

@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSString * lat_dms;
@property (nonatomic, retain) NSNumber * lon;
@property (nonatomic, retain) NSString * lon_dms;
@property (nonatomic, retain) NSString * waypoint;
@property (nonatomic, retain) SkiRoutes *ski_route;

@end
