//
//  SkiRoutes.h
//  SkiMontana
//
//  Created by Matt Eiben on 8/17/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class File, Gps, SkiAreas;

@interface SkiRoutes : NSManagedObject

@property (nonatomic, retain) NSString * aspects;
@property (nonatomic, retain) NSString * avalanche_danger;
@property (nonatomic, retain) NSString * avalanche_info;
@property (nonatomic, retain) NSString * bounds_northeast;
@property (nonatomic, retain) NSString * bounds_southwest;
@property (nonatomic, retain) NSString * directions;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSNumber * elevation_gain;
@property (nonatomic, retain) NSString * gps_guidance;
@property (nonatomic, retain) NSString * kml;
@property (nonatomic, retain) NSString * name_route;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * overview;
@property (nonatomic, retain) NSString * short_desc;
@property (nonatomic, retain) NSString * skier_traffic;
@property (nonatomic, retain) NSString * snowfall;
@property (nonatomic, retain) NSNumber * vertical;
@property (nonatomic, retain) SkiAreas *ski_area;
@property (nonatomic, retain) NSSet *ski_route_gps;
@property (nonatomic, retain) NSSet *ski_route_images;
@end

@interface SkiRoutes (CoreDataGeneratedAccessors)

- (void)addSki_route_gpsObject:(Gps *)value;
- (void)removeSki_route_gpsObject:(Gps *)value;
- (void)addSki_route_gps:(NSSet *)values;
- (void)removeSki_route_gps:(NSSet *)values;

- (void)addSki_route_imagesObject:(File *)value;
- (void)removeSki_route_imagesObject:(File *)value;
- (void)addSki_route_images:(NSSet *)values;
- (void)removeSki_route_images:(NSSet *)values;

@end
