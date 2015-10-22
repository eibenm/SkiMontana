//
//  SMRSSParseOperation.h
//  SkiMontana
//
//  Created by Matt Eiben on 10/20/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

extern NSString *kAddAvyFeedNotificationName;
extern NSString *kAvyFeedResultsKey;

extern NSString *kAvyFeedErrorNotificationName;
extern NSString *kAvyFeedMessageErrorKey;

@interface SMRSSParseOperation : NSOperation

@property (copy, readonly) NSData *avyFeedData;

- (id)initWithData:(NSData *)parseData;

@end
