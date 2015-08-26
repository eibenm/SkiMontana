//
//  File.h
//  SkiMontana
//
//  Created by Matt Eiben on 8/17/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SkiAreas, SkiRoutes;

@interface File : NSManagedObject

@property (nonatomic, retain) NSString * avatar;
@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) SkiAreas *ski_area;
@property (nonatomic, retain) SkiRoutes *ski_route;

@end
