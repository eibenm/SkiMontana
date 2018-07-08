//
//  SMDetailsHeaderView.h
//  SkiMontana
//
//  Created by Matt Eiben on 9/8/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

@interface SMDetailsHeaderView : UIView

@property (strong, nonatomic) IBOutlet UILabel *routeTitle;
@property (strong, nonatomic) IBOutlet UILabel *areaTitle;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *routeTitleTopConstaint;

@end
