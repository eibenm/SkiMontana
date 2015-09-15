//
//  SMDataLoading.h
//  SkiMontana
//
//  Created by Matt Eiben on 9/13/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMDataLoading : UIView

@property (strong, nonatomic) IBOutlet UIView *view;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *loadingLabel;

- (void)setLabelLookingForUpdate;
- (void)setLabelFoundUpdate;
- (void)setLabelUpdatingApp;

@end
