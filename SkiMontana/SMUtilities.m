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

typedef void (^SkiDataCompletionHandler)(NSURLResponse *, NSData *, NSError *);

@interface SMUtilities()

@property (nonatomic, copy) Success successBlock;
@property (nonatomic, copy) Failure failureBlock;

@end

@implementation SMUtilities
{
    NSFileManager *_fileManager;
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
    }
    return self;
}

#pragma mark - Public Utility Methods

- (void)downloadSMJsonWithSuccess:(Success)successBlock error:(Failure)failureBlock
{
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
    
    SkiDataCompletionHandler completionHandler = ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
        if (connectionError != nil) {
            self.failureBlock(connectionError);
            return;
        }
        
        if (data != nil) {
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSDictionary *internalJson = [self skiAppCurrentJson];
            
            //NSLog(@"Recieved json from cloud");
            
            NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
            [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            
            float internalVersion = [numberFormatter numberFromString:internalJson[@"version"]].floatValue;
            float externalVersion = [numberFormatter numberFromString:parsedObject[@"version"]].floatValue;
            
            if (externalVersion > internalVersion) {
                //NSLog(@"Cloud json is different, refreshing local data!");
                if ([[SMDataManager sharedInstance] clearPersistentStores]) {
                    //NSLog(@"Stores cleared!");
                    [self copyJsonToDataStore:parsedObject];
                    if ([self createCopyOfSkiJsonFromData:parsedObject]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.successBlock(YES, @"Updated Local Data from server");
                        });
                        return;
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.successBlock(NO, @"Problem writing Local json file from server");
                        });
                        return;
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.successBlock(NO, @"Problem clear persistent stores");
                    });
                    return;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.successBlock(NO, @"Version is the same, no changes needed");
            });
        }
    };
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Initial Launch - Get Data from bundle
    
    if (![defaults boolForKey:NS_USER_DEFUALTS_INITAL_LAUNCH]) {
        if ([self createCopyOfSkiJsonFromBundle]) {
            [self copyJsonToDataStore:[self skiAppCurrentJson]];
            //NSLog(@"SkidataJSON Successfully copied from bundle to iPhone");
            //NSLog(@"Created Local Data from Bundled JSON");
        }
        [defaults setBool:YES forKey:NS_USER_DEFUALTS_INITAL_LAUNCH];
        [defaults synchronize];
        self.successBlock(NO, @"First app launch, no updated needed");
    }
    else { // Get data from cloud
        [[SMReachabilityManager sharedManager] checkNetworkStatusWithCompletionHandler:^(BOOL success, CurrentNetworkStatus status) {
            if (status == NetworkStatusEnabled) {
                NSLog(@"Network Enabled");
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:SKIAPP_JSON_URL]
                                                         cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                     timeoutInterval:10.0];
                
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                
                [NSURLConnection sendAsynchronousRequest:request
                                                   queue:[[NSOperationQueue alloc] init]
                                       completionHandler:completionHandler];
            }
            if (status == NetworkStatusDisabled) {
                NSLog(@"Network Disabled");
                self.failureBlock([NSError errorWithDomain:@"ccom.eibenm.SkiMontana.NoResponse" code:404 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Network is disabled", @"") }]);
            }
        }];
    }
}

#pragma mark - Private Utility Methods

- (NSString *)applicationDocumentsDirectory
{
    //return [[_fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
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
    
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:SKIAPP_JSON];
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
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES]
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
    
    for (NSDictionary *skiAreaJson in skiAreas) {
        SkiAreas *skiArea = [NSEntityDescription insertNewObjectForEntityForName:SM_SkiAreas inManagedObjectContext:context];
        skiArea.bounds_northeast = skiAreaJson[@"bounds_northeast"];
        skiArea.bounds_southwest = skiAreaJson[@"bounds_southwest"];
        skiArea.color = skiAreaJson[@"color"];
        skiArea.short_desc = skiAreaJson[@"short_desc"];
        skiArea.conditions = skiAreaJson[@"conditions"];
        skiArea.name_area = skiAreaJson[@"name_area"];
        skiArea.permissions = skiAreaJson[@"permissions"];
        
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
