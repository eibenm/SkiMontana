//
//  SMUtilities.m
//  SkiMontana
//
//  Created by Matt Eiben on 8/17/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMUtilities.h"
#import "SMDataManager.h"
#import "SMReachabilityManager.h"

typedef void (^SkiDataCompletionHandler)(NSData *, NSURLResponse *, NSError *);

@interface SMUtilities()

@property (nonatomic, copy) SMSuccess successBlock;
@property (nonatomic, copy) SMFailure failureBlock;

@end

@implementation SMUtilities
{
    NSFileManager *_fileManager;
    NSUserDefaults *_defaults;
}

#pragma mark - Singleton

+ (SMUtilities *)sharedInstance
{
    static SMUtilities *sharedInstance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _fileManager = [NSFileManager defaultManager];
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

#pragma mark - Public Utility Methods

- (void)downloadSMJsonWithSuccess:(SMSuccess)successBlock error:(SMFailure)failureBlock
{
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
    
    SkiDataCompletionHandler completionHandler = ^( NSData *data, NSURLResponse *response, NSError *connectionError) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    
        if (connectionError != nil) {
            self.failureBlock(connectionError);
            return;
        }
        
        if (data != nil) {
            NSError *error;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSDictionary *internalJson = [self skiAppCurrentJson];
            
            typedef void (^SuccessMessage)(BOOL appUpdate, NSString *message);
            
            SuccessMessage successMessage = ^(BOOL appUpdated, NSString *message) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.successBlock(appUpdated, message);
                });
            };
            
            if (parsedObject != nil) {
                NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
                numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
                
                float internalVersion = [numberFormatter numberFromString:internalJson[@"version"]].floatValue;
                float externalVersion = [numberFormatter numberFromString:parsedObject[@"version"]].floatValue;
                
                if (externalVersion > internalVersion) {
                    if ([[SMDataManager sharedInstance] clearPersistentStores]) {
                        [self copyJsonToDataStore:parsedObject];
                        if ([self createCopyOfSkiJsonFromData:parsedObject]) {
                            successMessage(YES, @"Updated Local Data from server");
                            return;
                        } else {
                            successMessage(NO, @"Problem writing Local json file from server");
                            return;
                        }
                    } else {
                        successMessage(NO, @"Problem clear persistent stores");
                        return;
                    }
                }
                successMessage(NO, @"Version is the same, no changes needed");
            } else {
                successMessage(NO, @"JSON object recieved from server could not be parsed");
            }
        }
    };
    
    // Initial Launch - Get Data from bundle
    // Initial Launch - Set initial system memory values
    
    if ([_defaults boolForKey:NS_USER_DEFUALTS_IS_INITAL_LAUNCH] == YES) {
        [[SMDataManager sharedInstance] clearPersistentStores];
        [self createCopyOfSkiJsonFromBundle];
        [self copyJsonToDataStore:[self skiAppCurrentJson]];
        [self setNSUserDefaultValueWithBool:NO andKey:NS_USER_DEFUALTS_IS_INITAL_LAUNCH];
        [_defaults synchronize];
        self.successBlock(NO, @"First app launch, no updated needed");
    }
    
    // Not initial launch, get data from cloud
    
    else {
        [[SMReachabilityManager sharedManager] checkNetworkStatusWithCompletionHandler:^(BOOL success, CurrentNetworkStatus status) {
            if (status == NetworkStatusEnabled) {
                NSLog(@"Network Enabled");
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:SKIAPP_JSON_URL]
                                                         cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                     timeoutInterval:10.0];
                
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:completionHandler] resume];
            }
            if (status == NetworkStatusDisabled) {
                NSLog(@"Network Disabled");
                self.failureBlock([NSError errorWithDomain:@"com.eibenm.SkiMontana.NoResponse" code:404 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Network is disabled", @"") }]);
            }
        }];
    }
}

- (void)initializeAppOnLaunch
{
    // Initial Launch - Get Data from bundle
    // Initial Launch - Set initial system memory values
    
    if ([_defaults boolForKey:NS_USER_DEFUALTS_IS_INITAL_LAUNCH] == YES) {
        [[SMDataManager sharedInstance] clearPersistentStores];
        [self createCopyOfSkiJsonFromBundle];
        [self copyJsonToDataStore:[self skiAppCurrentJson]];
        [self setNSUserDefaultValueWithBool:NO andKey:NS_USER_DEFUALTS_IS_INITAL_LAUNCH];
        [_defaults synchronize];
    }
}

- (void)setAppLockedStateIsUnlocked:(BOOL)unlocked
{
    // Set all areas to locked/unlocked
    // Ignore "Free Routes" is all permission changes
    
    NSManagedObjectContext *context = [SMDataManager sharedInstance].managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:SM_SkiAreas];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name_area != %@", @"Free Routes"];
    fetchRequest.predicate = predicate;
    NSError *error;
    NSArray *skiAreasArray = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error.localizedDescription);
        return;
    }
    
    for (SkiAreas *skiArea in skiAreasArray) {
        skiArea.permissions = @(unlocked);
    }
    
    NSError *saveError;
    if (![context save:&saveError]) {
        NSLog(@"Whoops, couldn't save: %@", saveError.localizedDescription);
        return;
    }
}

- (void)initUserDefaults
{
    if ([_defaults objectForKey:NS_USER_DEFUALTS_IS_INITAL_LAUNCH] == nil) {
        [self setNSUserDefaultValueWithBool:YES andKey:NS_USER_DEFUALTS_IS_INITAL_LAUNCH];
    }
    
    if ([_defaults objectForKey:NS_USER_DEFAULTS_PURCHASED] == nil) {
        [self setNSUserDefaultValueWithBool:NO andKey:NS_USER_DEFAULTS_PURCHASED];
    }
    
    if ([_defaults objectForKey:NS_USER_DEFAULTS_IS_TRIAL] == nil) {
        [self setNSUserDefaultValueWithBool:NO andKey:NS_USER_DEFAULTS_IS_TRIAL];
    }
}

- (void)setNSUserDefaultValueWithBool:(BOOL)value andKey:(NSString *)key
{
    [_defaults setBool:value forKey:key];
    [_defaults synchronize];
}

- (void)printDocumentsFolderIfSimulator
{
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"App Documents Dir: \n%@\n\n", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                                  inDomains:NSUserDomainMask] firstObject]);
#endif
}

- (void)checkForAppStateChange
{
    // Don't execute this code, if this is the first app launch
    if ([_defaults boolForKey:NS_USER_DEFUALTS_IS_INITAL_LAUNCH] == YES) {
        return;
    }
    
    // Checking database unlocked state ...
    
    NSManagedObjectContext *context = [SMDataManager sharedInstance].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = [NSEntityDescription entityForName:SM_SkiAreas inManagedObjectContext:context];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name_area != %@", @"Free Routes"];
    fetchRequest.fetchLimit = 1;
    fetchRequest.sortDescriptors = @[
         [[NSSortDescriptor alloc] initWithKey:@"name_area" ascending:NO]
     ];
    
    NSError *error = nil;
    NSArray<SkiAreas *> *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        return;
    }
    
    if (results.count != 1) {
        return;
    }
    
    BOOL isLocked = results.firstObject.permissions.boolValue == YES ? NO : YES;
    BOOL isPurchased = [SMIAPHelper checkInAppMemoryPurchasedState];
    
    // is database currently locked?
    // what is the trial status currently ?
    
    if (IS_TRIAL == NO) {
        if (isLocked == YES && isPurchased == YES) {
            // app is purchased, but still locked ... unlock app !
            [self setAppLockedStateIsUnlocked:YES];
        } else if (isLocked == YES && isPurchased == NO) {
            // do nothing ... not currently purchased
        } else if (isLocked == NO && isPurchased == YES) {
            // do nothing ... already purchased
        } else if (isLocked == NO && isPurchased == NO) {
            // trial may have changed ... lock the app!
            [self setAppLockedStateIsUnlocked:NO];
        }
    }
    
    if (IS_TRIAL == YES) {
        if (isLocked == YES && isPurchased == YES) {
            // app is purchased, but still locked ... unlock app !
            [self setAppLockedStateIsUnlocked:YES];
        } else if (isLocked == YES && isPurchased == NO) {
            // trial may have changed ... unlock the app!
            [self setAppLockedStateIsUnlocked:YES];
        } else if (isLocked == NO && isPurchased == YES) {
            // do nothing ... app is already purchased
        } else if (isLocked == NO && isPurchased == NO) {
            // do nothing ... app is in trial mode
        }
    }
}

#pragma mark - Private Utility Methods

- (NSString *)applicationDocumentsDirectory
{
    //return [[_fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
}

- (NSDictionary *)skiAppCurrentJson
{
    NSURL *skidataJson = [NSURL fileURLWithPathComponents:@[[self applicationDocumentsDirectory], SKIAPP_JSON]];
    NSData *data = [NSData dataWithContentsOfURL:skidataJson];
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    return parsedObject;
}

- (BOOL)createCopyOfSkiJsonFromBundle
{
    NSError *error;
    
    NSURL *skidataJson = [NSURL fileURLWithPathComponents:@[[self applicationDocumentsDirectory], SKIAPP_JSON]];
    
    if ([_fileManager fileExistsAtPath:skidataJson.path]) {
        [_fileManager removeItemAtPath:skidataJson.path
                                 error:&error];
    }
    
    NSString *defaultDBPath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:SKIAPP_JSON];
    BOOL success = [_fileManager copyItemAtPath:defaultDBPath
                                         toPath:skidataJson.path
                                          error:&error];
    
    [self addSkipBackupAttributeToItemAtURL:skidataJson];
    
    if (success) {
        return YES;
    }
    
    return NO;
}

- (BOOL)createCopyOfSkiJsonFromData:(NSDictionary *)parsedObject
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parsedObject options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSURL *skidataJson = [NSURL fileURLWithPathComponents:@[[self applicationDocumentsDirectory], SKIAPP_JSON]];
    
    if ([_fileManager fileExistsAtPath:skidataJson.path]) {
        [_fileManager removeItemAtPath:skidataJson.path error:nil];
    }
    
    BOOL success = [jsonString writeToFile:skidataJson.path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    [self addSkipBackupAttributeToItemAtURL:skidataJson];
    
    if (success) {
        return YES;
    }
    
    return NO;
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue:@YES
                                  forKey:NSURLIsExcludedFromBackupKey
                                   error:&error];
    if(!success) {
        NSLog(@"Error excluding %@ from iCloud backup. Error: %@", URL.lastPathComponent, error.localizedDescription);
    }
    
    return success;
}

- (void)copyJsonToDataStore:(NSDictionary *)parsedObject
{
    NSManagedObjectContext *context = [SMDataManager sharedInstance].managedObjectContext;
    
    NSArray *skiAreas = parsedObject[@"skiAreas"];
    NSArray *glossary = parsedObject[@"glossary"];
    
    BOOL purchased = [SMIAPHelper checkInAppMemoryPurchasedState];
    
    for (NSDictionary *skiAreaJson in skiAreas) {
        SkiAreas *skiArea = [NSEntityDescription insertNewObjectForEntityForName:SM_SkiAreas inManagedObjectContext:context];
        skiArea.bounds_northeast = skiAreaJson[@"bounds_northeast"];
        skiArea.bounds_southwest = skiAreaJson[@"bounds_southwest"];
        skiArea.color = skiAreaJson[@"color"];
        skiArea.conditions = skiAreaJson[@"conditions"];
        skiArea.name_area = skiAreaJson[@"name_area"];
        
        if ([skiArea.name_area isEqualToString:@"Free Routes"]) {
            skiArea.permissions = @YES;
        } else {
            skiArea.permissions = (IS_TRIAL || purchased ? @YES : skiAreaJson[@"permissions"]);
        }
        
        NSDictionary *skiAreaImage = skiAreaJson[@"skiarea_image"];
        
        if (skiAreaImage != (NSDictionary *)[NSNull null]) {
            File *fileArea = [NSEntityDescription insertNewObjectForEntityForName:SM_File inManagedObjectContext:context];
            fileArea.filename = skiAreaImage[@"filename"];
            fileArea.avatar = skiAreaImage[@"avatar"];
            fileArea.ski_area = skiArea;
            skiArea.ski_area_image = fileArea;
        }
        
        NSMutableSet *skiRouteSet = [NSMutableSet new];
        
        NSArray *skiRoutes = skiAreaJson[@"skiarea_routes"];
        
        for (NSDictionary *skiRouteJson in skiRoutes) {
            SkiRoutes *skiRoute = [NSEntityDescription insertNewObjectForEntityForName:SM_SkiRoutes inManagedObjectContext:context];
            skiRoute.aspects = skiRouteJson[@"aspects"];
            skiRoute.avalanche_danger = skiRouteJson[@"avalanche_danger"];
            skiRoute.avalanche_info = skiRouteJson[@"avalanche_info"];
            skiRoute.bounds_northeast = skiRouteJson[@"bounds_northeast"];
            skiRoute.bounds_southwest = skiRouteJson[@"bounds_southwest"];
            skiRoute.directions = skiRouteJson[@"directions"];
            skiRoute.distance = skiRouteJson[@"distance"];
            skiRoute.elevation_gain = skiRouteJson[@"elevation_gain"];
            skiRoute.gps_guidance = skiRouteJson[@"gps_guidance"];
            skiRoute.kml = skiRouteJson[@"kml"];
            skiRoute.name_route = skiRouteJson[@"name_route"];
            skiRoute.notes = skiRouteJson[@"notes"];
            skiRoute.overview = skiRouteJson[@"overview"];
            skiRoute.quip = skiRouteJson[@"quip"];
            skiRoute.short_desc = skiRouteJson[@"short_desc"];
            skiRoute.skier_traffic = skiRouteJson[@"skier_traffic"];
            skiRoute.snowfall = skiRouteJson[@"snowfall"];
            skiRoute.vertical = skiRouteJson[@"vertical"];
            skiRoute.mbtiles = skiRouteJson[@"mbtiles"];
            skiRoute.ski_area = skiArea;
            
            [skiRouteSet addObject:skiRoute];
            
            NSMutableSet *skiRouteImageSet = [NSMutableSet new];
            NSMutableSet *skiRouteGpsSet = [NSMutableSet new];
            
            NSArray *skiRouteImages = skiRouteJson[@"skiroute_images"];
            NSArray *skiRouteGps = skiRouteJson[@"skiroute_gps"];
            
            for (NSDictionary *skiRouteImageJson in skiRouteImages) {
                File *fileRoute = [NSEntityDescription insertNewObjectForEntityForName:SM_File inManagedObjectContext:context];
                fileRoute.filename = skiRouteImageJson[@"filename"];
                fileRoute.avatar = skiRouteImageJson[@"avatar"];
                fileRoute.caption = skiRouteImageJson[@"caption"];
                fileRoute.kml_image = skiRouteImageJson[@"kml_image"];
                fileRoute.ski_route = skiRoute;
                [skiRouteImageSet addObject:fileRoute];
            }
            
            for (NSDictionary *skiRouteGpsJson in skiRouteGps) {
                Gps *gps = [NSEntityDescription insertNewObjectForEntityForName:SM_Gps inManagedObjectContext:context];
                gps.waypoint = skiRouteGpsJson[@"waypoint"];
                gps.lat = skiRouteGpsJson[@"lat"];
                gps.lon = skiRouteGpsJson[@"lon"];
                gps.lat_dms = skiRouteGpsJson[@"lat_dms"];
                gps.lon_dms = skiRouteGpsJson[@"lon_dms"];
                gps.ski_route = skiRoute;
                [skiRouteGpsSet addObject:gps];
            }
            
            skiRoute.ski_route_images = skiRouteImageSet;
            skiRoute.ski_route_gps = skiRouteGpsSet;
        }
        
        skiArea.ski_routes = (NSSet *)skiRouteSet;
    }
    
    for (NSDictionary *glossaryJson in glossary) {
        Glossary *glossary = [NSEntityDescription insertNewObjectForEntityForName:SM_Glossary inManagedObjectContext:context];
        glossary.term = glossaryJson[@"term"];
        glossary.desc = glossaryJson[@"description"];
    }
    
    NSError *saveError;
    if (![context save:&saveError]) {
        NSLog(@"Whoops, couldn't save: %@", saveError.localizedDescription);
    }
}

@end
