//
//  SMRSSCurrentViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 10/27/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import <WebKit/WebKit.h>

#import "SMRSSCurrentViewController.h"

@interface SMRSSCurrentViewController () <WKNavigationDelegate>

@property (weak, nonatomic) IBOutlet WKWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *back;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *stop;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refresh;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forward;

@end

@implementation SMRSSCurrentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(dismissViewController)];
    
    self.title = @"Current Advisory";
    self.navigationItem.leftBarButtonItem = backButton;
    self.webView.navigationDelegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.mtavalanche.com/current?theme=mobile_simple"]]];
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

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
    [self updateButtons];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
