//
//  SMIAPHelper.h
//  SkiMontana
//
//  Created by Matt Eiben on 10/19/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import "SCPStoreKitManager.h"
#import "SCPStoreKitReceiptValidator.h"

@interface SMIAPHelper : NSObject

+ (BOOL)checkInAppMemoryPurchasedState;

+ (void)setInAppMemoryPurchasedStatePurchased:(BOOL)purchased;

+ (BOOL)subscriptionIsActiveWithReceipt:(SCPStoreKitIAPReceipt *)transaction date:(NSDate *)date;

@end
