//
//  SMDetailsViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 4/26/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMDetailsViewController.h"
#import "SMRouteMapViewController.h"

#import "SMDetailsTableViewCell.h"

#import "SMSlideAnimation.h"

static NSString *cellIdentifier;

static CGFloat scalingFactor = 0.3f;

@interface SMDetailsViewController() <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *routeTitle;
@property (weak, nonatomic) IBOutlet UILabel *areaTitle;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeight;

@property (nonatomic, assign) CGFloat offsetStartingY;
@property (nonatomic, assign) CGFloat offStartingRouteY;
@property (nonatomic, assign) CGFloat offStartingAreaY;
@property (nonatomic, assign) CGFloat maxOffsetY;

// A dictionary of offscreen cells that are used within the tableView:heightForRowAtIndexPath: method to
// handle the height calculations. These are never drawn onscreen.
@property (strong, nonatomic) NSMutableDictionary *offscreenCells;

@end

@implementation SMDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    
    [self setTitle:self.skiRoute.name_route];
    
    [self.areaTitle setText:self.nameArea];
    [self.routeTitle setText:self.skiRoute.name_route];
    
    self.offscreenCells = [NSMutableDictionary dictionary];
    
    self.headerView.layer.zPosition = 2;
    self.offsetStartingY = self.headerView.frame.size.height;
    self.offStartingRouteY = self.routeTitle.center.y;
    self.offStartingAreaY = self.areaTitle.center.y;
    self.maxOffsetY = 70.0f;
    
    [self.tableView setContentInset:UIEdgeInsetsMake(self.offsetStartingY, 0, 0, 0)];
    //[self.tableView setBackgroundColor:[UIColor clearColor]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0: cellIdentifier = @"map"; break;
        case 1: cellIdentifier = @"content"; break;
        case 2: cellIdentifier = @"overview"; break;
        case 3: cellIdentifier = @"avalanche"; break;
        case 4: cellIdentifier = @"directions"; break;
    }
    
    SMDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[SMDetailsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cellIdentifier isEqualToString:@"map"]) {
        
    }
    
    if ([cellIdentifier isEqualToString:@"content"]) {
        [cell.labelElevation setText:[NSString stringWithFormat:@"%@ ft", self.skiRoute.elevation_gain]];
        [cell.labelVertical setText:[NSString stringWithFormat:@"%@ ft", self.skiRoute.vertical]];
        [cell.labelSlope setText:self.skiRoute.aspects];
        [cell.labelDistance setText:[NSString stringWithFormat:@"~%@ mi", self.skiRoute.distance]];
        [cell.labelSnowfall setText:[NSString stringWithFormat:@"%@ in", self.skiRoute.snowfall]];
        [cell.labelAvalanche setText:self.skiRoute.avalanche_danger];
        [cell.labelSkierTraffic setText:self.skiRoute.skier_traffic];
    }
    else if ([cellIdentifier isEqualToString:@"overview"]) {
        [cell.labelOverviewInformation setText:self.skiRoute.overview];
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
    }
    else if ([cellIdentifier isEqualToString:@"avalanche"]) {
        [cell.labelAvalancheInformation setText:self.skiRoute.avalanche_info];
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
    }
    else if ([cellIdentifier isEqualToString:@"directions"]) {
        [cell.labelDirectionsInformation setText:self.skiRoute.directions];
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = UITableViewAutomaticDimension;
    
    switch (indexPath.row) {
        case 0: cellIdentifier = @"map"; break;
        case 1: cellIdentifier = @"content"; break;
        case 2: cellIdentifier = @"overview"; break;
        case 3: cellIdentifier = @"avalanche"; break;
        case 4: cellIdentifier = @"directions"; break;
    }
    
    switch (indexPath.row) {
        case 0: height = 120; break;
        case 1: height = 160; break;
    }
    
    SMDetailsTableViewCell *cell = [self.offscreenCells objectForKey:cellIdentifier];
    
    if (!cell) {
        cell = [[SMDetailsTableViewCell alloc] init];
        [self.offscreenCells setObject:cell forKey:cellIdentifier];
    }
    
    if ([cellIdentifier isEqualToString:@"overview"]) {
        [cell.labelOverviewInformation setText:self.skiRoute.overview];
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        height += 1;
    }
    else if ([cellIdentifier isEqualToString:@"avalanche"]) {
        [cell.labelAvalancheInformation setText:self.skiRoute.avalanche_info];
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        height += 1;
    }
    else if ([cellIdentifier isEqualToString:@"directions"]) {
        [cell.labelDirectionsInformation setText:self.skiRoute.directions];
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        height += 1;
    }
    
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = UITableViewAutomaticDimension;
    
    switch (indexPath.row) {
        case 0: height = 120; break;
        case 1: height = 160; break;
        case 3: height = 350; break;
        case 2: height = 350; break;
        case 4: height = 350; break;
    }
    
    return height;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.y;
    
    CGFloat offsetDiff = (-1.0f * self.offsetStartingY) - offset;
    
    // Adjusting table content inset
    // Adjusting height constraint on header
    // Adjusting labels in header
    // Adjuting opacity of area label
    
    if (offsetDiff < -80) {
        self.tableView.contentInset = UIEdgeInsetsMake(self.maxOffsetY, 0, 0, 0); // 100
        self.headerViewHeight.constant = self.maxOffsetY;
        self.routeTitle.center = CGPointMake(self.routeTitle.center.x, self.offStartingRouteY - (80 * scalingFactor));
        self.areaTitle.center = CGPointMake(self.areaTitle.center.x, self.offStartingAreaY - (80 * scalingFactor));
        self.areaTitle.layer.opacity = 0;
    }
    else if (offsetDiff > 0) {
        self.tableView.contentInset = UIEdgeInsetsMake(self.offsetStartingY, 0, 0, 0); // 150
        self.headerViewHeight.constant = self.offsetStartingY;
        self.routeTitle.center = CGPointMake(self.routeTitle.center.x, self.offStartingRouteY);
        self.areaTitle.center = CGPointMake(self.areaTitle.center.x, self.offStartingAreaY);
        self.areaTitle.layer.opacity = 1.0f;
    }
    else {
        self.tableView.contentInset = UIEdgeInsetsMake(ABS(offset), 0, 0, 0);
        self.headerViewHeight.constant = ABS(offset);
        self.routeTitle.center = CGPointMake(self.routeTitle.center.x, self.offStartingRouteY - (ABS(offsetDiff) * scalingFactor));
        self.areaTitle.center = CGPointMake(self.areaTitle.center.x, self.offStartingAreaY - (ABS(offsetDiff) * scalingFactor));
        self.areaTitle.layer.opacity = 1 - (ABS(offsetDiff) / 50); // Going opaque over the first 50 points
    }
    
    //NSLog(@"Current Offset:  %f", offset);
    //NSLog(@"Offset Diff: %f", offsetDiff);
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showMap"]) {
        SMDetailsViewController *thisViewController = (SMDetailsViewController *) self;
        SMRouteMapViewController *modalController = [segue destinationViewController];
        SMSlideAnimation *layerAnimation = [[SMSlideAnimation alloc] initWithType:SMSlideAnimationFromRight];
        thisViewController.animationController = layerAnimation;
        modalController.transitioningDelegate = self.transitioningDelegate;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end