//
//  SMAreasTableViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 3/1/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMAreasTableViewController.h"
#import "SMAreaOverviewViewController.h"
#import "SMIAPViewController.h"
#import "SMDetailsViewController.h"
#import "SMDataManager.h"

#import "SMLayerAnimation.h"

#import "SMSkiAreaTableViewCell.h"
#import "SMSkiRouteTableViewCell.h"

@interface SMAreasTableViewController ()

@property (weak, nonatomic) UIButton *mapButton;
@property (strong, nonatomic) UIImage *mapButtonBlackBackground;
@property (weak, nonatomic) UIImage *mapButtonBlueBackground;

@end

@implementation SMAreasTableViewController
{
    NSMutableArray *_isShowingArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self setupMapButton];
    
    self.managedObjectContext = [SMDataManager sharedInstance].managedObjectContext;
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    self.title = @"Ski Guide";
    
    NSArray *fetchedObjects = [self.fetchedResultsController fetchedObjects];
    
    _isShowingArray = [[NSMutableArray alloc] initWithCapacity:[fetchedObjects count]];
    [fetchedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [_isShowingArray addObject:[NSNumber numberWithBool:NO]];
    }];
    
    // Asynchronously open table sections after 0.4 sec delay
    double delayInSeconds = 0.6f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        for (int i = 0; i < _isShowingArray.count; i++) {
            [_isShowingArray replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:YES]];
        }
        NSInteger sectionsNumber = [self.tableView numberOfSections];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, sectionsNumber)]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}

/*
- (void)setupMapButton
{
    self.mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.mapButtonBlackBackground = [UIImage imageNamed:@"globe_icon"];
    self.mapButtonBlueBackground = [self.mapButton tintedImageWithColor:[UIColor blueColor] image:self.mapButtonBlackBackground];
    [self.mapButton setImage:self.mapButtonBlackBackground forState:UIControlStateNormal];
    [self.mapButton setImage:self.mapButtonBlueBackground forState:UIControlStateSelected];
    [self.mapButton setImage:self.mapButtonBlueBackground forState:UIControlStateHighlighted];
    [self.mapButton addTarget:self action:@selector(presentMapViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.mapButton sizeToFit];
    UIBarButtonItem *mapBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.mapButton];
    [self.navigationItem setLeftBarButtonItem:mapBarButtonItem];
}
*/

/*
- (void)presentMapViewController
{
    void (^presentation)(void) = ^(void) {
        [self.mapButton setImage:self.mapButtonBlackBackground forState:UIControlStateNormal];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SMOverviewMapViewController *overivewMapViewController = (SMOverviewMapViewController *)[storyboard instantiateViewControllerWithIdentifier:@"overviewMap"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:overivewMapViewController];
        navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        navController.navigationBarHidden = NO;
        [self presentViewController:navController animated:YES completion:nil];
    };
    
    [self.mapButton setImage:self.mapButtonBlueBackground forState:UIControlStateNormal];
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulseAnimation.duration = 0.15f;
    pulseAnimation.toValue = [NSNumber numberWithFloat:1.4f];
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulseAnimation.autoreverses = YES;
    [CATransaction setCompletionBlock:presentation];
    [self.mapButton.layer addAnimation:pulseAnimation forKey:nil];
}
*/

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
    SkiAreas *skiArea = [skiAreaObjects objectAtIndex:indexPath.section];

    if (indexPath.row == 0) {
        cell.viewAreaColor.backgroundColor = [UIColor colorwithHexString:skiArea.color alpha:1.0];
        cell.labelAreaName.text = skiArea.name_area;
        
        if (![[_isShowingArray objectAtIndex:[skiAreaObjects indexOfObject:skiArea]] boolValue]) {
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_up"]];
        }
        else {
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_down"]];
        }
    }
    else {
        SkiRoutes *skiRoute = [skiArea.ski_routes.allObjects objectAtIndex:indexPath.row - 1];
        NSSet *skiRouteImages = skiRoute.ski_route_images;
        
        if ([skiArea.permissions  isEqual:[NSNumber numberWithBool:NO]]) {
            cell.backgroundColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:0.2];
        }
        
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
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = nil;
    }
        
    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    CGFloat height = UITableViewAutomaticDimension;
    
    if (indexPath.row == 0) { height = 80.0f;  }
    if (indexPath.row >  0) { height = 140.0f; }
    
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

/*
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}
*/

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
    
    if ([segue.identifier isEqualToString:@"showAreaOverview"]) {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        SkiAreas *skiArea = [skiAreaObjects objectAtIndex:indexPath.section];
        SMAreasTableViewController *thisViewController = (SMAreasTableViewController *) self;
        SMAreaOverviewViewController *modalController = [segue destinationViewController];
        SMLayerAnimation *layerAnimation = [[SMLayerAnimation alloc] initWithType:SMLayerAnimationCover];
        thisViewController.animationController = layerAnimation;
        modalController.transitioningDelegate = self.transitioningDelegate;
        modalController.skiArea = skiArea;
    }
    
    if ([segue.identifier isEqualToString:@"showPurchase"]) {
        nil;
    }
}
 
@end