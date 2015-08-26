//
//  SMConstants.h
//  SkiMontana
//
//  Created by Gneiss Software on 12/13/14.
//  Copyright (c) 2014 Gneiss Software. All rights reserved.
//

#define SKIAPP_JSON                      @"skiappdata.json"
#define SKIAPP_JSON_URL                  @"http://eibenm.com/downloads/skiappdata.json"
#define MAPBOX_ACCESS_TOKEN              @"pk.eyJ1IjoiZWliZW5tIiwiYSI6ImNBMU11WjAifQ.AVf0Ym7u2Rq4F9KQJ5kPQw"
#define NS_USER_DEFUALTS_INITAL_LAUNCH   @"initialAppLaunch"

#define LogBool(BOOL) NSLog(@"%s: %@",#BOOL, BOOL ? @"YES" : @"NO" )

#pragma mark - Conditional Compiles

#if DEV == 1

#define HOST_NAME           @"dev.website.com"

#else

#define HOST_NAME           @"pro.webisite.com"
#undef NSLog
#define NSLog(...)

#endif

#pragma mark - SMConstants

@interface SMConstants : NSObject

+ (void)documentsFolderIfSimulator;

+ (BOOL)isIOS7OrLater;
+ (BOOL)isIOS8OrLater;

@end
