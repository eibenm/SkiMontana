//
//  SMIAPHelper.m
//  SkiMontana
//
//  Created by Matt Eiben on 10/19/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import "SMIAPHelper.h"

@implementation SMIAPHelper

+ (BOOL)checkInAppMemoryPurchasedState
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:NS_USER_DEFAULTS_PURCHASED];
}

+ (BOOL)subscriptionIsActiveWithReceipt:(SCPStoreKitIAPReceipt *)transaction date:(NSDate *)date
{
    if (transaction.cancellationDate) {
        return NO;
    }
    
    return [transaction.purchaseDate isEarlierThanDate:date] && [date isEarlierThanDate:transaction.subscriptionExpiryDate];
}

@end
