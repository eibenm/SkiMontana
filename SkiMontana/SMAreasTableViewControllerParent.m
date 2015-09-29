//
//  SMAreasTableViewControllerParent.m
//  SkiMontana
//
//  Created by Matt Eiben on 9/28/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import "SMModel.h"
#import "StoreManager.h"
#import "StoreObserver.h"
#import "SMAreasTableViewControllerParent.h"

@interface SMAreasTableViewControllerParent ()

// Indicate that there are restored products
@property BOOL restoreWasCalled;

// Indicate whether a download is in progress
@property (nonatomic)BOOL hasDownloadContent;

@property SMModel *iapModel;

@end

@implementation SMAreasTableViewControllerParent

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hasDownloadContent = NO;
    self.restoreWasCalled = NO;
    self.iapModel = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleProductRequestNotification:)
                                                 name:IAPProductRequestNotification
                                               object:[StoreManager sharedInstance]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePurchasesNotification:)
                                                 name:IAPPurchaseNotification
                                               object:[StoreObserver sharedInstance]];
    
    [self fetchProductInformation];
}

#pragma mark - Display message

- (void)alertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Fetch product information

// Retrieve product information from the App Store
- (void)fetchProductInformation
{
    // Query the App Store for product information if the user is is allowed to make purchases.
    // Display an alert, otherwise.
    if([SKPaymentQueue canMakePayments])
    {
        [[StoreManager sharedInstance] fetchProductInformation];
    }
    else
    {
        // Warn the user that they are not allowed to make purchases.
        [self alertWithTitle:@"Warning" message:@"Purchases are disabled on this device."];
    }
}


#pragma mark - Handle product request notification

// Update the UI according to the product request notification result
- (void)handleProductRequestNotification:(NSNotification *)notification
{
    StoreManager *productRequestNotification = (StoreManager*)notification.object;
    IAPProductRequestStatus result = (IAPProductRequestStatus)productRequestNotification.status;
    
    if (result == IAPProductRequestResponse)
    {
        self.iapModel = [productRequestNotification.productRequestResponse firstObject];
        
        NSLog(@"%@: %@", self.iapModel.name, self.iapModel.elements);
    }
}


#pragma mark - Handle purchase request notification

// Update the UI according to the purchase request notification result
- (void)handlePurchasesNotification:(NSNotification *)notification
{
    StoreObserver *purchasesNotification = (StoreObserver *)notification.object;
    IAPPurchaseNotificationStatus status = (IAPPurchaseNotificationStatus)purchasesNotification.status;
    
    switch (status)
    {
        case IAPPurchaseFailed:
            [self alertWithTitle:@"Purchase Status" message:purchasesNotification.message];
            break;
            // Switch to the iOSPurchasesList view controller when receiving a successful restore notification
        case IAPRestoredSucceeded:
        {
            self.restoreWasCalled = YES;
            NSLog(@"Restore was successfull.  Now refresh the UI!");
        }
            break;
        case IAPRestoredFailed:
            [self alertWithTitle:@"Purchase Status" message:purchasesNotification.message];
            break;
            // Notify the user that downloading is about to start when receiving a download started notification
        case IAPDownloadStarted:
        {
            self.hasDownloadContent = YES;
        }
            break;
            // Display a status message showing the download progress
        case IAPDownloadInProgress:
        {
            self.hasDownloadContent = YES;
            NSString *title = [[StoreManager sharedInstance] titleMatchingProductIdentifier:purchasesNotification.purchasedID];
            NSString *displayedTitle = (title.length > 0) ? title : purchasesNotification.purchasedID;
            NSLog(@"Downloading %@   %.2f%%", displayedTitle, purchasesNotification.downloadProgress);
        }
            break;
            // Downloading is done, remove the status message
        case IAPDownloadSucceeded:
        {
            self.hasDownloadContent = NO;
            NSLog(@"IAP download success!");
        }
            break;
        default:
            break;
    }
}

#pragma mark Restore all appropriate transactions

- (void)restore
{
    // Call StoreObserver to restore all restorable purchases
    [[StoreObserver sharedInstance] restore];
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)dealloc
{
    // Unregister for StoreManager's notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IAPProductRequestNotification
                                                  object:[StoreManager sharedInstance]];
    
    // Unregister for StoreObserver's notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IAPPurchaseNotification
                                                  object:[StoreObserver sharedInstance]];
}

#pragma mark ActionSheet

- (void)addActionSheet
{
    UIAlertController *view= [UIAlertController alertControllerWithTitle:@"Subscribe to Ski Bozeman" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (SKProduct *product in self.iapModel.elements) {
        NSLog(@"%@", product.productIdentifier);
        
        if ([product.productIdentifier isEqualToString:kIdentifierSubscription1Month]) {
            SKProduct *oneMonthProduct = product;
            UIAlertAction *oneMonth = [UIAlertAction actionWithTitle:@"One Month" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [[StoreObserver sharedInstance] buy:oneMonthProduct];
            }];
            [view addAction:oneMonth];
        }
        
        if ([product.productIdentifier isEqualToString:kIdentifierSubscription1Year]) {
            SKProduct *oneYearProduct = product;
            UIAlertAction *oneYear = [UIAlertAction actionWithTitle:@"One Year" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [[StoreObserver sharedInstance] buy:oneYearProduct];
            }];
            [view addAction:oneYear];
        }
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        [view dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [view addAction:cancel];

    [self presentViewController:view animated:YES completion:nil];
}

/*
- (UIImage *)blurBackground
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 1.0f);
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *blurImaged = [snapshotImage applyBlurWithRadius:2.0 tintColor:[UIColor colorWithWhite:0.18 alpha:0.5] saturationDeltaFactor:1.8 maskImage:nil];
    
    return blurImaged;
}
*/

@end
