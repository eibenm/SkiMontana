//
//  SMDataManager.m
//  CoreDataTestApp
//
//  Created by Gneiss Software on 5/18/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMDataManager.h"

#define kDataManagerModelName @"SkiDataModel"
#define kDataManagerSQLiteName @"SkiDataModel.sqlite"

NSString *const SM_SkiAreas = @"SkiAreas";
NSString *const SM_SkiRoutes = @"SkiRoutes";
NSString *const SM_Gps = @"Gps";
NSString *const SM_File = @"File";
NSString *const SM_Glossary = @"Glossary";

@interface SMDataManager()

- (NSURL *)applicationDocumentsDirectory;

@end

@implementation SMDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Singleton 

+ (SMDataManager *)sharedInstance
{
    static SMDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Core Data Boilerplate Code

- (NSURL *)applicationDocumentsDirectory
{
    return [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
}

- (NSManagedObjectModel *)managedObjectModel
{
    // The managed object model for the application.
    // It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:kDataManagerModelName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    // The persistent store coordinator for the application.
    // This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kDataManagerSQLiteName];
    
    NSDictionary *options = @{
        NSMigratePersistentStoresAutomaticallyOption: @YES,
        NSInferMappingModelAutomaticallyOption: @YES
    };
    
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
    
    // Don't backup to iCloud
    [self addSkipBackupAttributeToItemAtURL:storeURL];
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext
{
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        _managedObjectContext.persistentStoreCoordinator = coordinator;
    }
    
    return _managedObjectContext;
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath:URL.path]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue:@YES
                                  forKey:NSURLIsExcludedFromBackupKey
                                   error:&error];
    
    if(!success) {
        NSLog(@"Error excluding %@ from backup %@", URL.lastPathComponent, error.localizedDescription);
    }
    
    return success;
}

#pragma mark - Core Data Saving support

- (void)saveContext
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if (managedObjectContext.hasChanges && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unable to save context %@, %@", error.localizedDescription, error.userInfo);
            abort();
        }
    }
}

#pragma mark - Utility Methods

- (BOOL)clearPersistentStores
{
    _persistentStoreCoordinator = self.persistentStoreCoordinator;
        
    if (!_persistentStoreCoordinator) {
        return NO;
    }
    
    NSArray *stores = _persistentStoreCoordinator.persistentStores;
    NSError *storeError = nil;
    NSError *fileError = nil;
    
    for (NSPersistentStore *store in stores) {
        BOOL success1 = [_persistentStoreCoordinator removePersistentStore:store error:&storeError];
        BOOL success2 = [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:&fileError];
        if (!success1) {
            NSLog(@"Error clearing store: %@", storeError.localizedDescription);
            return NO;
        }
        if (!success2) {
            NSLog(@"Error clearing DB: %@", fileError.localizedDescription);
            return NO;
        }
        storeError = nil;
        fileError = nil;
    }
    
    _persistentStoreCoordinator = nil;
    
    return YES;
}

@end
