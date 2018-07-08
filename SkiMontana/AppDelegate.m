//
//  AppDelegate.m
//  SkiMontana
//
//  Created by Gneiss Software on 2/22/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "AppDelegate.h"
#import "SMAppearanceModifier.h"
#import "SMUtilities.h"
#import "SMNavigationController.h"
#import "SMAreasTableViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [SMAppearanceModifier defaultAppearance];
    
    [[SMUtilities sharedInstance] printDocumentsFolderIfSimulator];
    [[SMUtilities sharedInstance] initUserDefaults];
    [[SMUtilities sharedInstance] checkForAppStateChange];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// Handling force touch shortcut items from ios
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    NSString* viewAdvisoryKey = [NSString stringWithFormat:@"%@.viewAdvisory", [[NSBundle mainBundle] bundleIdentifier]];

    if ([shortcutItem.type isEqualToString:viewAdvisoryKey]) {
        SMNavigationController *navController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"baseNavigationController"];
        self.window.rootViewController = navController;
        SMAreasTableViewController *controller = [self getAreasTableViewController:navController];
        if (controller != nil) {
            [controller performSegueWithIdentifier:@"showAdvisory" sender:controller];
        }
        [self.window makeKeyAndVisible];
        completionHandler(YES);
    }
    
    completionHandler(NO);
}

// Recursively getting SMAreasTableViewController from view controller hierarchy
- (SMAreasTableViewController *)getAreasTableViewController:(UIViewController *)baseViewController
{
    for (UIViewController *controller in baseViewController.childViewControllers) {
        if ([controller isKindOfClass:[SMAreasTableViewController class]]) {
            return (SMAreasTableViewController *)controller;
        } else {
            if (controller.childViewControllers.count > 0) {
                return [self getAreasTableViewController:controller];
            }
        }
    }
    
    return nil;
}

@end
