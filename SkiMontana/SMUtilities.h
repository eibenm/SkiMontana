//
//  SMUtilities.h
//  SkiMontana
//
//  Created by Matt Eiben on 8/17/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMIAPHelper.h"

typedef void(^SMSuccess)(BOOL appUpdated, NSString *message);
typedef void(^SMFailure)(NSError *error);

@interface SMUtilities : NSObject

+ (SMUtilities *)sharedInstance;

- (void)downloadSMJsonWithSuccess:(SMSuccess)successBlock error:(SMFailure)failureBlock;

- (void)initializeAppOnLaunch;

- (void)setAppLockedStateIsUnlocked:(BOOL)unlocked;

- (void)initUserDefaults;

- (void)setNSUserDefaultValueWithBool:(BOOL)value andKey:(NSString *)key;

- (void)printDocumentsFolderIfSimulator;

- (void)checkForAppStateChange;

@end
