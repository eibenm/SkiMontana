//
//  SMConstants.h
//  SkiMontana
//
//  Created by Gneiss Software on 12/13/14.
//  Copyright (c) 2014 Gneiss Software. All rights reserved.
//


static inline BOOL isIOS8OrLater()
{
    return [[[UIDevice currentDevice] systemVersion] floatValue] >= 8;
}

static inline BOOL isIOS9OrLater()
{
    return [[[UIDevice currentDevice] systemVersion] floatValue] >= 9;
}

static NSString * const SKIAPP_JSON =                    @"skiappdata.json";
static NSString * const MAPBOX_ACCESS_TOKEN =            @"pk.eyJ1IjoiZWliZW5tIiwiYSI6ImNBMU11WjAifQ.AVf0Ym7u2Rq4F9KQJ5kPQw";
static NSString * const NS_USER_DEFUALTS_INITAL_LAUNCH = @"initialAppLaunch";
static NSString * const NS_USER_DEFUALTS_PURCHASED =     @"purchasedState";
static NSString * const ICLOUD_SMONEMONTH_SUB =          @"ski_montana_one_month_subscription";
static NSString * const ICLOUD_SMONEYEAR_SUB =           @"ski_montana_one_month_subscription";
static NSString * const ICLOUD_SMAPP_RECEIPTS =          @"ski_montana_app_receipts";

#pragma mark - General Macros

#define SM_LogBool(BOOL) NSLog(@"%s: %@",#BOOL, BOOL ? @"YES" : @"NO" )

#pragma mark - Conditional Compiles

#if DEV == 1

static NSString * const SKIAPP_JSON_URL =                @"http://eibenm.com/backcountryskiapp/skimontanadata/skiappdata.json";
//static NSString * const SKIAPP_JSON_URL =                @"http://eibenm.com/devbackcountryskiapp/skimontanadata/skiappdata.json";
static NSString * const BUNDLE_IDENTIFIER =              @"com.eibenm.SkiMontanaTest";
static NSString * const kIdentifierSubscription1Month =  @"com.eibenm.SkiMontana.1Month.Dev";
static NSString * const kIdentifierSubscription1Year =   @"com.eibenm.SkiMontana.1Year.Dev";

#else

static NSString * const SKIAPP_JSON_URL =                @"http://eibenm.com/backcountryskiapp/skimontanadata/skiappdata.json";
static NSString * const BUNDLE_IDENTIFIER =              @"com.eibenm.SkiMontana";
static NSString * const kIdentifierSubscription1Month =   @"com.eibenm.SkiMontana.1Month.Pro";
static NSString * const kIdentifierSubscription1Year =    @"com.eibenm.SkiMontana.1Year.Pro";

#undef NSLog
#define NSLog(...)

#endif

#if TRIAL == 1

static BOOL const IS_TRIAL = YES;

#else

static BOOL const IS_TRIAL = NO;

#endif

#pragma mark - SMConstants

@interface SMConstants : NSObject

+ (void)documentsFolderIfSimulator;

@end
