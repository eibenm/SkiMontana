//
//  SMConstants.h
//  SkiMontana
//
//  Created by Gneiss Software on 12/13/14.
//  Copyright (c) 2014 Gneiss Software. All rights reserved.
//

static inline BOOL isIOS7OrLater()
{
    return [[[UIDevice currentDevice] systemVersion] floatValue] >= 7;
}

static inline BOOL isIOS8OrLater()
{
    return [[[UIDevice currentDevice] systemVersion] floatValue] >= 8;
}

static inline BOOL isRetinaDevice()
{
    return [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] >= 2;
}

static NSString * const SKIAPP_JSON =                    @"skiappdata.json";
static NSString * const MAPBOX_ACCESS_TOKEN =            @"pk.eyJ1IjoiZWliZW5tIiwiYSI6ImNBMU11WjAifQ.AVf0Ym7u2Rq4F9KQJ5kPQw";
static NSString * const NS_USER_DEFUALTS_INITAL_LAUNCH = @"initialAppLaunch";

#pragma mark - General Macros

#define SM_LogBool(BOOL) NSLog(@"%s: %@",#BOOL, BOOL ? @"YES" : @"NO" )

#pragma mark - Conditional Compiles

#if DEV == 1

static NSString * const SKIAPP_JSON_URL =                @"http://eibenm.com/devskimontana/skiappdata.json";
static NSString *kIdentifierSubscription1Month =         @"com.eibenm.SkiMontana.1Month.Dev";
static NSString *kIdentifierSubscription1Year =          @"com.eibenm.SkiMontana.1Year.Dev";

#else

static NSString * const SKIAPP_JSON_URL =                @"http://eibenm.com/skimontana/skiappdata.json";
static NSString *kIdentifierSubscription1Month =         @"com.eibenm.SkiMontana.1Month.Pro";
static NSString *kIdentifierSubscription1Year =          @"com.eibenm.SkiMontana.1Year.Pro";

#undef NSLog
#define NSLog(...)

#endif

#pragma mark - SMConstants

@interface SMConstants : NSObject

+ (void)documentsFolderIfSimulator;

@end
