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

@interface SMGlossaryTableViewController() <UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) NSArray *filteredResults;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSFetchRequest *searchFetchRequest;

@end

@implementation SMGlossaryTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    (self.tableView).dataSource = self;
    (self.tableView).delegate = self;
    self.managedObjectContext = [SMDataManager sharedInstance].managedObjectContext;
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
    
    self.title = @"Glossary";
    self.selectedIndex = -1.0f;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    (self.searchController).searchResultsUpdater = self;
    (self.searchController).dimsBackgroundDuringPresentation = NO;
    (self.tableView).tableHeaderView = (self.searchController).searchBar;
    self.definesPresentationContext = YES;
    [(self.searchController).searchBar sizeToFit];
    
    // View for background color (opaque white mask)
    UIView *backgroundColorView = [[UIView alloc]initWithFrame:self.view.frame];
    backgroundColorView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    [self.view addSubview:backgroundColorView];
    [self.view sendSubviewToBack:backgroundColorView];
    
    // Background imageview
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RouteInfoBackground"]];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImageView.frame = self.view.frame;
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    
    // Setting autolayout constraints for background views
    [backgroundColorView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [backgroundImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *backgroundColorViews = NSDictionaryOfVariableBindings(backgroundColorView);
    NSDictionary *backgroundImageViews = NSDictionaryOfVariableBindings(backgroundImageView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundColorView]|" options:kNilOptions metrics:nil views:backgroundColorViews]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundColorView]|" options:kNilOptions metrics:nil views:backgroundColorViews]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundImageView]|" options:kNilOptions metrics:nil views:backgroundImageViews]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundImageView]|" options:kNilOptions metrics:nil views:backgroundImageViews]];
}

- (void)dealloc
{
    [self.searchController.view removeFromSuperview];
    self.searchController = nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
    //return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    if ((self.searchController).active) {
        return (self.filteredResults).count;
    }
    
    id <NSFetchedResultsSectionInfo> sectionInfo = (self.fetchedResultsController.sections)[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMGlossaryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[SMGlossaryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    Glossary *glossary = nil;
    
    if ((self.searchController).active) {
        glossary = self.filteredResults[indexPath.row];
    }
    else {
        glossary = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    
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
    
    fetchRequest.entity = entity;
    fetchRequest.fetchBatchSize = 20;
    fetchRequest.sortDescriptors = descriptors;
    
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

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    
    if (self.managedObjectContext) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"term BEGINSWITH[cd] %@", searchString];
        (self.searchFetchRequest).predicate = predicate;
        
        NSError *error = nil;
        self.filteredResults = [self.managedObjectContext executeFetchRequest:self.searchFetchRequest error:&error];
        if (error) {
            NSLog(@"searchFetchRequest failed: %@",[error localizedDescription]);
        }
    }
    [self.tableView reloadData];
}

- (NSFetchRequest *)searchFetchRequest
{
    if (_searchFetchRequest != nil) {
        return _searchFetchRequest;
    }
    
    _searchFetchRequest = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:SM_Glossary inManagedObjectContext:self.managedObjectContext];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"term" ascending:YES];
    NSArray *descriptors = @[sortDescriptor];
    
    _searchFetchRequest.entity = entity;
    _searchFetchRequest.fetchBatchSize = 20;
    _searchFetchRequest.sortDescriptors = descriptors;
    
    return _searchFetchRequest;
}

@end
