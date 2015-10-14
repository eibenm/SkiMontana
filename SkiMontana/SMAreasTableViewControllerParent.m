//
//  SMAreasTableViewControllerParent.m
//  SkiMontana
//
//  Created by Matt Eiben on 9/28/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import "SMAreasTableViewControllerParent.h"
#import "SCPStoreKitManager.h"
#import "SCPStoreKitReceiptValidator.h"

static NSString *manageSubscriptions = @"https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions";


@interface SMAreasTableViewControllerParent ()

@property (nonatomic, strong) NSArray *products;

@end

@implementation SMAreasTableViewControllerParent

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
    [[SCPStoreKitReceiptValidator sharedInstance] validateReceiptWithBundleIdentifier:BUNDLE_IDENTIFIER bundleVersion:@"1.0" tryAgain:YES showReceiptAlert:YES alertPresentingViewController:self alertViewTitle:nil alertViewMessage:nil success:^(SCPStoreKitReceipt *receipt) {
        
        //Here you would do some further checks such as :
        //Validate that the number of coins/tokens the user has does not exceed the number they have paid for
        //Unlock any non-consumable items
        
        NSLog(@"App receipt : %@", [receipt fullDescription]);
        
        //Enumerate through the IAPs and unlock their features
        [[receipt inAppPurchases] enumerateObjectsUsingBlock:^(SCPStoreKitIAPReceipt *iapReceipt, NSUInteger idx, BOOL *stop) {
            NSLog(@"IAP receipt :%@", [iapReceipt fullDescription]);
            //NSString *cancellationDate = iapReceipt.fullDescription[@"cancellationDate"];
        }];
        
    } failure:^(NSError *error) {
        NSLog(@"Failure: %@", [error fullDescription]);
    }];
    */
    
    NSSet *productIdentifiers = [NSSet setWithObjects:
        kIdentifierSubscription1Month,
        kIdentifierSubscription1Year,
        nil
    ];
    
    [self requestProductsWithProductIdentifiers:productIdentifiers];
}

#pragma mark - Display message

- (void)alertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)requestProductsWithProductIdentifiers:(NSSet *)identifiers
{
    [[SCPStoreKitManager sharedInstance] requestProductsWithIdentifiers:identifiers productsReturnedSuccessfully:^(NSArray *products) {
        NSLog(@"Success with products: %@", products);
        self.products = products;
    } invalidProducts:^(NSArray *invalidProducts) {
        NSLog(@"Invalid products: %@", invalidProducts);
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

- (void)restorePurchases
{
    [[SCPStoreKitManager sharedInstance] restorePurchasesPaymentTransactionStateRestored:^(NSArray *transactions) {
        NSLog(@"Restored transactions : %@", transactions);
        
        //        for (SKPaymentTransaction *transation in transactions) {
        //            NSLog(@"%@", transation.)
        //        }
        
    } paymentTransactionStateFailed:^(NSArray *transactions) {
        NSLog(@"Failed to restore transactions : %@", transactions);
    } failure:^(NSError *error) {
        NSLog(@"Failure : %@", [error localizedDescription]);
    }];
}

- (void)purchaseWithProduct:(SKProduct *)product
{
    [[SCPStoreKitManager sharedInstance] requestPaymentForProduct:product paymentTransactionStatePurchasing:^(NSArray *transactions) {
        NSLog(@"Purchasing products : %@", transactions);
    } paymentTransactionStatePurchased:^(NSArray *transactions) {
        NSLog(@"Purchased products : %@", transactions);
        [self alertWithTitle:@"Purhcase Success" message:@"You have successfully subscribed to Ski Bozeman!"];
    } paymentTransactionStateFailed:^(NSArray *transactions) {
        NSLog(@"Failed products : %@", transactions);
    } paymentTransactionStateRestored:^(NSArray *transactions) {
        NSLog(@"Restored products : %@", transactions);
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark ActionSheet

- (void)addActionSheet
{
    UIAlertController *view = [UIAlertController alertControllerWithTitle:@"Subscribe to Ski Bozeman" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (SKProduct *product in self.products) {
        
        if ([product.productIdentifier isEqualToString:kIdentifierSubscription1Month]) {
            SKProduct *oneMonthProduct = product;
            NSString *title = [NSString stringWithFormat:@"One Month - %@", oneMonthProduct.price];
            UIAlertAction *oneMonth = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self purchaseWithProduct:oneMonthProduct];
            }];
            [view addAction:oneMonth];
        }
        
        if ([product.productIdentifier isEqualToString:kIdentifierSubscription1Year]) {
            SKProduct *oneYearProduct = product;
            NSString *title = [NSString stringWithFormat:@"One Month - %@", oneYearProduct.price];
            UIAlertAction *oneYear = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self purchaseWithProduct:oneYearProduct];
            }];
            [view addAction:oneYear];
        }
    }
    
    UIAlertAction *restore = [UIAlertAction actionWithTitle:@"Restore Subscriptions" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self restorePurchases];
    }];
    
    UIAlertAction *manager = [UIAlertAction actionWithTitle:@"Manage Subscriptions" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        NSURL *manageUrl = [NSURL URLWithString:manageSubscriptions];
        if ([[UIApplication sharedApplication] canOpenURL:manageUrl]) {
            [[UIApplication sharedApplication] openURL:manageUrl];
        }
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        [view dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [view addAction:restore];
    [view addAction:manager];
    [view addAction:cancel];
    
    [self presentViewController:view animated:YES completion:nil];
}

@end

