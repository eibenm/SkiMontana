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
#import "SMFlipAnimation.h"
#import "SMUtilities.h"

@interface SMIntroViewController ()

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *disclaimerTextView;
@property (weak, nonatomic) IBOutlet UIButton *startSkiingBtn;

- (IBAction)startSkiingAction:(id)sender;

@end

@implementation SMIntroViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *attrsDictionary = @{ NSKernAttributeName: @1 };
    (self.titleLabel).attributedText = [[NSAttributedString alloc] initWithString:@"Ski Bozeman" attributes:attrsDictionary];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f);
    UIImage *skiButtonEnabled = [UIImage imageNamed:@"start_skiing"];
    
    (self.disclaimerTextView).layer.cornerRadius = 5.0f;
    (self.startSkiingBtn).userInteractionEnabled = NO;
    (self.startSkiingBtn).layer.opacity = 0.8;
    [self.startSkiingBtn setTitle:@"Updating ..." forState:UIControlStateNormal];
    [self.startSkiingBtn setBackgroundImage:[skiButtonEnabled resizableImageWithCapInsets:insets]
                                   forState:UIControlStateNormal];
    
    [[SMUtilities sharedInstance] downloadSMJsonWithSuccess:^(BOOL appUpdated, NSString *message) {
        if (appUpdated == YES) {
            NSLog(@"Download success: App has been updated");
            NSLog(@"Message: %@", message);
        }
        else {
            NSLog(@"Download success: App has NOT been updated");
            NSLog(@"Message: %@", message);
        }
        [self.startSkiingBtn setUserInteractionEnabled:YES];
        [self.startSkiingBtn setTitle:@"I Agree" forState:UIControlStateNormal];
        [UIView animateWithDuration:0.25 animations:^{
            (self.startSkiingBtn).layer.opacity = 1.0;
        }];
    } error:^(NSError *error) {
        NSLog(@"Download failure: Error: %@", error.localizedDescription);
        [self.startSkiingBtn setUserInteractionEnabled:YES];
        [self.startSkiingBtn setTitle:@"I Agree" forState:UIControlStateNormal];
        [UIView animateWithDuration:0.25 animations:^{
            (self.startSkiingBtn.layer).opacity = 1.0;
        }];
    }];
        
    // Setup Background Image
    UIImage *image = [UIImage imageNamed:@"landing_image"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.frame = self.view.frame;
    [self.backgroundView addSubview:imageView];
    [self.backgroundView sendSubviewToBack:imageView];
    
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
    
    emitterCell.contents = (id)[UIImage imageNamed:@"snow_particle"].CGImage;
    
    emitterLayer.emitterCells = @[emitterCell];
    
    [self.backgroundView.layer addSublayer:emitterLayer];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
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

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (IBAction)startSkiingAction:(id)sender
{
    SMIntroViewController *thisViewController = (SMIntroViewController *)self;
    SMNavigationController *navController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"baseNavigationController"];
    SMFlipAnimation *layerAnimation = [[SMFlipAnimation alloc] initWithType:SMFlipAnimationBottom];
    thisViewController.animationController = layerAnimation;
    navController.transitioningDelegate = self.transitioningDelegate;
    [self presentViewController:navController animated:YES completion:nil];
}

@end
