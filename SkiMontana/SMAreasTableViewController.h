//
//  SMAreasTableViewController.h
//  SkiMontana
//
//  Created by Matt Eiben on 3/1/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMAreasTableViewControllerParent.h"
#import "SMDataManager.h"

@interface SMAreasTableViewController : SMAreasTableViewControllerParent <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *buyBarItem;

- (IBAction)purchaseOneMonth:(id)sender;

@end
