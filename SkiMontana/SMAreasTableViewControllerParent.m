//
//  SMAreasTableViewControllerParent.m
//  SkiMontana
//
//  Created by Matt Eiben on 9/28/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import "SMAreasTableViewControllerParent.h"
#import "SMUtilities.h"

@interface SMAreasTableViewControllerParent () <UIPopoverPresentationControllerDelegate>

@property (strong, nonatomic) NSArray *products;
@property (strong, nonatomic) NSSet *productIdentifiers;
@property (strong, nonatomic) UIAlertController *actionSheetViewController;

@end

@implementation SMAreasTableViewControllerParent

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.deviceIsIPhone = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone);
    
    self.productIdentifiers = [NSSet setWithObjects:
        kIdentifierSubscription1Month,
        kIdentifierSubscription1Year,
        nil
    ];
    
    self.purchased = [SMIAPHelper checkInAppMemoryPurchasedState];
    
    if (TRIAL == NO) {
        if (self.purchased == YES) {
            [self checkReceiptsForSubscriptionChange];
        }
        else {
            [self requestProductsWithProductIdentifiers:self.productIdentifiers];
        }
    }
    
    // Adding button that returns to splash view
//    UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    homeButton.frame = CGRectMake(0, 0, 30, 30);
//    homeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [homeButton setImage:[UIImage imageNamed:@"warning"] forState:UIControlStateNormal];
//    [homeButton addTarget:self action:@selector(popToSplashView) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *homeItem = [[UIBarButtonItem alloc] initWithCustomView:homeButton];
//    self.navigationItem.leftBarButtonItem = homeItem;
}

//- (void)popToSplashView
//{
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

- (void)populateIsShowingArray
{
    NSArray *fetchedObjects = (self.fetchedResultsController).fetchedObjects;
    self.isShowingArray = [[NSMutableArray alloc] initWithCapacity:fetchedObjects.count];
    [fetchedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.isShowingArray addObject:@NO];
    }];
}

#pragma mark - Display message

- (void)alertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
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

- (void)checkReceiptsAfterPurchase
{
    // Note that subscription checking no longer checks again bundle versions due to Apple's App receipt not reflecting the most current App version and not validating
    // The argument in the methods remains though
    // WHY APPLE, WHY????????
    
    [[SCPStoreKitReceiptValidator sharedInstance] validateReceiptWithBundleIdentifier:BUNDLE_IDENTIFIER bundleVersion:@"1.0" tryAgain:YES showReceiptAlert:YES alertPresentingViewController:self alertViewTitle:nil alertViewMessage:nil success:^(SCPStoreKitReceipt *receipt) {
        
        NSLog(@"Receipt: %@", receipt.fullDescription);
        
        // Getting latest transaction
        SCPStoreKitIAPReceipt *lastTransaction;
        for (SCPStoreKitIAPReceipt *iapReceipt in receipt.inAppPurchases) {
            if ([self.productIdentifiers containsObject:iapReceipt.productIdentifier]) {
                if (!lastTransaction || [iapReceipt.subscriptionExpiryDate compare:lastTransaction.subscriptionExpiryDate] == NSOrderedDescending) {
                    lastTransaction = iapReceipt;
                }
            }
        }
        
        NSLog(@"Latest receipt: %@", lastTransaction);
        
        BOOL active = [SMIAPHelper subscriptionIsActiveWithReceipt:lastTransaction date:[NSDate date]];
        
        // Unlock App and reload view
        if (active) {
            [[SMUtilities sharedInstance] setAppLockedStateIsUnlocked:YES];
            self.purchased = [SMIAPHelper checkInAppMemoryPurchasedState];
            self.fetchedResultsController = nil;
            [self.fetchedResultsController performFetch:nil];
            [self populateIsShowingArray];
            [self.tableView reloadData];
            [self alertWithTitle:@"Purhcase Success" message:@"You have successfully subscribed to Ski Bozeman!"];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"Failure: %@", [error fullDescription]);
        NSLog(@"App not being unlocked");
    }];
}

- (void)checkReceiptsForSubscriptionChange
{
    // Note that subscription checking no longer checks again bundle versions due to Apple's App receipt not reflecting the most current App version and not validating
    // The argument in the methods remains though
    // WHY APPLE, WHY????????
    
    [[SCPStoreKitReceiptValidator sharedInstance] validateReceiptWithBundleIdentifier:BUNDLE_IDENTIFIER bundleVersion:@"1.0" tryAgain:YES showReceiptAlert:YES alertPresentingViewController:self alertViewTitle:nil alertViewMessage:nil success:^(SCPStoreKitReceipt *receipt) {
        
        NSLog(@"Receipt: %@", receipt.fullDescription);
        
        // Getting latest transaction
        SCPStoreKitIAPReceipt *lastTransaction;
        for (SCPStoreKitIAPReceipt *iapReceipt in receipt.inAppPurchases) {
            if ([self.productIdentifiers containsObject:iapReceipt.productIdentifier]) {
                if (!lastTransaction || [iapReceipt.subscriptionExpiryDate compare:lastTransaction.subscriptionExpiryDate] == NSOrderedDescending) {
                    lastTransaction = iapReceipt;
                }
            }
        }
        
        NSLog(@"Latest receipt cancellation date: %@", lastTransaction.cancellationDate);
        
        // Today's date should be between the purchase date and expiration date
        NSLog(@"Latest receipt expiratory date: %@", lastTransaction.subscriptionExpiryDate);
        NSLog(@"Today's date: %@", [NSDate date]);
        NSLog(@"Latest receipt purchase date: %@", lastTransaction.purchaseDate);
        
        BOOL purchased = self.purchased;
        BOOL active = [SMIAPHelper subscriptionIsActiveWithReceipt:lastTransaction date:[NSDate date]];
        
        // Subscription is no longer active ... lock the app!
        if (!active) {
            [[SMUtilities sharedInstance] setAppLockedStateIsUnlocked:NO];
            self.purchased = [SMIAPHelper checkInAppMemoryPurchasedState];
            self.fetchedResultsController = nil;
            [self.fetchedResultsController performFetch:nil];
            [self populateIsShowingArray];
            [self.tableView reloadData];
            [self alertWithTitle:@"Subscription Status" message:@"Your subscription has expired!"];
        }
        
        // In the case of restored subscription
        if (purchased == NO && active == YES) {
            [[SMUtilities sharedInstance] setAppLockedStateIsUnlocked:YES];
            self.purchased = [SMIAPHelper checkInAppMemoryPurchasedState];
            self.fetchedResultsController = nil;
            [self.fetchedResultsController performFetch:nil];
            [self populateIsShowingArray];
            [self.tableView reloadData];
            [self alertWithTitle:@"Subscription Status" message:@"Your subscription has been restored!"];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"Failure: %@", [error fullDescription]);
    }];
}

- (void)restorePurchases
{
    [[SCPStoreKitManager sharedInstance] restorePurchasesPaymentTransactionStateRestored:^(NSArray *transactions) {
        // Check if transaction is one of ours and verify receipt before unlocking
        for (SKPaymentTransaction *transaction in transactions) {
            if ([self.productIdentifiers containsObject:transaction.payment.productIdentifier]) {
                [self checkReceiptsForSubscriptionChange];
                break;
            }
        }
    } paymentTransactionStateFailed:^(NSArray *transactions) {
        NSLog(@"Failed to restore transactions : %@", transactions);
        [self alertWithTitle:@"Subscription Restore" message:@"Your subscription restoration failed"];
    } failure:^(NSError *error) {
        NSLog(@"Failure : %@", error.localizedDescription);
    }];
}

- (void)purchaseWithProduct:(SKProduct *)product
{
    [[SCPStoreKitManager sharedInstance] requestPaymentForProduct:product paymentTransactionStatePurchasing:^(NSArray *transactions) {
        NSLog(@"Purchasing products : %@", transactions);
    } paymentTransactionStatePurchased:^(NSArray *transactions) {
        NSLog(@"Purchased products : %@", transactions);
        // Receipt validation
        [self checkReceiptsAfterPurchase];
    } paymentTransactionStateFailed:^(NSArray *transactions) {
        NSLog(@"Failed products : %@", transactions);
        [self alertWithTitle:@"Failed Purchase" message:@"Something went wrong with the transaction, try again!"];
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

- (void)presentIAPActionSheet
{
    self.actionSheetViewController = [UIAlertController alertControllerWithTitle:@"Subscribe to Ski Bozeman\nLess than 1/2 the cost of a lift ticket for a season’s worth of adventure." message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    for (SKProduct *product in self.products) {
        
        formatter.locale = product.priceLocale;
        
        if ([product.productIdentifier isEqualToString:kIdentifierSubscription1Month]) {
            SKProduct *oneMonthProduct = product;
            NSString *title = [NSString stringWithFormat:@"One Month - %@", [formatter stringFromNumber:oneMonthProduct.price]];
            UIAlertAction *oneMonth = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self purchaseWithProduct:oneMonthProduct];
            }];
            [self.actionSheetViewController addAction:oneMonth];
        }
        
        if ([product.productIdentifier isEqualToString:kIdentifierSubscription1Year]) {
            SKProduct *oneYearProduct = product;
            NSString *title = [NSString stringWithFormat:@"One Year - %@", [formatter stringFromNumber:oneYearProduct.price]];
            UIAlertAction *oneYear = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self purchaseWithProduct:oneYearProduct];
            }];
            [self.actionSheetViewController addAction:oneYear];
        }
    }
    
    UIAlertAction *restore = [UIAlertAction actionWithTitle:@"Restore Subscription" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self restorePurchases];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [self.actionSheetViewController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [self.actionSheetViewController addAction:restore];
    [self.actionSheetViewController addAction:cancel];
    
    self.actionSheetViewController.popoverPresentationController.delegate = self;
    
    [self presentViewController:self.actionSheetViewController animated:YES completion:nil];
}

- (void)didEnterBackground:(NSNotification *)notification
{
    [self.actionSheetViewController dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - UIPopoverPresentationControllerDelegate

- (void)prepareForPopoverPresentation:(UIPopoverPresentationController *)popoverPresentationController
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    popoverPresentationController.sourceView = self.view;
    popoverPresentationController.sourceRect = cell.bounds;
}

@end

