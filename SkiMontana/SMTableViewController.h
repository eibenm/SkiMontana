//
//  SMTableViewController.h
//  SkiMontana
//
//  Created by Matt Eiben on 3/15/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMBaseAnimation.h"

@interface SMTableViewController : UITableViewController <UIViewControllerTransitioningDelegate>

/**
 Animation for the transition
 */
@property (strong, nonatomic) SMBaseAnimation *animationController;

/**
 Whether interaction should be enabled for transitioning
 */
@property (assign, nonatomic) BOOL interactionEnabled;

/** Inits with nib and transitioning animations
 @param animation Animation for the transition
 @return An instance of SMFancyViewController
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withAnimation:(SMBaseAnimation *) animation;

@end
