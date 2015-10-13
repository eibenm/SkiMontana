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
@property (strong, nonatomic) IBOutlet UITextView *areaShortDesc;

@end
