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
#import "SMInitialSegue.h"

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)startSkiingAction:(id)sender
{
    SMNavigationController *navController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"baseNavigationController"];
    [[[SMInitialSegue alloc] initWithIdentifier:@"SMInitialSeue" source:self destination:navController] perform];
}

@end
