//
//  SMReachabilityManager.m
//  SkiMontana
//
//  Created by Matt Eiben on 8/17/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMReachabilityManager.h"

@implementation SMReachabilityManager
{
    Reachability *hostReachability;
    NetworkStatus netStatus;
    NetworkStatusCompletionHandler _completionHandler;
}

+ (SMReachabilityManager *)sharedManager
{
    static SMReachabilityManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (void)checkNetworkStatusWithCompletionHandler:(NetworkStatusCompletionHandler)completionHandler
{
    _completionHandler = [completionHandler copy];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    hostReachability = [Reachability reachabilityWithHostName: @"www.google.com"];
    [hostReachability startNotifier];
}

- (void)updateWithReachability:(Reachability *)reachability
{
    netStatus = [reachability currentReachabilityStatus];
    
    switch (netStatus) {
        case NotReachable:     _completionHandler(YES, NetworkStatusDisabled); break;
        case ReachableViaWiFi: _completionHandler(YES, NetworkStatusEnabled); break;
        case ReachableViaWWAN: _completionHandler(YES, NetworkStatusEnabled); break;
    }
    
    [self removeReachabilityObserver];
}

- (void) reachabilityChanged: (NSNotification* )note
{
    Reachability* curReach = note.object;
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateWithReachability:curReach];
}

- (void)removeReachabilityObserver
{
    _completionHandler = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

@end
