//
//  SMRSSEntry.m
//  SkiMontana
//
//  Created by Matt Eiben on 10/20/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import "SMRSSEntry.h"

/*
@interface SMRSSEntry()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end
*/

@implementation SMRSSEntry

/*
- (SMRSSEntry *)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        
        self.dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
        _dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
        
        self.title = @"title";
        self.link = @"link";
        self.desc = @"description";
        self.pubDate = [_dateFormatter dateFromString:@""];;
    }
    return self;
}

- (void)dealloc
{
    self.title = nil;
    self.link = nil;
    self.desc = nil;
    self.pubDate = nil;
}
*/

@end
