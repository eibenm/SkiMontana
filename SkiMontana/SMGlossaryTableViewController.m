//
//  SMGlossaryTableViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 9/14/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMGlossaryTableViewController.h"
#import "SMGlossaryTableViewCell.h"

static NSString *cellIdentifier = @"glossaryTerm";

@interface SMGlossaryTableViewController ()

@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation SMGlossaryTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.managedObjectContext = [SMDataManager sharedInstance].managedObjectContext;
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    self.title = @"Glossary";
    self.selectedIndex = -1.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.fetchedResultsController = nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    if (self.fetchedResultsController.sections.count > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMGlossaryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[SMGlossaryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    Glossary *glossary = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.termLabel.text = glossary.term;

    if (indexPath.row == self.selectedIndex) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.15 animations:^{
                cell.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.6f alpha:0.2];
            }];
        });
        cell.descriptionLabel.text = glossary.desc;
        cell.descriptionLabel.hidden = NO;
    }
    else {
        cell.descriptionLabel.text = @"";
        cell.descriptionLabel.hidden = YES;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
    //return [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 200)];
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.selectedIndex) {
        return 44.0f + 30.0f;
    }
    
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // User taps expanded row
    if (self.selectedIndex == indexPath.row) {
        self.selectedIndex = -1;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    
    // User taps different row
    if (self.selectedIndex != -1) {
        NSIndexPath *prevPath = [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
        self.selectedIndex = indexPath.row;
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [UIView animateWithDuration:0.15 animations:^{
                //[tableView cellForRowAtIndexPath:indexPath].backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
            }];
        }];
        [tableView reloadRowsAtIndexPaths:@[prevPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [CATransaction commit];
    }
    
    // User taps new row
    self.selectedIndex = indexPath.row;
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [UIView animateWithDuration:0.15 animations:^{
            //[tableView cellForRowAtIndexPath:indexPath].backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
        }];
    }];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [CATransaction commit];
}

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:SM_Glossary inManagedObjectContext:self.managedObjectContext];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"term" ascending:YES];
    NSArray *descriptors = @[sortDescriptor1];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setSortDescriptors:descriptors];
    
    NSFetchedResultsController *fetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                            managedObjectContext:self.managedObjectContext
                                              sectionNameKeyPath:nil
                                                       cacheName:nil];
    
    fetchedResultsController.delegate = self;
    self.fetchedResultsController = fetchedResultsController;
    
    return _fetchedResultsController;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

@end
