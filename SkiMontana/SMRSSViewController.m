//
//  SMRSSViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 10/20/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import "SMRSSViewController.h"
//#import "SMRSSWebViewController.h"
#import "SMRSSParseOperation.h"
#import "SMRSSEntry.h"

#import <SafariServices/SafariServices.h>

// this framework is imported so we can use the kCFURLErrorNotConnectedToInternet error code
#import <CFNetwork/CFNetwork.h>

#import "RSSHeaderView.h"
#import "RSSDataLoadingView.h"

@interface SMRSSViewController () <UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (nonatomic) NSMutableArray *avyFeedList;
@property (nonatomic) NSOperationQueue *parseQueue;

@end

@implementation SMRSSViewController

- (void)setupDataLoadingView
{
    RSSDataLoadingView *dataLoadingView = [RSSDataLoadingView new];
    
    [self.tableView addSubview:dataLoadingView];
    
    // Centering data loading view
    NSLayoutConstraint *horizonalCenterConstraint = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:dataLoadingView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *verticalCenterConstraint = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:dataLoadingView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    
    dataLoadingView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView addConstraint:horizonalCenterConstraint];
    [self.tableView addConstraint:verticalCenterConstraint];
}

- (void)removeDataLoadingView
{
    for (id view in self.tableView.subviews) {
        if ([view isKindOfClass:[RSSDataLoadingView class]]) {
            [(RSSDataLoadingView *)view removeFromSuperview];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupDataLoadingView];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"MMM dd, yyyy HH:mm"];
    
    self.title = @"GNFAC Advisory";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.avyFeedList = [NSMutableArray array];
    
    static NSString *feedURLString = @"http://www.mtavalanche.com/advisory/feed";
    NSURLRequest *avyFeedURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:feedURLString]];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:avyFeedURLRequest
                                     completionHandler:^(NSData *data,
                                                         NSURLResponse *response,
                                                         NSError *error) {
                                         
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
        
        if (error != nil) {
            [self handleError:error];
        } else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (([response.MIMEType isEqual:@"application/rss+xml"] || [response.MIMEType isEqual:@"text/html"]) &&
                (httpResponse.statusCode == 200)) {
                // Update the UI and start parsing the data,
                // Spawn an NSOperation to parse the avy feed data so that the UI is not
                // blocked while the application parses the XML data.
                //
                SMRSSParseOperation *parseOperation = [[SMRSSParseOperation alloc] initWithData:data];
                [self.parseQueue addOperation:parseOperation];
            } else {
                NSString *errorString = NSLocalizedString(@"There was an error loading the RSS feed!", @"Error message displayed when receving a connection error.");
                NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: errorString };
                NSError *reportError = [NSError errorWithDomain:@"HTTP" code:httpResponse.statusCode userInfo:userInfo];
                [self handleError:reportError];
            }
        }
    }] resume];
    
    // Start the status bar network activity indicator.
    // We'll turn it off when the connection finishes or experiences an error.
    //
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    self.parseQueue = [NSOperationQueue new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addAvyFeeds:)
                                                 name:kAddAvyFeedNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(avyFeedsError:)
                                                 name:kAvyFeedErrorNotificationName object:nil];
    
    // if the locale changes behind our back, we need to be notified so we can update the date
    // format in the table view cells
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localeChanged:)
                                                 name:NSCurrentLocaleDidChangeNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAddAvyFeedNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAvyFeedErrorNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSCurrentLocaleDidChangeNotification object:nil];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

/**
 Handle errors in the download by showing an alert to the user. This is a very simple way of handling the error, partly because this application does not have any offline functionality for the user. Most real applications should handle the error in a less obtrusive way and provide offline functionality to the user.
 */
- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    NSString *alertTitle = NSLocalizedString(@"Error", @"Title for alert displayed when download or parse error occurs.");
    NSString *okTitle = NSLocalizedString(@"OK ", @"OK Title for alert displayed when download or parse error occurs.");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    
    [self removeDataLoadingView];
}

- (void)addAvyFeeds:(NSNotification *)notification
{
    assert([NSThread isMainThread]);
    [self removeDataLoadingView];
    [self addAvyFeedsToList:[notification.userInfo valueForKey:kAvyFeedResultsKey]];
}

- (void)avyFeedsError:(NSNotification *)notification
{
    assert([NSThread isMainThread]);
    [self removeDataLoadingView];
    [self handleError:[notification.userInfo valueForKey:kAvyFeedMessageErrorKey]];
}

- (void)localeChanged:(NSNotification *)notif
{
    [self.tableView reloadData];
}

/**
 The NSOperation "ParseOperation" calls addEarthquakes: via NSNotification, on the main thread which in turn calls this method, with batches of parsed objects. The batch size is set via the kSizeOfBatch constant.
 */
- (void)addAvyFeedsToList:(NSArray *)avyFeeds
{
    NSInteger startingRow = (self.avyFeedList).count;
    NSInteger avyFeedCount = avyFeeds.count;
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:avyFeedCount];
    
    for (NSInteger row = startingRow; row < (startingRow + avyFeedCount); row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [indexPaths addObject:indexPath];
    }
    
    [self.avyFeedList addObjectsFromArray:avyFeeds];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
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
    return self.avyFeedList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"rssCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    SMRSSEntry *rssFeed = (self.avyFeedList)[indexPath.row];
    
    cell.textLabel.text = [self.dateFormatter stringFromDate:rssFeed.pubDate];
    cell.textLabel.font = [UIFont skiMontanaFontOfSize:18.0];
    
    // Adjust font to shrink, if bigger than line
    cell.textLabel.numberOfLines = 1;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.minimumScaleFactor = 10.0/[UIFont labelFontSize];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[RSSHeaderView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMRSSEntry *rssFeed = (self.avyFeedList)[indexPath.row];
    
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:rssFeed.link];
    safariVC.delegate = self;
    [self presentViewController:safariVC animated:YES completion:nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - SFSafariViewControllerDelegate

-(void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully
{
    // Load finished
}

-(void)safariViewControllerDidFinish:(SFSafariViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
