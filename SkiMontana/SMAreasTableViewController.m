//
//  SMAreasTableViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 3/1/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMAreasTableViewController.h"
#import "SMOverviewMapViewController.h"
#import "SMDetailsViewController.h"
#import "SMDataManager.h"

#import "SMSkiRouteTableViewCell.h"
#import "SMArrowView.h"

static NSString *arrowUp = @"arrow_up";
static NSString *arrowDown = @"arrow_down";
static NSString *arrowRight = @"arrow_right";

static NSString *cellIdentifier;

@interface SMAreasTableViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSSortDescriptor *routeSortDescriptor;
@property (weak, nonatomic) IBOutlet UIButton *overviewMapButton;
@property (weak, nonatomic) IBOutlet UILabel *overviewMapLabel;
@property (weak, nonatomic) IBOutlet UIView *aboutThisAppView;
@property (weak, nonatomic) IBOutlet UIButton *aboutThisAppButton;
@property (weak, nonatomic) IBOutlet UILabel *aboutThisAppLabel;
@property (strong, nonatomic) NSOperationQueue *imageLoadingOperationQueue;
@property (strong, nonatomic) NSMutableDictionary *imageLoadingOperationsDictionary;
@property (strong, nonatomic) CAShapeLayer *maskLayer;

- (IBAction)didSelectOverviewMap:(id)sender;
- (IBAction)didSelectAboutThisApp:(id)sender;

@end

@implementation SMAreasTableViewController
{
    NSMutableArray *_isShowingArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Ski Bozeman";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.managedObjectContext = [SMDataManager sharedInstance].managedObjectContext;
    self.routeSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name_route" ascending:YES];
    self.deviceIsIPhone = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone);
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
    
    NSArray *fetchedObjects = (self.fetchedResultsController).fetchedObjects;
    
    _isShowingArray = [[NSMutableArray alloc] initWithCapacity:fetchedObjects.count];
    [fetchedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [_isShowingArray addObject:@NO];
    }];
    
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
    backgroundColorView.translatesAutoresizingMaskIntoConstraints = NO;
    backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *backgroundColorViews = NSDictionaryOfVariableBindings(backgroundColorView);
    NSDictionary *backgroundImageViews = NSDictionaryOfVariableBindings(backgroundImageView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundColorView]|" options:kNilOptions metrics:nil views:backgroundColorViews]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundColorView]|" options:kNilOptions metrics:nil views:backgroundColorViews]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundImageView]|" options:kNilOptions metrics:nil views:backgroundImageViews]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundImageView]|" options:kNilOptions metrics:nil views:backgroundImageViews]];
    
    // Configuring "Overview Map" View
    [self.overviewMapButton setImage:[UIImage imageNamed:@"overview_map"] forState:UIControlStateNormal];
    (self.overviewMapButton).imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    // Configuring "About This App" View
    [self.aboutThisAppButton setImage:[UIImage imageNamed:@"Skin Track"] forState:UIControlStateNormal];
    (self.aboutThisAppButton).imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.aboutThisAppView.backgroundColor = [UIColor clearColor];
    
    // Initializing asynch image loading queue
    if (!self.imageLoadingOperationQueue) {
        self.imageLoadingOperationQueue = [NSOperationQueue new];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // Creating mask so the CAnimation doesn't spill over view boundaries.
    if (!self.maskLayer) {
        self.maskLayer = [CAShapeLayer layer];
    }
    CGRect maskRect = CGRectMake(0, 4.0f, CGRectGetWidth(self.aboutThisAppView.bounds), CGRectGetHeight(self.aboutThisAppView.bounds) - 4.0f);
    CGPathRef path = CGPathCreateWithRect(maskRect, NULL);
    self.maskLayer.path = path;
    CGPathRelease(path);
    self.aboutThisAppView.layer.mask = self.maskLayer;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.imageLoadingOperationQueue cancelAllOperations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (self.fetchedResultsController).sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ((self.fetchedResultsController).sections.count > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = (self.fetchedResultsController).sections[section];
        SkiAreas *skiArea = sectionInfo.objects[0];
        NSUInteger indexofCurrentObject = [(self.fetchedResultsController).fetchedObjects indexOfObject:skiArea];
        if ([_isShowingArray[indexofCurrentObject] boolValue] == NO) {
            return 1;
        }
        NSUInteger countRoutes = (skiArea.ski_routes).count;
        return countRoutes + 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0: cellIdentifier = @"SkiArea"; break;
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
    
    NSArray *skiAreaObjects = (self.fetchedResultsController).fetchedObjects;
    SkiAreas *skiArea = skiAreaObjects[indexPath.section];

    // Ski Area
    if (indexPath.row == 0) {
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.maximumLineHeight = 17.0f;
        NSDictionary *attrsDictionary = @{
            NSParagraphStyleAttributeName: paragraphStyle,
            NSFontAttributeName: [UIFont skiMontanaFontOfSize:14.0f],
            NSForegroundColorAttributeName: [UIColor whiteColor]
        };
        
        UIBezierPath *imgRect = [UIBezierPath bezierPathWithRect:CGRectInset(cell.areaImage.bounds, -8.0f, 0)];

        (cell.areaName).text = skiArea.name_area;
        (cell.areaName).textColor = [UIColor whiteColor];
        //(cell.areaImage).image = [UIImage imageNamed:[skiArea.name_area stringByAppendingString:@"-thumbnail"]];
        (cell.areaImage.layer).borderColor = [UIColor darkGrayColor].CGColor;
        (cell.areaImage.layer).borderWidth = 1.0;
        (cell.areaConditions).textContainerInset = UIEdgeInsetsZero;
        (cell.areaConditions.textContainer).lineFragmentPadding = 0;
        (cell.areaConditions.textContainer).lineBreakMode = NSLineBreakByTruncatingTail;
        (cell.areaConditions).attributedText = [[NSAttributedString alloc] initWithString:skiArea.conditions attributes:attrsDictionary];
        (cell.areaConditions.textContainer).exclusionPaths = @[imgRect];
                
        if (![_isShowingArray[[skiAreaObjects indexOfObject:skiArea]] boolValue]) {
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:arrowDown]];
            (cell.areaConditionsHeightConstraint).priority = UILayoutPriorityDefaultHigh;
        }
        else {
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:arrowUp]];
            (cell.areaConditionsHeightConstraint).priority = UILayoutPriorityDefaultLow;
        }
        
        // Setting lock on image if appropriate
        if ((skiArea.permissions).boolValue == NO) {
            UIImageView *lockedView = [[UIImageView alloc] initWithFrame:cell.areaImage.bounds];
            lockedView.image = [UIImage imageNamed:@"lock"];
            lockedView.contentMode = UIViewContentModeCenter;
            lockedView.tag = 500;
            lockedView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
            [cell.areaImage addSubview:lockedView];
        }
        
        // Asynchronous image loading
        NSBlockOperation *loadImageIntoCellOp = [NSBlockOperation new];
        __weak NSBlockOperation *weakOperation = loadImageIntoCellOp;
        __block NSString *imageName = [skiArea.name_area stringByAppendingString:@"-thumbnail"];
        [loadImageIntoCellOp addExecutionBlock:^(void){
            // Background Thread
            UIImage *image = [UIImage imageNamed:imageName];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^(void) {
                // Main Thread
                if (!weakOperation.isCancelled) {
                    SMSkiRouteTableViewCell *cell = (SMSkiRouteTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                    (cell.areaImage).layer.opacity = 0;
                    (cell.areaImage).image = image;
                    [UIView animateWithDuration:0.4 animations:^{
                        (cell.areaImage).layer.opacity = 1;
                    }];
                }
            }];
        }];
        
        [self.imageLoadingOperationsDictionary setObject:loadImageIntoCellOp forKey:imageName];
        
        if (loadImageIntoCellOp) {
            [self.imageLoadingOperationQueue addOperation:loadImageIntoCellOp];
        }
        
        (cell.areaImage).image = nil;
    }
    
    // Ski Route
    else {
        NSArray *skiRoutesArray = [skiArea.ski_routes sortedArrayUsingDescriptors:@[self.routeSortDescriptor]];
        SkiRoutes *skiRoute = skiRoutesArray[indexPath.row - 1];
        NSDictionary *underlineAttribute = @{
            NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
            NSForegroundColorAttributeName: [UIColor whiteColor]
        };
        
        (cell.routeTitle).attributedText = [[NSAttributedString alloc] initWithString:(skiRoute.name_route).uppercaseString attributes:underlineAttribute];
        (cell.routeQuip).text = skiRoute.quip;
        (cell.routeQuip).textColor = [UIColor whiteColor];
        (cell.routeVertical).text = [NSString stringWithFormat:@"Vertical: %@", skiRoute.vertical];
        (cell.routeVertical).textColor = [UIColor whiteColor];
        (cell.routeElevationGain).text = [NSString stringWithFormat:@"Elevation Gain: %@ ft", skiRoute.elevation_gain];
        (cell.routeElevationGain).textColor = [UIColor whiteColor];
        (cell.routeDistance).text = [NSString stringWithFormat:@"Distance: ~%@ mi", skiRoute.distance];
        (cell.routeDistance).textColor = [UIColor whiteColor];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:arrowRight]];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

// Remove asynch image operation if cell leaves screen before loaded up.
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        NSArray *skiAreaObjects = (self.fetchedResultsController).fetchedObjects;
        SkiAreas *skiArea = skiAreaObjects[indexPath.section];
        NSString *imageName = [skiArea.name_area stringByAppendingString:@"-thumbnail"];
        NSBlockOperation *ongoingImageOperation = [self.imageLoadingOperationsDictionary objectForKey:imageName];
        if (ongoingImageOperation) {
            [ongoingImageOperation cancel];
            [self.imageLoadingOperationsDictionary removeObjectForKey:imageName];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *skiAreaObjects = (self.fetchedResultsController).fetchedObjects;
    SkiAreas *skiArea = skiAreaObjects[indexPath.section];
    CGFloat height = UITableViewAutomaticDimension;
    CGRect conditionsRect = CGRectNull;
    
    if (indexPath.row == 0) {
        if ([_isShowingArray[[skiAreaObjects indexOfObject:skiArea]] boolValue] == NO) {
            height = 178.0f;
        }
        else {
            // Estimating a better height if row is expanded
            NSAttributedString * attributedString = [[NSAttributedString alloc] initWithString:skiArea.conditions attributes:@{ NSFontAttributeName:[UIFont mediumSkiMontanaFontOfSize:14]}];
            CGSize constraintSize = CGSizeMake(tableView.frame.size.width - 15, MAXFLOAT);
            conditionsRect = [attributedString boundingRectWithSize:constraintSize options:(NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading) context:nil];
            height = (conditionsRect.size.height < 178.0f) ? 178.0f : conditionsRect.size.height;
        }
    }
    else {
        height = 135.0f;
    }
    
    return height;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *skiAreaObjects = (self.fetchedResultsController).fetchedObjects;
    SkiAreas *skiArea = skiAreaObjects[indexPath.section];
    NSUInteger index = [(self.fetchedResultsController).fetchedObjects indexOfObject:skiArea];
    
    // Collapse or expand section when skiArea cells are selected
    if (indexPath.row == 0) {
        _isShowingArray[index] = [NSNumber numberWithBool:![_isShowingArray[index] boolValue]];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        // Present IAP options if needed
        NSArray *skiAreaObjects = (self.fetchedResultsController).fetchedObjects;
        SkiAreas *skiArea = skiAreaObjects[indexPath.section];
        if (skiArea.permissions.boolValue == NO) {
            [self presentIAPActionSheet];
        }
    }
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
    
    fetchRequest.entity = entity;
    fetchRequest.fetchBatchSize = 20;
    fetchRequest.sortDescriptors = descriptors;
    
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
    NSSet *segues = [[NSSet alloc] initWithObjects:@"showAdvisory", nil];
    if ([segues containsObject:identifier]) {
        return YES;
    }
    
    NSArray *skiAreaObjects = (self.fetchedResultsController).fetchedObjects;
    NSIndexPath *indexPath = (self.tableView).indexPathForSelectedRow;
    SkiAreas *skiArea = skiAreaObjects[indexPath.section];
    if ((skiArea.permissions).boolValue == NO) {
        return NO;
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSArray *skiAreaObjects = (self.fetchedResultsController).fetchedObjects;
    
    if ([segue.identifier isEqualToString:@"showRoute"]) {
        NSIndexPath *indexPath = (self.tableView).indexPathForSelectedRow;
        SkiAreas *skiArea = skiAreaObjects[indexPath.section];
        NSArray *skiRoutesArray = [skiArea.ski_routes sortedArrayUsingDescriptors:@[self.routeSortDescriptor]];
        SkiRoutes *skiRoute = skiRoutesArray[indexPath.row - 1];
        SMDetailsViewController *viewController = segue.destinationViewController;
        viewController.nameArea = skiArea.name_area;
        viewController.skiRoute = skiRoute;
        UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:nil action:nil];
        (self.navigationItem).backBarButtonItem = newBackButton;
    }
    
    if ([segue.identifier isEqualToString:@"showAdvisory"]) {
        UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:nil action:nil];
        (self.navigationItem).backBarButtonItem = newBackButton;
    }
}

- (IBAction)didSelectOverviewMap:(id)sender
{
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulseAnimation.duration = 0.2f;
    pulseAnimation.toValue = @1.1f;
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    pulseAnimation.fillMode = kCAFillModeForwards;
    pulseAnimation.removedOnCompletion = NO;
    pulseAnimation.autoreverses = NO;
    [CATransaction setCompletionBlock:^{
        SMOverviewMapViewController *overviewMapController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"overviewMapViewController"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:overviewMapController];
        [self presentViewController:navController animated:YES completion:^{
            [self.overviewMapButton.layer removeAnimationForKey:pulseAnimation.keyPath];
            [self.overviewMapLabel.layer removeAnimationForKey:pulseAnimation.keyPath];
        }];
    }];
    [self.overviewMapButton.layer addAnimation:pulseAnimation forKey:pulseAnimation.keyPath];
    [self.overviewMapLabel.layer addAnimation:pulseAnimation forKey:pulseAnimation.keyPath];
}

- (IBAction)didSelectAboutThisApp:(id)sender
{
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulseAnimation.duration = 0.2f;
    pulseAnimation.toValue = @1.1f;
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    pulseAnimation.fillMode = kCAFillModeForwards;
    pulseAnimation.removedOnCompletion = NO;
    pulseAnimation.autoreverses = NO;
    [CATransaction setCompletionBlock:^{
        UIViewController *aboutThisApp = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"aboutThisApp"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:aboutThisApp];
        [self presentViewController:navController animated:YES completion:^{
            [self.aboutThisAppButton.layer removeAnimationForKey:pulseAnimation.keyPath];
            [self.aboutThisAppLabel.layer removeAnimationForKey:pulseAnimation.keyPath];
        }];
    }];
    [self.aboutThisAppButton.layer addAnimation:pulseAnimation forKey:pulseAnimation.keyPath];
    [self.aboutThisAppLabel.layer addAnimation:pulseAnimation forKey:pulseAnimation.keyPath];
}

@end