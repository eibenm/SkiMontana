//
//  SMRSSEntry.h
//  SkiMontana
//
//  Created by Matt Eiben on 10/20/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

@interface SMRSSEntry : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSURL *link;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSDate *pubDate;

@end
