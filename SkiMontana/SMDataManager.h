#import <CoreData/CoreData.h>

#import "SMManagedObjects.h"

COREDATA_EXTERN NSString *const SM_SkiAreas;
COREDATA_EXTERN NSString *const SM_SkiRoutes;
COREDATA_EXTERN NSString *const SM_Gps;
COREDATA_EXTERN NSString *const SM_File;
COREDATA_EXTERN NSString *const SM_Glossary;

@interface SMDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (SMDataManager*) sharedInstance;

- (void)saveContext;
- (BOOL)clearPersistentStores;

@end