//
//  SMAreasTableViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 3/1/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMAreasTableViewController.h"
#import "SMOverviewMapViewController.h"
#import "SMAreaOverviewViewController.h"
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupMapButton];
    
    self.managedObjectContext = [SMDataManager sharedInstance].managedObjectContext;
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    self.title = @"Ski Guide";
}

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
        NSUInteger countArea = [sectionInfo numberOfObjects];
        NSUInteger countRoutes = [skiArea.ski_routes.allObjects count];
        //NSLog(@"%lu", countArea + countRoutes);
        return countArea;
        return countArea + countRoutes;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row == 0) {
        SkiAreas *skiArea = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text = skiArea.name_area;
    }
    else {
        SkiRoutes *skiRoute = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text = skiRoute.name_route;
    }

    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Section Selected: %li", (long)indexPath.section);
}

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController
{
    /*
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:SM_SkiRoutes inManagedObjectContext:self.managedObjectContext];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"ski_area.name_area" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"name_route" ascending:YES];
    NSArray *descriptors = @[sortDescriptor1, sortDescriptor2];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setSortDescriptors:descriptors];
    
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc]
                                                            initWithFetchRequest:fetchRequest
                                                            managedObjectContext:self.managedObjectContext
                                                            sectionNameKeyPath:@"ski_area.name_area"
                                                            cacheName:nil];
    
    fetchedResultsController.delegate = self;
    self.fetchedResultsController = fetchedResultsController;
    
    return _fetchedResultsController;
    */
    
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
    
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc]
            initWithFetchRequest:fetchRequest
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

@end



















/*
@interface SMAreasTableViewController ()
{
    NSMutableArray *_skiInformation;
    NSMutableArray *_isShowingArray;
}

@property (strong, nonatomic) SkiAreas *area;
@property (strong, nonatomic) SkiRoutes *route;

@property (weak, nonatomic) UIButton *mapButton;
@property (strong, nonatomic) UIImage *mapButtonBlackBackground;
@property (weak, nonatomic) UIImage *mapButtonBlueBackground;

@end

@implementation SMAreasTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupMapButton];
    
    self.title = @"Ski Guide";
    
    NSArray *skiAreaObjects = [[SMDataManager database] getSkiAreas];

    _skiInformation = [NSMutableArray new];
    [skiAreaObjects enumerateObjectsUsingBlock:^(SkiAreas *area, NSUInteger idx, BOOL *stop) {
        [_skiInformation addObject:[[[SMDataManager database] getSkiRoutesByAreaID:area.id] mutableCopy]];
        [[_skiInformation lastObject] insertObject:area atIndex:0];
    }];
    
    _isShowingArray = [[NSMutableArray alloc] initWithCapacity:[_skiInformation count]];
    [_skiInformation enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_skiInformation count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    for (NSArray *infos in _skiInformation) {
        if (section == [_skiInformation indexOfObject:infos]) {
            if ([[_isShowingArray objectAtIndex:[_skiInformation indexOfObject:infos]] boolValue] == NO) {
                return 1;
            }
            else {
                return [infos count];
            }
        }
    }
    
    return 1;
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
    
    
    for (NSArray *infoArray in _skiInformation) {
        if (indexPath.section == [_skiInformation indexOfObject:infoArray]) {
            if (indexPath.row == 0) {
                self.area = [infoArray objectAtIndex:indexPath.row];
                
                cell.viewAreaColor.backgroundColor = [UIColor colorwithHexString:self.area.color alpha:1.0];
                cell.labelAreaName.text = self.area.name_area;
                
                if (![[_isShowingArray objectAtIndex:[_skiInformation indexOfObject:infoArray]] boolValue]) {
                    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_up"]];
                }
                else {
                    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_down"]];
                }
            }
            else {
                self.route = [infoArray objectAtIndex:indexPath.row];
                
                cell.labelRouteName.text = self.route.name_route;
                cell.textViewShortDescription.text = self.route.short_description;
                cell.textViewShortDescription.textContainer.lineFragmentPadding = 0;
                cell.textViewShortDescription.textContainerInset = UIEdgeInsetsZero;
                cell.imageViewAreaImage.image = [UIImage imageNamed:self.route.image];
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.accessoryView = nil;
            }
        }
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
    [_skiInformation enumerateObjectsUsingBlock:^(id infoArray, NSUInteger index, BOOL *stop) {
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showRoute"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        SkiAreas *area = _skiInformation[indexPath.section][0];
        SkiRoutes *route = _skiInformation[indexPath.section][indexPath.row];
        SMDetailsViewController *viewController = [segue destinationViewController];
        viewController.name_area = area.name_area;
        viewController.route_id = [NSNumber numberWithInt:route.id];
        // Overwriting back text on next view controller.
        UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:nil action:nil];
        [self.navigationItem setBackBarButtonItem:newBackButton];
    }
    
    if ([segue.identifier isEqualToString:@"showAreaOverview"]) {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        SkiAreas *area = _skiInformation[indexPath.section][indexPath.row];
        SMAreasTableViewController *thisViewController = (SMAreasTableViewController *) self;
        SMAreaOverviewViewController *modalController = [segue destinationViewController];
        SMLayerAnimation *layerAnimation = [[SMLayerAnimation alloc] initWithType:SMLayerAnimationCover];
        thisViewController.animationController = layerAnimation;
        modalController.transitioningDelegate = self.transitioningDelegate;
        modalController.area_id = [NSNumber numberWithInt:area.id];
    }
}

@end
*/