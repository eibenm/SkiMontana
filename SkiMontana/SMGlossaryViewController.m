//
//  SMGlossaryViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 9/14/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMGlossaryViewController.h"
#import "SMGlossaryTableViewCell.h"

static NSString *cellIdentifier = @"glossaryTerm";

@interface SMGlossaryViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSManagedObjectID *selectedObjectID;
@property (strong, nonatomic) NSArray *filteredResults;
@property (strong, nonatomic) NSFetchRequest *searchFetchRequest;
@property (strong, nonatomic) UISearchController *searchController;

@end

#pragma mark -

@implementation SMGlossaryViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.managedObjectContext = [SMDataManager sharedInstance].managedObjectContext;

    // Setup the Search Controller
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.showsScopeBar = NO;
    self.searchController.searchBar.scopeButtonTitles = [NSArray array];
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleProminent;
    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = (self.searchController).searchBar;
    [self.searchController.searchBar sizeToFit];
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
    
    self.title = @"Glossary";
    self.selectedObjectID = nil;
    
    // View for background color (opaque white mask)
    UIView *backgroundColorView = [[UIView alloc] initWithFrame:self.view.frame];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)filterContentForSearchText:(NSString *)searchText
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"term BEGINSWITH[cd] %@", searchText];
    self.searchFetchRequest.predicate = predicate;
    self.filteredResults = [self.managedObjectContext executeFetchRequest:self.searchFetchRequest error:nil];
    [self.tableView reloadData];
}

- (BOOL)searchControllerActive
{
    return self.searchController.active && ![self.searchController.searchBar.text isEqualToString:@""];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self searchControllerActive]) {
        return self.filteredResults.count;
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
    
    Glossary *glossary = [self searchControllerActive] ? self.filteredResults[indexPath.row] : [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.termLabel.text = glossary.term;
    
    if (glossary.objectID == self.selectedObjectID) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.15 animations:^{
                cell.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.6f alpha:0.2];
            }];
        });
        cell.descriptionLabel.text = glossary.desc;
        cell.descriptionLabel.hidden = NO;
    } else {
        cell.descriptionLabel.text = @"";
        cell.descriptionLabel.hidden = YES;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Glossary *glossary = [self searchControllerActive] ? self.filteredResults[indexPath.row] : [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (glossary.objectID == self.selectedObjectID) {
        return 44.0f + 30.0f;
    }
    
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Glossary *glossary = [self searchControllerActive] ? self.filteredResults[indexPath.row] : [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // User taps expanded row
    if (glossary.objectID == self.selectedObjectID) {
        self.selectedObjectID = nil;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    
    // User taps different row
    if (self.selectedObjectID != nil) {
        
        // Find previous cell and reload both the old and new ones if the old one is still visible
        for (Glossary *entry in (self.fetchedResultsController).fetchedObjects) {
            if (self.selectedObjectID == entry.objectID) {
                for (SMGlossaryTableViewCell *visiblecell in tableView.visibleCells) {
                    if ([visiblecell.termLabel.text isEqualToString:entry.term]) {
                        self.selectedObjectID = glossary.objectID;
                        NSIndexPath *previousIndexPath = [tableView indexPathForCell:visiblecell];
                        [tableView reloadRowsAtIndexPaths:@[previousIndexPath, indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                        return;
                    }
                }
            }
        }
        
        self.selectedObjectID = glossary.objectID;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    
    // User taps new row
    self.selectedObjectID = glossary.objectID;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self filterContentForSearchText:searchBar.text];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [self filterContentForSearchText:searchController.searchBar.text];
}

@end

