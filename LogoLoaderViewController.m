//
//  LogoLoaderViewController.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 2/24/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "LogoLoaderViewController.h"
#import "ContentSettingsViewController.h"
#import "BrandMeetsWorldViewController.h"
#import "Reachability.h"
#import <Parse/Parse.h>

@interface LogoLoaderViewController ()

@property (strong, nonatomic) UIView *logoView;
@property (strong, nonatomic) UIImageView *cLogo;

@end

@implementation LogoLoaderViewController

@synthesize content;
@synthesize logoView;       //UIView
@synthesize companyName;    //NSString
@synthesize companyLogo;    //UIImage
@synthesize cLogo;

- (BOOL)prefersStatusBarHidden {
    //Hide status bar
    return YES;
}

#pragma mark -
#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //UIView used to hold the splashscreen image
    logoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    logoView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:logoView];

    //NSUserDefaults to check if data has been downloaded.
    //If data has been downloaded pull from local datastore else fetch data from Parse.com
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"splash_screen"] isEqualToString:@"hasData"]) {
        [self buildLogoLoader:content.imgPoster];
    }
    else {
        [self fetchDataFromParse];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Hide UINavigationController top bar
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark - Parse
- (void)fetchDataFromParse {
    PFQuery *query = [PFQuery queryWithClassName:@"splash_screen"];
    query.limit = 1;
    [query orderByAscending:@"updatedAt"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    PFFile *imageFile = [objects[0] objectForKey:@"field_background_image_img"];
                    [imageFile getDataInBackgroundWithBlock:^(NSData *imgData, NSError *error) {
                        if (!error) {
                            UIImage *backgroundImage = [[UIImage alloc] initWithData:imgData];
                            [self buildLogoLoader:backgroundImage];
                        }
                    }];
                });
            }
        }];
    });
}

#pragma mark -
#pragma mark - Build View
- (void)buildLogoLoader:(UIImage *)image {
    
    //UIImageView used to hold the splash screen image
    UIImageView *splashImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, logoView.bounds.size.width, logoView.bounds.size.height)];
    [splashImg setUserInteractionEnabled:NO];
    [splashImg setImage:image];
    [logoView addSubview:splashImg];
    
    //UILable and NSString used to hold Presented to content
    //NSString *name = (companyName == (id)[NSNull null] || companyName.length == 0 ) ? @"<COMPANY NAME HERE>" : companyName;
    if (companyName.length != 0) {
        UILabel *presentedTo = [[UILabel alloc] initWithFrame:CGRectMake(0, 520, logoView.bounds.size.width, 30)];
        [presentedTo setFont:[UIFont fontWithName:@"Oswald-light" size:24.0]];
        presentedTo.textColor = [UIColor whiteColor];
        presentedTo.numberOfLines = 1;
        presentedTo.backgroundColor = [UIColor clearColor];
        presentedTo.textAlignment = NSTextAlignmentCenter;
        presentedTo.text = [NSString stringWithFormat:@"PRESENTED TO %@", companyName];
        [logoView addSubview:presentedTo];
    }
    
    //UIImageView used to hold the splash screen image
    cLogo = [[UIImageView alloc] initWithFrame:CGRectMake(36, 500, companyLogo.size.width, companyLogo.size.height)];
    [cLogo setUserInteractionEnabled:YES];
    [cLogo setImage:companyLogo];
    //cLogo.contentMode = UIViewContentModeScaleAspectFit;
    [logoView addSubview:cLogo];
    
    //UITapGesture used to navigate into the app
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGesture.numberOfTapsRequired = 1;
    [logoView addGestureRecognizer:tapGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(resizeImage:)];
    [cLogo addGestureRecognizer:pinchGesture];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // get touch event
    UITouch *touch = [[event allTouches] anyObject];
    if (touch.view == cLogo) {
        CGPoint touchLocation = [touch locationInView:self.view];
        cLogo.center = touchLocation;
    }
}

- (void)resizeImage:(UIPinchGestureRecognizer *)recognizer {
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}

#pragma mark -
#pragma mark - Navigation
- (void)viewTapped:(id)sender {
    
    //Navigate into the app
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BrandMeetsWorldViewController *bmwvc = (BrandMeetsWorldViewController *)[storyboard instantiateViewControllerWithIdentifier:@"brandMeetsWorldViewController"];
    bmwvc.content = content;
    
    [self removeEverything];
    [self.navigationController pushViewController:bmwvc animated:YES];
}

#pragma mark -
#pragma mark - Reachability
- (BOOL)connected {
    //Check if there is an internet connection
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

#pragma mark -
#pragma mark - Memory Management
- (void)removeEverything {
    for (UIView *v in [logoView subviews]) {
        [v removeFromSuperview];
    }
    [logoView removeFromSuperview];
}
@end
