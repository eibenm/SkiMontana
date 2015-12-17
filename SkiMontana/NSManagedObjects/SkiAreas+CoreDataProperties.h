//
//  SkiAreas+CoreDataProperties.h
//  SkiMontana
//
//  Created by Matt Eiben on 11/2/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SkiAreas.h"

NS_ASSUME_NONNULL_BEGIN

@interface SkiAreas (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *bounds_northeast;
@property (nullable, nonatomic, retain) NSString *bounds_southwest;
@property (nullable, nonatomic, retain) NSString *color;
@property (nullable, nonatomic, retain) NSString *conditions;
@property (nullable, nonatomic, retain) NSString *name_area;
@property (nullable, nonatomic, retain) NSNumber *permissions;
@property (nullable, nonatomic, retain) File *ski_area_image;
@property (nullable, nonatomic, retain) NSSet<SkiRoutes *> *ski_routes;

@end

@interface SkiAreas (CoreDataGeneratedAccessors)

- (void)addSki_routesObject:(SkiRoutes *)value;
- (void)removeSki_routesObject:(SkiRoutes *)value;
- (void)addSki_routes:(NSSet<SkiRoutes *> *)values;
- (void)removeSki_routes:(NSSet<SkiRoutes *> *)values;

@end

NS_ASSUME_NONNULL_END
