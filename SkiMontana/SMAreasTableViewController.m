//
//  SMAreasTableViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 3/1/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMAreasTableViewController.h"
#import "SMDetailsViewController.h"
#import "SMDataManager.h"

#import "SMSkiAreaTableViewCell.h"
#import "SMSkiRouteTableViewCell.h"

#import "SMArrowView.h"

@interface SMAreasTableViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SMAreasTableViewController
{
    NSMutableArray *_isShowingArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.managedObjectContext = [SMDataManager sharedInstance].managedObjectContext;
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    self.title = @"Ski Bozeman";
    
    NSArray *fetchedObjects = [self.fetchedResultsController fetchedObjects];
    
    _isShowingArray = [[NSMutableArray alloc] initWithCapacity:[fetchedObjects count]];
    [fetchedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [_isShowingArray addObject:[NSNumber numberWithBool:NO]];
    }];
    
    // View for background color (opaque white mask)
    UIView *backgroundColorView = [[UIView alloc]initWithFrame:self.view.frame];
    [backgroundColorView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.8]];
    [self.view addSubview:backgroundColorView];
    [self.view sendSubviewToBack:backgroundColorView];
    
    // Background imageview
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RouteInfoBackground"]];
    [backgroundImageView setContentMode:UIViewContentModeScaleAspectFill];
    [backgroundImageView setFrame:self.view.frame];
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        SkiAreas *skiArea = [sectionInfo objects][0];
        NSUInteger indexofCurrentObject = [[self.fetchedResultsController fetchedObjects] indexOfObject:skiArea];
        if ([[_isShowingArray objectAtIndex:indexofCurrentObject] boolValue] == NO) {
            return 1;
        }
        NSUInteger countArea = [sectionInfo numberOfObjects];
        NSUInteger countRoutes = [skiArea.ski_routes.allObjects count];
        return countArea + countRoutes;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier;
    
    if (indexPath.row == 0) { cellIdentifier = @"SkiArea";  }
    if (indexPath.row >  0) { cellIdentifier = @"SkiRoute"; }
    
    SMSkiRouteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[SMSkiRouteTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    UIView *selectedCellView = [UIView new];
    selectedCellView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.6f alpha:0.2];
    cell.selectedBackgroundView = selectedCellView;
    
    NSArray *skiAreaObjects = [self.fetchedResultsController fetchedObjects];
    SkiAreas *skiArea = skiAreaObjects[indexPath.section];
    
    BOOL skiAreaAllowed = [skiArea.permissions boolValue];

    if (indexPath.row == 0) {
        
        // Temporary workaround until all areas have images associated 
        NSString *areaImageString = skiArea.ski_area_image.avatar ? skiArea.ski_area_image.avatar : @"_7jvo5amB_exxkbLLSQLPaQsV6OSclOd";
        
        cell.areaImage.image = [UIImage imageNamed:areaImageString];
        cell.areaName.text = skiArea.name_area;
        cell.areaShortDesc.text = skiArea.short_desc;
        
        if (![_isShowingArray[[skiAreaObjects indexOfObject:skiArea]] boolValue]) {
            cell.accessoryView = [[SMArrowView alloc] initWithFrame:CGRectMake(0, 0, 30, 30) arrowType:SMArrowDown color:[UIColor blueColor]];
            cell.areaConditions.text = @"";
            cell.areaConditions.hidden = YES;
        }
        else {
            cell.accessoryView = [[SMArrowView alloc] initWithFrame:CGRectMake(0, 0, 30, 30) arrowType:SMArrowUp color:[UIColor redColor]];
            cell.areaConditions.text = skiArea.conditions;
            cell.areaConditions.hidden = NO;
        }
        
        if (skiAreaAllowed == NO) {
            UIImageView *lockedView = [[UIImageView alloc] initWithFrame:cell.areaImage.bounds];
            [lockedView setImage:[UIImage imageNamed:@"lock"]];
            [lockedView setContentMode:UIViewContentModeCenter];
            [cell.areaImage addSubview:lockedView];
        }
        
    }
    else {
        SkiRoutes *skiRoute = skiArea.ski_routes.allObjects[indexPath.row - 1];
        NSSet *skiRouteImages = skiRoute.ski_route_images;
        
        cell.labelRouteName.text = skiRoute.name_route;
        cell.textViewShortDescription.text = skiRoute.short_desc;
        cell.textViewShortDescription.textContainer.lineFragmentPadding = 0;
        cell.textViewShortDescription.textContainerInset = UIEdgeInsetsZero;
        if ([skiRouteImages count]) {
            File *image = [skiRouteImages.allObjects firstObject];
            cell.imageViewAreaImage.image = [UIImage imageNamed:image.avatar];
        }
        else {
            cell.imageViewAreaImage.backgroundColor = [UIColor blackColor];
        }
        
        cell.accessoryView = [[SMArrowView alloc] initWithFrame:CGRectMake(0, 0, 20, 25) arrowType:SMArrowRight color:[UIColor redColor]];
        
        if (skiAreaAllowed == NO) {
            UIImageView *lockedView = [[UIImageView alloc] initWithFrame:cell.imageViewAreaImage.bounds];
            [lockedView setImage:[UIImage imageNamed:@"lock"]];
            [lockedView setContentMode:UIViewContentModeCenter];
            [cell.imageViewAreaImage addSubview:lockedView];
        }
    }
    
    NSLog(@"%f", cell.contentView.frame.size.height);
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *skiAreaObjects = [self.fetchedResultsController fetchedObjects];
    
    CGFloat height = 140.0f;
    
    if (indexPath.row == 0) {
        SkiAreas *skiArea = skiAreaObjects[indexPath.section];
        
        if ([_isShowingArray[[skiAreaObjects indexOfObject:skiArea]] boolValue]) {
            height = 85.0f + 80.0f;
        }
        else {
            height = 85.0f;
        }
    }
    
    if (indexPath.row > 0) {
        height = 140.0f;
    }
    
    return height;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Collapse or expand section when the skiArea cell is selected
    NSArray *skiAreaObjects = [self.fetchedResultsController fetchedObjects];
    [skiAreaObjects enumerateObjectsUsingBlock:^(id skiArea, NSUInteger index, BOOL *stop) {
        if (indexPath.section == index) {
            if (indexPath.row == 0) {
                BOOL isShowing = [_isShowingArray[index] boolValue];
                [_isShowingArray replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:!isShowing]];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:index]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
    }];
}

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:SM_SkiAreas inManagedObjectContext:self.managedObjectContext];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"name_area" ascending:YES];
    NSArray *descriptors = @[sortDescriptor1];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setSortDescriptors:descriptors];
    
    NSFetchedResultsController *fetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                            managedObjectContext:self.managedObjectContext
                                              sectionNameKeyPath:@"name_area"
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSArray *skiAreaObjects = [self.fetchedResultsController fetchedObjects];
    
    if ([segue.identifier isEqualToString:@"showRoute"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        SkiAreas *skiArea = [skiAreaObjects objectAtIndex:indexPath.section];
        SkiRoutes *skiRoute = [skiArea.ski_routes.allObjects objectAtIndex:indexPath.row - 1];
        SMDetailsViewController *viewController = [segue destinationViewController];
        viewController.nameArea = skiArea.name_area;
        viewController.skiRoute = skiRoute;
        UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:nil action:nil];
        [self.navigationItem setBackBarButtonItem:newBackButton];
    }
    
    if ([segue.identifier isEqualToString:@"showGlossary"]) {
        UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:nil action:nil];
        [self.navigationItem setBackBarButtonItem:newBackButton];
    }
    
    /*
    if ([segue.identifier isEqualToString:@"showAreaOverview"]) {
        nil;
    }
    */
    
    /*
    if ([segue.identifier isEqualToString:@"showPurchase"]) {
        nil;
    }
    */
}

#pragma mark - In App Purchase
 
- (IBAction)purchaseOneMonth:(id)sender
{
    //[self restorePurchases];
    [self addActionSheet];
}

@end