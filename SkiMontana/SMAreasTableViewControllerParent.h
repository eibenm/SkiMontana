//
//  SMAreasTableViewControllerParent.h
//  SkiMontana
//
//  Created by Matt Eiben on 9/28/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import "SMViewController.h"

@interface SMAreasTableViewControllerParent : SMViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) BOOL deviceIsIPhone;
@property (assign, nonatomic) BOOL purchased;

- (void)presentIAPActionSheet;

@end
