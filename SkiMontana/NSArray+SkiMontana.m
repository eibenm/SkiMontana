//
//  NSArray+SkiMontana.h
//  SkiMontana
//
//  Created by Gneiss Software on 2/22/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "NSArray+SkiMontana.h"

@implementation NSArray (SkiMontana)

- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject:block(obj, idx)];
    }];
    return result;
}

@end