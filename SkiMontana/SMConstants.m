//
//  SMConstants.m
//  CoreDataTestApp
//
//  Created by Gneiss Software on 12/13/14.
//  Copyright (c) 2014 Gneiss Software. All rights reserved.
//

#import "SMConstants.h"

@implementation SMConstants

+ (void)documentsFolderIfSimulator
{
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"App Documents Dir: \n%@\n\n", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                                  inDomains:NSUserDomainMask] firstObject]);
#endif
}

+ (BOOL)isIOS7OrLater
{
    return [[[UIDevice currentDevice] systemVersion] floatValue] >= 7;
}

+ (BOOL)isIOS8OrLater
{
    return [[[UIDevice currentDevice] systemVersion] floatValue] >= 8;
}

@end
