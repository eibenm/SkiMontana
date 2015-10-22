//
//  SMRSSViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 10/20/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import "SMRSSViewController.h"

#import "SMRSSParseOperation.h"
#import "SMRSSEntry.h"

// this framework is imported so we can use the kCFURLErrorNotConnectedToInternet error code
#import <CFNetwork/CFNetwork.h>

@interface SMRSSViewController () <UITableViewDelegate, UITableViewDataSource>

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
    
    static NSString *feedURLString = @"http://earthquake.usgs.gov/eqcenter/catalogs/7day-M2.5.xml";
    NSURLRequest *avyFeedURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:feedURLString]];
    
    [NSURLConnection sendAsynchronousRequest:avyFeedURLRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        // back on the main thread, check for errors, if no errors start the parsing
        //
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        // here we check for any returned NSError from the server, "and" we also check for any http response errors
        if (error != nil) {
            [self handleError:error];
        }
        else {
            // check for any response errors
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if ((([httpResponse statusCode]/100) == 2) && [[response MIMEType] isEqual:@"application/atom+xml"]) {
                
                // Update the UI and start parsing the data,
                // Spawn an NSOperation to parse the earthquake data so that the UI is not
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
                                             selector:@selector(addEarthquakes:)
                                                 name:kAddEarthquakesNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(earthquakesError:)
                                                 name:kEarthquakesErrorNotificationName object:nil];
    
    // if the locale changes behind our back, we need to be notified so we can update the date
    // format in the table view cells
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localeChanged:)
                                                 name:NSCurrentLocaleDidChangeNotification
                                               object:nil];
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
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"rssCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.textLabel.text = @"title";
    return cell;
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
