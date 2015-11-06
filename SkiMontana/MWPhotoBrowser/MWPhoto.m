//
//  MWPhoto.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 17/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import "MWPhoto.h"
#import "MWPhotoBrowser.h"

@interface MWPhoto ()

@end

@implementation MWPhoto

@synthesize underlyingImage = _underlyingImage; // synth property from protocol

#pragma mark - Class Methods

+ (MWPhoto *)photoWithImage:(UIImage *)image {
	return [[MWPhoto alloc] initWithImage:image];
}

// Deprecated
+ (MWPhoto *)photoWithFilePath:(NSString *)path {
    return [MWPhoto photoWithURL:[NSURL fileURLWithPath:path]];
}

+ (MWPhoto *)photoWithURL:(NSURL *)url {
	return [[MWPhoto alloc] initWithURL:url];
}

#pragma mark - Init

- (id)initWithImage:(UIImage *)image {
	if ((self = [super init])) {
		_image = image;
	}
	return self;
}

// Deprecated
- (id)initWithFilePath:(NSString *)path {
	if ((self = [super init])) {
		_photoURL = [NSURL fileURLWithPath:path];
	}
	return self;
}

- (id)initWithURL:(NSURL *)url {
	if ((self = [super init])) {
		_photoURL = [url copy];
	}
	return self;
}

#pragma mark - MWPhoto Protocol Methods

- (UIImage *)underlyingImage {
    return _underlyingImage;
}

- (void)loadUnderlyingImageAndNotify {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    @try {
        if (self.underlyingImage) {
            [self imageLoadingComplete];
        } else {
            [self performLoadUnderlyingImageAndNotify];
        }
    }
    @catch (NSException *exception) {
        self.underlyingImage = nil;
        [self imageLoadingComplete];
    }
    @finally {
    }
}

// Set the underlyingImage
- (void)performLoadUnderlyingImageAndNotify {
    
    // Get underlying image
    if (_image) {
        
        // We have UIImage!
        self.underlyingImage = _image;
        [self imageLoadingComplete];
        
    } else if (_photoURL) {
        
        // Load from local file async
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @autoreleasepool {
                @try {
                    self.underlyingImage = [UIImage imageWithContentsOfFile:_photoURL.path];
                    if (!_underlyingImage) {
                        MWLog(@"Error loading photo from path: %@", _photoURL.path);
                    }
                } @finally {
                    [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
                }
            }
        });
        
    } else {
        
        // Failed - no source
        @throw [NSException exceptionWithName:@"Exception - No Photo" reason:nil userInfo:nil];
        
    }
}

// Release if we can get it again from path or url
- (void)unloadUnderlyingImage {
	self.underlyingImage = nil;
}

- (void)imageLoadingComplete {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    // Complete so notify
    // Notify on next run loop
    [self performSelector:@selector(postCompleteNotification) withObject:nil afterDelay:0];
}

- (void)postCompleteNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_LOADING_DID_END_NOTIFICATION
                                                        object:self];
}

- (void)cancelAnyLoading {
}

@end
