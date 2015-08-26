//
//  UIFont+SkiMontana.h
//  SkiMontana
//
//  Created by Gneiss Software on 2/22/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

@interface NSArray (SkiMontana)

- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block;

@end
