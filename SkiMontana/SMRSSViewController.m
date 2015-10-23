//
//  SMRSSViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 10/20/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import "SMRSSViewController.h"
#import "SMRSSWebViewController.h"
#import "SMRSSParseOperation.h"
#import "SMRSSEntry.h"

#import <SafariServices/SafariServices.h>

// this framework is imported so we can use the kCFURLErrorNotConnectedToInternet error code
#import <CFNetwork/CFNetwork.h>

@interface SMRSSViewController () <UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSMutableArray *avyFeedList;
@property (nonatomic) NSOperationQueue *parseQueue;

@end

@implementation SMRSSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"RSS Feed";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.avyFeedList = [NSMutableArray array];
    
    static NSString *feedURLString = @"http://www.mtavalanche.com/advisory/feed";
    NSURLRequest *avyFeedURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:feedURLString]];
    
    [NSURLConnection sendAsynchronousRequest:avyFeedURLRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (error != nil) {
            [self handleError:error];
        }
        else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (((httpResponse.statusCode / 100) == 2) && [response.MIMEType isEqual:@"application/rss+xml"]) {
                // Update the UI and start parsing the data,
                // Spawn an NSOperation to parse the avy feed data so that the UI is not
                // blocked while the application parses the XML data.
                //
                SMRSSParseOperation *parseOperation = [[SMRSSParseOperation alloc] initWithData:data];
                [self.parseQueue addOperation:parseOperation];
            }
            else {
                NSString *errorString = NSLocalizedString(@"HTTP Error", @"Error message displayed when receving a connection error.");
                NSDictionary *userInfo = @{ NSLocalizedDescriptionKey :errorString };
                NSError *reportError = [NSError errorWithDomain:@"HTTP" code:httpResponse.statusCode userInfo:userInfo];
                [self handleError:reportError];
            }
        }
    }];
    
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

- (void)dealloc {
    
    // we are no longer interested in these notifications:
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kAddAvyFeedNotificationName
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kAvyFeedErrorNotificationName
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSCurrentLocaleDidChangeNotification
                                                  object:nil];
}

/**
 Handle errors in the download by showing an alert to the user. This is a very simple way of handling the error, partly because this application does not have any offline functionality for the user. Most real applications should handle the error in a less obtrusive way and provide offline functionality to the user.
 */
- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    NSString *alertTitle = NSLocalizedString(@"Error", @"Title for alert displayed when download or parse error occurs.");
    NSString *okTitle = NSLocalizedString(@"OK ", @"OK Title for alert displayed when download or parse error occurs.");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle message:errorMessage delegate:nil cancelButtonTitle:okTitle otherButtonTitles:nil];
    [alertView show];
}

- (void)addAvyFeeds:(NSNotification *)notif
{
    assert([NSThread isMainThread]);
    [self addAvyFeedsToList:[[notif userInfo] valueForKey:kAvyFeedResultsKey]];
}

- (void)avyFeedsError:(NSNotification *)notif
{
    assert([NSThread isMainThread]);
    [self handleError:[[notif userInfo] valueForKey:kAvyFeedMessageErrorKey]];
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
    return (self.avyFeedList).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"rssCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    SMRSSEntry *rssFeed = (self.avyFeedList)[indexPath.row];
    
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"MMM dd, yyyy HH:mm"];
    
    //cell.textLabel.text = [formater stringFromDate:rssFeed.pubDate];
    
    cell.textLabel.text = rssFeed.title;
    cell.detailTextLabel.text = rssFeed.link.absoluteString;
    
//    NSLog(@"Title: %@", rssFeed.title);
//    NSLog(@"Link: %@", rssFeed.link);
//    NSLog(@"Desc: %@", rssFeed.desc);
//    NSLog(@"Pubdate: %@", rssFeed.pubDate);
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMRSSEntry *rssFeed = (self.avyFeedList)[indexPath.row];
    
    if (isIOS9OrLater()) {
        SFSafariViewController *safariVC = [[SFSafariViewController alloc]initWithURL:rssFeed.link entersReaderIfAvailable:NO];
        safariVC.delegate = self;
        [self presentViewController:safariVC animated:YES completion:nil];
    }
    else {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SMRSSWebViewController *webViewController = [storyboard instantiateViewControllerWithIdentifier:@"rssWebViewController"];
        webViewController.feedUrl = rssFeed.link;
        UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:nil action:nil];
        (self.navigationItem).backBarButtonItem = newBackButton;
        [self.navigationController pushViewController:webViewController animated:YES];
    }

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
