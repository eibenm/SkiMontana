//
//  Gps+CoreDataProperties.m
//  SkiMontana
//
//  Created by Matt Eiben on 11/2/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Gps+CoreDataProperties.h"

@implementation Gps (CoreDataProperties)

@dynamic lat;
@dynamic lat_dms;
@dynamic lon;
@dynamic lon_dms;
@dynamic waypoint;
@dynamic ski_route;

@end
