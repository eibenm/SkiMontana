//
//  SMDetailsTableViewCell.m
//  SkiMontana
//
//  Created by Matt Eiben on 4/27/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMDetailsTableViewCell.h"

@implementation SMDetailsTableViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
    self.labelOverviewInformation.preferredMaxLayoutWidth = CGRectGetWidth(self.labelOverviewInformation.frame);
    self.labelAvalancheInformation.preferredMaxLayoutWidth = CGRectGetWidth(self.labelAvalancheInformation.frame);
    self.labelDirectionsInformation.preferredMaxLayoutWidth = CGRectGetWidth(self.labelDirectionsInformation.frame);
}

@end
