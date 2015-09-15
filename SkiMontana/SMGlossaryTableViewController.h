//
//  SMGlossaryTableViewController.h
//  SkiMontana
//
//  Created by Matt Eiben on 9/14/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMDataManager.h"

@interface SMGlossaryTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
