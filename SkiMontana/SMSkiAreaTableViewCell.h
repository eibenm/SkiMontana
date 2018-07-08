//
//  SMSkiAreaTableViewCell.h
//  SkiMontana
//
//  Created by Matt Eiben on 3/5/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

@interface SMSkiAreaTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *areaImage;
@property (strong, nonatomic) IBOutlet UILabel *areaName;
@property (strong, nonatomic) IBOutlet UITextView *areaConditions;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *areaConditionsHeightConstraint;

@property (nonatomic, strong) UIView *areaBackgroundLayer;
@property (nonatomic, strong) UIView *routeBackgroundLayer;

@end
