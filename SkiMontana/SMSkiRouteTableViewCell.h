//
//  SMSkiRouteTableViewCell.h
//  SkiMontana
//
//  Created by Matt Eiben on 3/5/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMSkiAreaTableViewCell.h"

@interface SMSkiRouteTableViewCell : SMSkiAreaTableViewCell

@property (strong, nonatomic) IBOutlet UILabel *routeTitle;
@property (strong, nonatomic) IBOutlet UILabel *routeVertical;
@property (strong, nonatomic) IBOutlet UILabel *routeElevationGain;
@property (strong, nonatomic) IBOutlet UILabel *routeDistance;

@end
