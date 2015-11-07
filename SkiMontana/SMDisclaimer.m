//
//  SMDisclaimer.m
//  SkiMontana
//
//  Created by Matt Eiben on 11/6/15.
//  Copyright © 2015 Gneiss Software. All rights reserved.
//

#import "SMDisclaimer.h"

@interface SMDisclaimer()

@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) CALayer *headerShadow;

- (IBAction)dismissView:(id)sender;

@end

@implementation SMDisclaimer

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"SMDisclaimer" owner:self options:nil];
        (self.view).alpha = 0;
        (self.view).frame = self.frame;
        (self.view).layer.cornerRadius = 6.0f;
        (self.view).transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
        [self addSubview:self.view];
        
        self.headerShadow = [CALayer layer];
        (self.headerShadow).backgroundColor = [UIColor grayColor].CGColor;
        (self.headerShadow).masksToBounds = NO;
        (self.headerShadow).shadowOpacity = 0.4;
        (self.headerShadow).shadowRadius = 3.0f;
        (self.headerShadow).shadowOffset = CGSizeMake(0, 2);
        [self.headerView.layer addSublayer:self.headerShadow];
        
        NSLog(@"%f", self.headerView.bounds.size.width);
        NSLog(@"%f", self.headerShadow.bounds.size.width);
        
        [UIView animateWithDuration:0.7
                              delay:0
             usingSpringWithDamping:0.7
              initialSpringVelocity:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             (self.view).alpha = 1;
                             (self.view).transform = CGAffineTransformIdentity;
                         }
                         completion:nil];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGRect headerRect = self.headerView.bounds;
    (self.headerShadow).frame = CGRectMake(0, CGRectGetHeight(headerRect) - 2.5f, CGRectGetWidth(headerRect), 5.0f);
}

- (IBAction)dismissView:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
        (self.view).alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
