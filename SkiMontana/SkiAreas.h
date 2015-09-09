//
//  SkiAreas.h
//  SkiMontana
//
//  Created by Matt Eiben on 9/8/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class File, SkiRoutes;

@interface SkiAreas : NSManagedObject

@property (nonatomic, retain) NSString * bounds_northeast;
@property (nonatomic, retain) NSString * bounds_southwest;
@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSString * conditions;
@property (nonatomic, retain) NSString * name_area;
@property (nonatomic, retain) NSNumber * permissions;
@property (nonatomic, retain) File *ski_area_image;
@property (nonatomic, retain) NSSet *ski_routes;
@end

@interface SkiAreas (CoreDataGeneratedAccessors)

- (void)addSki_routesObject:(SkiRoutes *)value;
- (void)removeSki_routesObject:(SkiRoutes *)value;
- (void)addSki_routes:(NSSet *)values;
- (void)removeSki_routes:(NSSet *)values;

@end
