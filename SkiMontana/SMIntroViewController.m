//
//  SMIntroViewController
//  SkiMontana
//
//  Created by Gneiss Software on 2/22/15.
//  Copyright (c) 2015 Gneiss Software. All rights reserved.
//

#import "SMIntroViewController.h"
#import "SMNavigationController.h"
#import "SMAreasTableViewController.h"

#import "SMDataLoading.h"

@interface SMIntroViewController ()

@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@property (strong, nonatomic) IBOutlet UIButton *startSkiingBtn;

- (IBAction)startSkiingAction:(id)sender;

@end

@implementation SMIntroViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup Background Image
    UIImage *image = [UIImage imageNamed:@"intro_background"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [imageView setFrame:self.view.frame];
    [self.backgroundView addSubview:imageView];
    
    // Set up Snow Particle Layer
    CAEmitterLayer *emitterLayer = [CAEmitterLayer layer];
    emitterLayer.emitterPosition = CGPointMake(self.view.bounds.origin.x - 50, self.view.bounds.origin.y);
    emitterLayer.emitterZPosition = 10;
    emitterLayer.emitterSize = CGSizeMake(self.view.bounds.size.width, 0);
    emitterLayer.emitterShape = kCAEmitterLayerSphere;
    
    CAEmitterCell *emitterCell = [CAEmitterCell emitterCell];
    emitterCell.scale = 0.1;
    emitterCell.scaleRange = 0.2;
    emitterCell.emissionRange = (CGFloat)M_PI_2;
    emitterCell.lifetime = 5.0;
    emitterCell.birthRate = 15;
    emitterCell.velocity = 200;
    emitterCell.velocityRange = 50;
    emitterCell.yAcceleration = 80;
    emitterCell.xAcceleration = -40;
    
    emitterCell.contents = (id)[[UIImage imageNamed:@"snow_particle"] CGImage];
    
    emitterLayer.emitterCells = [NSArray arrayWithObject:emitterCell];
    
    [self.backgroundView.layer addSublayer:emitterLayer];
    
    // Setup Start Skiing Button
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f);
    [self.startSkiingBtn setBackgroundImage:[[UIImage imageNamed:@"start_skiing"] resizableImageWithCapInsets:insets]
                                   forState:UIControlStateNormal];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
    
    /*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [activity setBackgroundColor:[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.4]];
        [activity setCenter:self.view.center];
        [activity setHidesWhenStopped:YES];
        [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activity setAlpha:0];
        [activity setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addSubview:activity];
        NSDictionary *views1 = NSDictionaryOfVariableBindings(activity);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[activity]|" options:kNilOptions metrics:nil views:views1]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[activity]|" options:kNilOptions metrics:nil views:views1]];
        
        UILabel *label = [[UILabel alloc] init];
        [label setText:@"Loading new Data!"];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont boldSkiMontanaFontOfSize:22]];
        [label setTextColor:[UIColor whiteColor]];
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [activity addSubview:label];
        NSDictionary *views2 = NSDictionaryOfVariableBindings(label);
        [activity addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[label]-160-|" options:kNilOptions metrics:nil views:views2]];
        [activity addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[label]|" options:kNilOptions metrics:nil views:views2]];
        
        [activity startAnimating];
        
        // After 2 seconds, fade the view in
        // After 2 more seconds, fade the view out
        [UIView animateWithDuration:0.25 animations:^{
            [activity setAlpha:1];
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.25 animations:^{
                    //[activity setAlpha:0];
                } completion:^(BOOL finished) {
                    //[activity stopAnimating];
                }];
            });
        }];
    });
    */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (IBAction)startSkiingAction:(id)sender
{
    SMNavigationController *navController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"baseNavigationController"];
    
    [UIView transitionWithView:self.view.window duration:0.6 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        [self presentViewController:navController animated:NO completion:nil];
    } completion:nil];
}

@end
