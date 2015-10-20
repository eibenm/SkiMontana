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

static NSString *cellIdentifier;

@interface SMAreasTableViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSSortDescriptor *routeSortDescriptor;
@property (assign, nonatomic) BOOL deviceIsIPhone;

@end

@implementation SMAreasTableViewController
{
    NSMutableArray *_isShowingArray;
}

- (void)reloadTable
{
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Ski Bozeman";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.managedObjectContext = [SMDataManager sharedInstance].managedObjectContext;
    self.routeSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name_route" ascending:YES];
    self.deviceIsIPhone = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
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
        NSUInteger countRoutes = [skiArea.ski_routes count];
        return countRoutes + 2;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0: cellIdentifier = @"SkiArea"; break;
        case 1: cellIdentifier = @"SkiAreaConditions"; break;
        default: cellIdentifier = @"SkiRoute"; break;
    }
    
    SMSkiRouteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[SMSkiRouteTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    else {
        [[cell.contentView viewWithTag:500] removeFromSuperview];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSArray *skiAreaObjects = [self.fetchedResultsController fetchedObjects];
    SkiAreas *skiArea = skiAreaObjects[indexPath.section];

    if (indexPath.row == 0) {
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.maximumLineHeight = 17.0f;
        NSDictionary *attrsDictionary = @{
            NSParagraphStyleAttributeName: paragraphStyle,
            NSFontAttributeName: [UIFont skiMontanaFontOfSize:14.0f],
            NSForegroundColorAttributeName: [UIColor whiteColor]
        };
        
        [cell.areaImage setImage:[UIImage imageNamed:skiArea.ski_area_image.avatar]];
        [cell.areaImage.layer setBorderColor: [[UIColor blackColor] CGColor]];
        [cell.areaImage.layer setBorderWidth: 1.0];
        [cell.areaName setText:skiArea.name_area];
        [cell.areaName setTextColor:[UIColor whiteColor]];
        [cell.areaShortDesc setTextContainerInset:UIEdgeInsetsZero];
        [cell.areaShortDesc.textContainer setLineFragmentPadding:0];
        [cell.areaShortDesc.textContainer setLineBreakMode:NSLineBreakByTruncatingTail];
        [cell.areaShortDesc setAttributedText:[[NSAttributedString alloc] initWithString:skiArea.short_desc attributes:attrsDictionary]];
        
        if (self.deviceIsIPhone) {
            UIBezierPath *imgRect = [UIBezierPath bezierPathWithRect:CGRectInset(cell.areaImage.bounds, -8.0f, 0)];
            [cell.areaShortDesc.textContainer setExclusionPaths:@[imgRect]];
        }
        
        if (![_isShowingArray[[skiAreaObjects indexOfObject:skiArea]] boolValue]) {
            [cell setAccessoryView:[[SMArrowView alloc] initWithFrame:CGRectMake(0, 0, 30, 22) arrowType:SMArrowDown color:[UIColor blueColor]]];
        }
        else {
            [cell setAccessoryView:[[SMArrowView alloc] initWithFrame:CGRectMake(0, 0, 30, 22) arrowType:SMArrowUp color:[UIColor redColor]]];
        }
        
        // Setting lock on image if appropriate
        if ([skiArea.permissions boolValue] == NO) {
            UIImageView *lockedView = [[UIImageView alloc] initWithFrame:cell.areaImage.bounds];
            [lockedView setImage:[UIImage imageNamed:@"lock"]];
            [lockedView setContentMode:UIViewContentModeCenter];
            [lockedView setTag:500];
            [cell.areaImage addSubview:lockedView];
        }
    }
    
    else if (indexPath.row == 1) {
        [cell.areaConditions setText:skiArea.conditions];
        [cell.areaConditions setTextColor:[UIColor whiteColor]];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    else {
        NSArray *skiRoutesArray = [skiArea.ski_routes sortedArrayUsingDescriptors:@[self.routeSortDescriptor]];
        SkiRoutes *skiRoute = skiRoutesArray[indexPath.row - 2];
        NSDictionary *underlineAttribute = @{
            NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
            NSForegroundColorAttributeName: [UIColor whiteColor]
        };
        
        [cell.routeTitle setAttributedText:[[NSAttributedString alloc] initWithString:[skiRoute.name_route uppercaseString] attributes:underlineAttribute]];
        [cell.routeQuip setText:skiRoute.quip];
        [cell.routeQuip setTextColor:[UIColor whiteColor]];
        [cell.routeVertical setText:[NSString stringWithFormat:@"Vertical: %@", skiRoute.vertical]];
        [cell.routeVertical setTextColor:[UIColor whiteColor]];
        [cell.routeElevationGain setText:[NSString stringWithFormat:@"Elevation Gain: %@ ft", skiRoute.elevation_gain]];
        [cell.routeElevationGain setTextColor:[UIColor whiteColor]];
        [cell.routeDistance setText:[NSString stringWithFormat:@"Distance: ~%@ mi", skiRoute.distance]];
        [cell.routeDistance setTextColor:[UIColor whiteColor]];
        [cell setAccessoryView:[[SMArrowView alloc] initWithFrame:CGRectMake(0, 0, 22, 30) arrowType:SMArrowRight color:[UIColor redColor]]];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = UITableViewAutomaticDimension;
    
    CGRect conditionsRect = CGRectNull;
    
    // If conditions cell, calculating a rough cell height
    if (indexPath.row == 1) {
        NSArray *skiAreaObjects = [self.fetchedResultsController fetchedObjects];
        SkiAreas *skiArea = skiAreaObjects[indexPath.section];
        NSAttributedString * attributedString = [[NSAttributedString alloc] initWithString:skiArea.conditions attributes:@{ NSFontAttributeName:[UIFont mediumSkiMontanaFontOfSize:14]}];
        CGSize constraintSize = CGSizeMake(tableView.frame.size.width - 15, MAXFLOAT);
        conditionsRect = [attributedString boundingRectWithSize:constraintSize options:(NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading) context:nil];
    }
    
    switch (indexPath.row) {
        case 0: height = 230.0f; break;
        case 1: height = conditionsRect.size.height; break;
        default: height = 150.0f; break;
    }
    
    return height;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Collapse or expand section when skiArea cells are selected
    NSArray *skiAreaObjects = [self.fetchedResultsController fetchedObjects];
    [skiAreaObjects enumerateObjectsUsingBlock:^(id skiArea, NSUInteger index, BOOL *stop) {
        if (indexPath.section == index) {
            if (indexPath.row == 0 || indexPath.row == 1) {
                BOOL isShowing = [_isShowingArray[index] boolValue];
                [_isShowingArray replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:!isShowing]];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else {
                // Present IAP options if needed
                NSArray *skiAreaObjects = [self.fetchedResultsController fetchedObjects];
                SkiAreas *skiArea = skiAreaObjects[indexPath.section];
                if (skiArea.permissions.boolValue == NO) {
                    [self presentIAPActionSheet];
                }
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

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    NSArray *skiAreaObjects = [self.fetchedResultsController fetchedObjects];
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    SkiAreas *skiArea = skiAreaObjects[indexPath.section];
    if (skiArea.permissions.boolValue == NO) {
        return NO;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSArray *skiAreaObjects = [self.fetchedResultsController fetchedObjects];
    
    if ([segue.identifier isEqualToString:@"showRoute"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        SkiAreas *skiArea = [skiAreaObjects objectAtIndex:indexPath.section];
        NSArray *skiRoutesArray = [skiArea.ski_routes sortedArrayUsingDescriptors:@[self.routeSortDescriptor]];
        SkiRoutes *skiRoute = skiRoutesArray[indexPath.row - 2];
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
}

@end