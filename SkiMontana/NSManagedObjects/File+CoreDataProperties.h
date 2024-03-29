//
//  File+CoreDataProperties.h
//  SkiMontana
//
//  Created by Matt Eiben on 11/2/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "File.h"

NS_ASSUME_NONNULL_BEGIN

@interface File (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *avatar;
@property (nullable, nonatomic, retain) NSString *caption;
@property (nullable, nonatomic, retain) NSString *filename;
@property (nullable, nonatomic, retain) NSNumber *kml_image;
@property (nullable, nonatomic, retain) SkiAreas *ski_area;
@property (nullable, nonatomic, retain) SkiRoutes *ski_route;

@end

NS_ASSUME_NONNULL_END
