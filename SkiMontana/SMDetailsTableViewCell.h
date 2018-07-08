//
//  SMDetailsTableViewCell.h
//  SkiMontana
//
//  Created by Matt Eiben on 4/27/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMDetailsInformationTableViewCell.h"

@interface SMDetailsTableViewCell : SMDetailsInformationTableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelElevation;
@property (strong, nonatomic) IBOutlet UILabel *labelVertical;
@property (strong, nonatomic) IBOutlet UILabel *labelSlope;
@property (strong, nonatomic) IBOutlet UILabel *labelDistance;
@property (strong, nonatomic) IBOutlet UILabel *labelSnowfall;
@property (strong, nonatomic) IBOutlet UILabel *labelAvalanche;
@property (strong, nonatomic) IBOutlet UILabel *labelSkierTraffic;

@end
