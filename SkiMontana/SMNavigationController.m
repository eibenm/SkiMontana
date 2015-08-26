//
//  SMNavigationController.m
//  SMTransitionAnimation
//
//  Created by Matt Eiben on 3/15/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMNavigationController.h"
#import "UIFont+SkiMontana.h"

@implementation SMNavigationController

#pragma mark - Init methods

- (id)initWithRootViewController:(UIViewController *)rootViewController withAnimation:(SMBaseAnimation *)animation
{
    self = [super initWithRootViewController:rootViewController];
    if (self){
        self.delegate = self;
        self.animationController = animation;
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSShadow *shadow = [NSShadow new];
    [shadow setShadowColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8]];
    [shadow setShadowOffset:CGSizeMake(0, 1)];
    [[UINavigationBar appearance] setTranslucent:YES];
    [[UINavigationBar appearance] setTitleTextAttributes: @{
        //NSForegroundColorAttributeName: [UIColor darkGrayColor],
        //NSShadowAttributeName: shadow,
        NSFontAttributeName: [UIFont boldSkiMontanaFontOfSize:20.0f]
    }];
}


#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    
    self.animationController.fromViewController = fromVC;
    self.animationController.toViewController = toVC;
    
    if (self.interactionEnabled){
        [self.animationController setInteractionEnabled];
    }
    
    if (operation == UINavigationControllerOperationPop) {
        self.animationController.reverse = YES;
    } else {
        self.animationController.reverse = NO;
    }
    
    return self.animationController;
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController
{
    return self.interactionEnabled && self.animationController.interactionInProgress ? self.animationController : nil;
}

@end
