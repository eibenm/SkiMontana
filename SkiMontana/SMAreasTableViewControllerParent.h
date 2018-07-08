//
//  SMAreasTableViewControllerParent.h
//  SkiMontana
//
//  Created by Matt Eiben on 9/28/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import "SMViewController.h"
#import "SMDataManager.h"

@interface SMAreasTableViewControllerParent : SMViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *isShowingArray;
@property (assign, nonatomic) BOOL deviceIsIPhone;
@property (assign, nonatomic) BOOL purchased;

- (void)presentIAPActionSheet;
- (void)populateIsShowingArray;

@end
