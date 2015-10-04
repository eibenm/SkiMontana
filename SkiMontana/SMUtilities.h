//
//  SMUtilities.h
//  SkiMontana
//
//  Created by Matt Eiben on 8/17/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^Success)(BOOL appUpdated, NSString *message);
typedef void(^Failure)(NSError *error);

@interface SMUtilities : NSObject

+ (SMUtilities *)sharedInstance;

- (void)downloadSMJsonWithSuccess:(Success)successBlock error:(Failure)failureBlock;

@end
