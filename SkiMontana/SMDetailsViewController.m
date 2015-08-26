//
//  SMDetailsViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 4/26/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

/*
#import "SMDetailsViewController.h"
#import "SMRouteMapViewController.h"
#import "SMDataManager.h"

#import "SMDetailsTableViewCell.h"

#import "SMSlideAnimation.h"

static NSString *cellIdentifier;

static CGFloat scalingFactor = 0.6f;

@interface SMDetailsViewController() <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *routeTitle;
@property (weak, nonatomic) IBOutlet UILabel *areaTitle;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeight;

// A dictionary of offscreen cells that are used within the tableView:heightForRowAtIndexPath: method to
// handle the height calculations. These are never drawn onscreen.
@property (strong, nonatomic) NSMutableDictionary *offscreenCells;

@end

@implementation SMDetailsViewController
{
    CGFloat _defaultHeaderHeight;
    CGFloat _defaultTitleY;
    
    BOOL _isPulling;
    SkiRoutes *_route;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _route = [[SMDataManager database] getSkiRouteByRouteID:self.route_id.intValue];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    
    [self.tableView setContentInset:UIEdgeInsetsMake(self.headerView.frame.size.height, 0, 0, 0)];
    
    self.headerView.layer.zPosition = 2;
    
    _defaultHeaderHeight = self.headerViewHeight.constant;
    _defaultTitleY = self.areaTitle.center.y;
    
    [self.areaTitle setText:self.name_area];
    [self.routeTitle setText:_route.name_route];
    
    self.offscreenCells = [NSMutableDictionary dictionary];
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
        [cell.labelElevation setText:[NSString stringWithFormat:@"%d ft", _route.elevation_gain]];
        [cell.labelVertical setText:[NSString stringWithFormat:@"%d ft", _route.vertical]];
        [cell.labelSlope setText:_route.aspects];
        [cell.labelDistance setText:[NSString stringWithFormat:@"~%.1f mi", _route.distance]];
        [cell.labelSnowfall setText:[NSString stringWithFormat:@"%@ in", _route.snowfall]];
        [cell.labelAvalanche setText:_route.avalanche_danger];
        [cell.labelSkierTraffic setText:_route.skier_traffic];
    }
    else if ([cellIdentifier isEqualToString:@"overview"]) {
        [cell.labelOverviewInformation setText:_route.overview];
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
    }
    else if ([cellIdentifier isEqualToString:@"avalanche"]) {
        [cell.labelAvalancheInformation setText:_route.avalanche_info];
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
    }
    else if ([cellIdentifier isEqualToString:@"directions"]) {
        [cell.labelDirectionsInformation setText:_route.directions];
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
        [cell.labelOverviewInformation setText:_route.overview];
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        height += 1;
    }
    else if ([cellIdentifier isEqualToString:@"avalanche"]) {
        [cell.labelAvalancheInformation setText:_route.avalanche_info];
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        height += 1;
    }
    else if ([cellIdentifier isEqualToString:@"directions"]) {
        [cell.labelDirectionsInformation setText:_route.directions];
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
    CGFloat absoffset = ABS(offset);
    
    
    //NSLog(@"%f", offset);
    
    // Header view will start at 80 pts height and contract to 45 pts height.
    
    if (offset > -80 && offset < -45) {
        self.headerViewHeight.constant = absoffset;
        _isPulling = YES;
        
        if (offset <= -45) {
            // Fade Header SubLabel by ratio of offset within the first 40 points.
            self.areaTitle.alpha = (absoffset - 50) / (80 - 50);
            self.areaTitle.center = CGPointMake(self.areaTitle.center.x, _defaultTitleY - ((80 - absoffset) * scalingFactor));
        }
    }
    
    if (offset > -45 && _isPulling) {
        self.headerViewHeight.constant = 45;
        self.areaTitle.alpha = 0;
        _isPulling = NO;
    }
    
    if (offset < -80 && _isPulling) {
        self.headerViewHeight.constant = _defaultHeaderHeight;
        self.areaTitle.center = CGPointMake(self.areaTitle.center.x, _defaultTitleY);
        self.areaTitle.alpha = 1;
        _isPulling = NO;
    }
}


//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    NSLog(@"Stopped Height: %f !!!", self.headerViewHeight.constant);
//}


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
*/