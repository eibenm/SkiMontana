//
//  SMReachabilityManager.h
//  SkiMontana
//
//  Created by Matt Eiben on 8/17/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "Reachability.h"

typedef NS_ENUM(NSInteger, CurrentNetworkStatus) {
    NetworkStatusEnabled,
    NetworkStatusDisabled
};

@interface SMReachabilityManager : NSObject

+ (SMReachabilityManager *)sharedManager;

typedef void (^NetworkStatusCompletionHandler)(BOOL success, CurrentNetworkStatus status);

- (void)checkNetworkStatusWithCompletionHandler:(NetworkStatusCompletionHandler)completionHandler;

@end
