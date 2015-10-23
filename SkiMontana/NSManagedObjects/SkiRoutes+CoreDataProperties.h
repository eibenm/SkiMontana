//
//  SkiRoutes+CoreDataProperties.h
//  SkiMontana
//
//  Created by Matt Eiben on 10/22/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SkiRoutes.h"

NS_ASSUME_NONNULL_BEGIN

@interface SkiRoutes (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *aspects;
@property (nullable, nonatomic, retain) NSString *avalanche_danger;
@property (nullable, nonatomic, retain) NSString *avalanche_info;
@property (nullable, nonatomic, retain) NSString *bounds_northeast;
@property (nullable, nonatomic, retain) NSString *bounds_southwest;
@property (nullable, nonatomic, retain) NSString *directions;
@property (nullable, nonatomic, retain) NSNumber *distance;
@property (nullable, nonatomic, retain) NSNumber *elevation_gain;
@property (nullable, nonatomic, retain) NSString *gps_guidance;
@property (nullable, nonatomic, retain) NSString *kml;
@property (nullable, nonatomic, retain) NSString *mbtiles;
@property (nullable, nonatomic, retain) NSString *name_route;
@property (nullable, nonatomic, retain) NSString *notes;
@property (nullable, nonatomic, retain) NSString *overview;
@property (nullable, nonatomic, retain) NSString *quip;
@property (nullable, nonatomic, retain) NSString *short_desc;
@property (nullable, nonatomic, retain) NSString *skier_traffic;
@property (nullable, nonatomic, retain) NSString *snowfall;
@property (nullable, nonatomic, retain) NSString *vertical;
@property (nullable, nonatomic, retain) SkiAreas *ski_area;
@property (nullable, nonatomic, retain) NSSet<Gps *> *ski_route_gps;
@property (nullable, nonatomic, retain) NSSet<File *> *ski_route_images;
@property (nullable, nonatomic, retain) File *kml_image;

@end

@interface SkiRoutes (CoreDataGeneratedAccessors)

- (void)addSki_route_gpsObject:(Gps *)value;
- (void)removeSki_route_gpsObject:(Gps *)value;
- (void)addSki_route_gps:(NSSet<Gps *> *)values;
- (void)removeSki_route_gps:(NSSet<Gps *> *)values;

- (void)addSki_route_imagesObject:(File *)value;
- (void)removeSki_route_imagesObject:(File *)value;
- (void)addSki_route_images:(NSSet<File *> *)values;
- (void)removeSki_route_images:(NSSet<File *> *)values;

@end

NS_ASSUME_NONNULL_END
