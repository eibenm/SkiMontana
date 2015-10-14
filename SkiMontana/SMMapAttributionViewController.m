//
//  SMMapAttributionViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 10/13/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import "SMMapAttributionViewController.h"

#import "RMMapView.h"
#import "RMTileSource.h"

@interface RMMapView (RMAttributionViewControllerPrivate)

@property (nonatomic, assign) UIViewController *viewControllerPresentingAttribution;

- (void)dismissAttribution:(id)sender;

@end

#pragma mark -

@interface SMMapAttributionViewController () <UIWebViewDelegate>

@property (nonatomic, weak) RMMapView *mapView;

@end

#pragma mark -

@implementation SMMapAttributionViewController

- (id)initWithMapView:(RMMapView *)mapView
{
    self = [super initWithNibName:nil bundle:nil];
    
    if (self)
        _mapView = mapView;
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = @"Map Legend";
    
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
    
    CGRect frame = self.view.bounds;
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:frame];
    webView.delegate = self;
    webView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    webView.scrollView.showsVerticalScrollIndicator = NO;
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
    
    // build up HTML styling
    //
    NSMutableString *contentString = [NSMutableString string];
    
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleDisplayName"];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *currentYear = [dateFormatter stringFromDate:[NSDate date]];
    
    UIImage *legend = [UIImage imageNamed:@"legend"];
    UIGraphicsBeginImageContextWithOptions(legend.size, NO, [[UIScreen mainScreen] scale]);
    [legend drawAtPoint:CGPointMake(0, 0)];
    NSString *tempFile = [[NSTemporaryDirectory() stringByAppendingString:@"/"] stringByAppendingString:[NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]]];
    [UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext()) writeToFile:tempFile atomically:YES];
    UIGraphicsEndImageContext();
    
    [contentString appendString:[NSString stringWithFormat:@"<style type='text/css'>"
     "a {"
     "color: rgb(0,122,255);"
     "    text-decoration: none;"
     "}"
     "body {"
     "color: black;"
     "    font-family: Avenir-Medium;"
     "    font-size: 17;"
     "    text-align: center;"
     "margin: 20px;"
     "}"
     "</style>"
     ""
     "<img src='file://%@' width='200' />"
     ""
     "<br/>"
     "<br/>"
     ""
     "%@ uses the Mapbox iOS SDK © %@ Mapbox, Inc."
     ""
     "<br/>"
     ""
     "<a href='https://www.mapbox.com/'>More</a>"
     ""
     "<br/><br/>", tempFile, appName, currentYear]];
    
    [webView loadHTMLString:contentString baseURL:nil];
    [self.view addSubview:webView];
    
    // add activity indicator
    //
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    spinner.center = webView.center;
    spinner.tag = 1;
    [self.view insertSubview:spinner atIndex:0];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [_mapView.viewControllerPresentingAttribution shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return [_mapView.viewControllerPresentingAttribution supportedInterfaceOrientations];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    UIWebView *webView = (UIWebView *)self.view.subviews[0];
    
    if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)) {
        webView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    }
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark -

- (void)dismiss:(id)sender
{
    [self.mapView dismissAttribution:self];
}

#pragma mark -

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:request.URL];
        [self performSelector:@selector(dismiss:) withObject:nil afterDelay:0];
    }
    
    return [[request.URL scheme] isEqualToString:@"about"];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none';"];
    [[self.view viewWithTag:1] removeFromSuperview];
}

@end
