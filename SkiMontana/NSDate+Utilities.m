//
//  NSDate+Utilities.m
//  SkiMontana
//
//  Created by Matt Eiben on 10/19/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import "NSDate+Utilities.h"

@implementation NSDate (Utilities)

- (BOOL)isEarlierThanDate:(NSDate *)aDate
{
    return ([self compare:aDate] == NSOrderedAscending);
}

- (BOOL)isLaterThanDate:(NSDate *)aDate
{
    return ([self compare:aDate] == NSOrderedDescending);
}

@end
