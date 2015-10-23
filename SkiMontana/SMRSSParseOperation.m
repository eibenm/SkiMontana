//
//  SMRSSParseOperation.m
//  SkiMontana
//
//  Created by Matt Eiben on 10/20/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import "SMRSSParseOperation.h"
#import "SMRSSEntry.h"

NSString *kAddAvyFeedNotificationName = @"AddAvyFeedNotification";
NSString *kAvyFeedResultsKey = @"AvyFeedResultsKey";

NSString *kAvyFeedErrorNotificationName = @"AvyFeedErrorNotification";
NSString *kAvyFeedMessageErrorKey = @"AvyFeedMsgErrorKey";

@interface SMRSSParseOperation () <NSXMLParserDelegate>

@property (nonatomic) SMRSSEntry *currentAvyFeedObject;
@property (nonatomic) NSMutableArray *currentParseBatch;
@property (nonatomic) NSMutableString *currentParsedCharacterData;

@end

@implementation SMRSSParseOperation
{
    NSDateFormatter *_dateFormatter;
    
    BOOL _accumulatingParsedCharacterData;
    BOOL _didAbortParsing;
    NSUInteger _parsedAvyFeedCounter;
}

- (instancetype)initWithData:(NSData *)parseData
{
    self = [super init];
    if (self) {
        _avyFeedData = [parseData copy];
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [_dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [_dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
        
        _currentParseBatch = [[NSMutableArray alloc] init];
        _currentParsedCharacterData = [[NSMutableString alloc] init];
    }
    return self;
}

- (void)addAvyFeedToList:(NSArray *)avyFeed
{
    assert([NSThread isMainThread]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddAvyFeedNotificationName object:self userInfo:@{kAvyFeedResultsKey: avyFeed}];
}

// The main function for this NSOperation, to start the parsing.
- (void)main
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.avyFeedData];
    [parser setDelegate:self];
    [parser parse];
    
    /*
     Depending on the total number of earthquakes parsed, the last batch might not have been a "full" batch, and thus not been part of the regular batch transfer. So, we check the count of the array and, if necessary, send it to the main thread.
     */
    if ((self.currentParseBatch).count > 0) {
        [self performSelectorOnMainThread:@selector(addAvyFeedToList:) withObject:self.currentParseBatch waitUntilDone:NO];
    }
}

#pragma mark - Parser constants

// Limit the parse to 50
static const NSUInteger kMaximumNumberToParse = 50;

// Send to tableView in batches of 10
// Reduces overhead in communicating between the threads and reloading the table
static NSUInteger const kSizeOfBatch = 10;

// Reduce potential parsing errors by using string constants declared in a single place.
static NSString * const kEntryElementName = @"item";
static NSString * const kTitleElementName = @"title";
static NSString * const kLinkElementName = @"link";
static NSString * const kDescriptionElementName = @"description";
static NSString * const kUpdatedElementName = @"pubDate";

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if (_parsedAvyFeedCounter >= kMaximumNumberToParse) {
        /*
         Use the flag didAbortParsing to distinguish between this deliberate stop and other parser errors.
         */
        _didAbortParsing = YES;
        [parser abortParsing];
    }
    if ([elementName isEqualToString:kEntryElementName]) {
        SMRSSEntry *rssEntry = [[SMRSSEntry alloc] init];
        self.currentAvyFeedObject = rssEntry;
    }
    else if ([elementName isEqualToString:kTitleElementName] ||
             [elementName isEqualToString:kUpdatedElementName] ||
             [elementName isEqualToString:kDescriptionElementName] ||
             [elementName isEqualToString:kLinkElementName]) {
        _accumulatingParsedCharacterData = YES;
        [self.currentParsedCharacterData setString:@""];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:kEntryElementName]) {
        [self.currentParseBatch addObject:self.currentAvyFeedObject];
        _parsedAvyFeedCounter++;
        if ((self.currentParseBatch).count >= kSizeOfBatch) {
            [self performSelectorOnMainThread:@selector(addAvyFeedToList:) withObject:self.currentParseBatch waitUntilDone:NO];
            self.currentParseBatch = [NSMutableArray array];
        }
    }
    else if ([elementName isEqualToString:kTitleElementName]) {
        (self.currentAvyFeedObject).title = self.currentParsedCharacterData;
        if (self.currentAvyFeedObject != nil) {
            (self.currentAvyFeedObject).title = [self.currentParsedCharacterData copy];
        }
    }
    else if ([elementName isEqualToString:kLinkElementName]) {
        if (self.currentAvyFeedObject != nil) {
            (self.currentAvyFeedObject).link = [NSURL URLWithString:[self.currentParsedCharacterData stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    else if ([elementName isEqualToString:kDescriptionElementName]) {
        if (self.currentAvyFeedObject != nil) {
            (self.currentAvyFeedObject).desc = [self.currentParsedCharacterData copy];
        }
    }
    else if ([elementName isEqualToString:kUpdatedElementName]) {
        (self.currentAvyFeedObject).pubDate = [_dateFormatter dateFromString:self.currentParsedCharacterData];
    }
    _accumulatingParsedCharacterData = NO;
}

/**
 This method is called by the parser when it find parsed character data ("PCDATA") in an element. The parser is not guaranteed to deliver all of the parsed character data for an element in a single invocation, so it is necessary to accumulate character data until the end of the element is reached.
 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if (_accumulatingParsedCharacterData) {
        [self.currentParsedCharacterData appendString:string];
    }
}

/**
 An error occurred while parsing the earthquake data: post the error as an NSNotification to our app delegate.
 */
- (void)handleParsingError:(NSError *)parseError {
    
    assert([NSThread isMainThread]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kAvyFeedErrorNotificationName object:self userInfo:@{kAvyFeedMessageErrorKey: parseError}];
}

/**
 An error occurred while parsing the earthquake data, pass the error to the main thread for handling.
 (Note: don't report an error if we aborted the parse due to a max limit of earthquakes.)
 */
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    if ([parseError code] != NSXMLParserDelegateAbortedParseError && !_didAbortParsing) {
        [self performSelectorOnMainThread:@selector(handleParsingError:) withObject:parseError waitUntilDone:NO];
    }
}



@end
