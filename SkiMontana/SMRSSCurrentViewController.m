//
//  SMRSSCurrentViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 10/27/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import <WebKit/WebKit.h>

#import "SMRSSCurrentViewController.h"

static NSString *KVEstimatedProgress;
static void * KVContext = &KVContext;

@interface SMRSSCurrentViewController () <WKNavigationDelegate>

@property (weak, nonatomic) IBOutlet WKWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *back;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *stop;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refresh;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forward;

@property (strong, nonatomic) UIProgressView *progressView;

@end

@implementation SMRSSCurrentViewController

- (void)viewDidLoad
{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(dismissViewController)];

    self.title = @"Current Advisory";
    self.navigationItem.leftBarButtonItem = backButton;
    self.webView.navigationDelegate = self;

    // Adding progress view
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.progressView.hidden = YES;
    self.progressView.alpha = 0.0f;
    [self.navigationController.navigationBar addSubview:self.progressView];
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    self.progressView.frame = CGRectMake(0, navigationBarBounds.size.height - 2, navigationBarBounds.size.width, 2);

    // Load url request
    NSURL *url = [NSURL URLWithString:@"http://www.mtavalanche.com/current?theme=mobile_simple"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    // Observe key values
    KVEstimatedProgress = NSStringFromSelector(@selector(estimatedProgress));
    [self.webView addObserver:self forKeyPath:KVEstimatedProgress options:NSKeyValueObservingOptionNew context:KVContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    if (context != KVContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if ([object isKindOfClass:[WKWebView class]] && [keyPath isEqualToString:KVEstimatedProgress]) {
        [self.progressView setAlpha:1.0f];
        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
        if (self.webView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.2 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.webView removeObserver:self forKeyPath:KVEstimatedProgress];
    [self.progressView removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Button Actions

- (IBAction)back:(id)sender
{
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }
}

- (IBAction)stop:(id)sender
{
    [self.webView stopLoading];
}

- (IBAction)refresh:(id)sender
{
    [self.webView reload];
}

- (IBAction)forward:(id)sender
{
    if (self.webView.canGoForward) {
        [self.webView goForward];
    }
}

- (void)updateButtons
{
    self.forward.enabled = self.webView.canGoForward;
    self.back.enabled = self.webView.canGoBack;
    self.stop.enabled = self.webView.loading;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
{
//    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
//        decisionHandler(WKNavigationActionPolicyCancel);
//        return;
//    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.progressView setHidden:NO];
    [self updateButtons];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.progressView setHidden:YES];
    [self updateButtons];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"webView: %@ didFailNavigation: %@ withError: %@\n", webView, navigation, error);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showRSS"]) {
        UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:nil action:nil];
        self.navigationItem.backBarButtonItem = newBackButton;
    }
}

@end
