//
//  Gps+CoreDataProperties.h
//  SkiMontana
//
//  Created by Matt Eiben on 10/22/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Gps.h"

NS_ASSUME_NONNULL_BEGIN

@interface Gps (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *lat;
@property (nullable, nonatomic, retain) NSString *lat_dms;
@property (nullable, nonatomic, retain) NSNumber *lon;
@property (nullable, nonatomic, retain) NSString *lon_dms;
@property (nullable, nonatomic, retain) NSString *waypoint;
@property (nullable, nonatomic, retain) SkiRoutes *ski_route;

@end

NS_ASSUME_NONNULL_END
