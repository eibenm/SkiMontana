//
//  SMUtilities.h
//  SkiMontana
//
//  Created by Matt Eiben on 8/17/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMUtilities : NSObject

+ (SMUtilities *)sharedInstance;

typedef void (^SkiDataCompletionHandler)(NSURLResponse *, NSData *, NSError *);

- (void)downloadSMJson;

@end
