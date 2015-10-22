//
//  SMWebViewController.m
//  SkiMontana
//
//  Created by Matt Eiben on 2/24/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMWebViewController.h"

@implementation SMWebViewController

- (void)initSMWebViewWithHtmlDoc:(NSString *)htmlName
{ 
    // Setting up UIWebView
    CGFloat navbarheight = self.navigationController.navigationBar.frame.size.height;
    
    CGRect web_rect = CGRectMake(self.view.frame.origin.x,
                                 navbarheight,
                                 self.view.frame.size.width,
                                 self.view.frame.size.height - navbarheight);
    
    self.webView = [[UIWebView alloc] initWithFrame:web_rect];
    self.webView.delegate = self;
    
    NSURL *html_doc = [[NSBundle mainBundle] URLForResource:htmlName withExtension:@"html"];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:html_doc]];
    (self.webView).backgroundColor = [UIColor clearColor];
    [self.webView setOpaque:NO];
    (self.view).backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.webView];
}

#pragma mark - Webview Delegate Methods

- (BOOL)webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType
{
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:inRequest.URL];
        return NO;
    }
    
    return YES;
}

@end
