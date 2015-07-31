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
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation LogoLoaderViewController

@synthesize content;
@synthesize logoView;       //UIView
@synthesize companyName;    //NSString
@synthesize companyLogo;    //UIImage
@synthesize cLogo;
@synthesize activityIndicator;

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
    
    //Check if data has been downloaded and pinned to local datastore.
    //If data has been downloaded pull from local datastore
    [self checkLocalDataStoreforData];
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
- (void)checkLocalDataStoreforData {
    PFQuery *query = [PFQuery queryWithClassName:@"splash_screen"];
    [query fromLocalDatastore];
    dispatch_async(dispatch_get_main_queue(), ^{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                if (objects.count > 0) {
                    // TODO: cim is always returning null
                    CIImage *cim = [content.imgPoster CIImage];
                    if (cim != nil) {
                        [self buildLogoLoader:content.imgPoster];
                    }
                    else {
                        PFFile *imageFile = [objects[0] objectForKey:@"field_background_image_img"];
                        [imageFile getDataInBackgroundWithBlock:^(NSData *imgData, NSError *error) {
                            if (!error) {
                                UIImage *backgroundImage = [[UIImage alloc] initWithData:imgData];
                                [self buildLogoLoader:backgroundImage];
                            }
                        }];
                    }
                    
                }
                else {
                    
                    activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                    activityIndicator.frame = CGRectMake(484.0, 300.0, 35.0, 35.0);
                    [activityIndicator setColor:[UIColor blackColor]];
                    [activityIndicator startAnimating];
                    [self.view addSubview:activityIndicator];
                    
                    [self fetchDataFromParse];
                }
            }
            else {
                NSLog(@"%s [Line %d] -- Error: %@ %@",__PRETTY_FUNCTION__, __LINE__,  error, [error userInfo]);
            }
        }];
    });
}

- (void)fetchDataFromParse {
    PFQuery *query = [PFQuery queryWithClassName:@"splash_screen"];
    query.limit = 1;
    [query orderByAscending:@"updatedAt"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                [PFObject pinAllInBackground:objects block:^(BOOL succeded, NSError *error) {
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
            }
            else {
                NSLog(@"%s [Line %d] -- Error: %@ %@",__PRETTY_FUNCTION__, __LINE__,  error, [error userInfo]);
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
    
    [activityIndicator stopAnimating];
    
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
    
    //Check if the company logo size and location have been set
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int x, y;
    long w, h;
    CGPoint logoLocation;
    
    //Check is company logo size has been set
    if ([defaults objectForKey:@"logosize"]) {
        NSDictionary *lSize = [NSDictionary dictionaryWithDictionary:[defaults objectForKey:@"logosize"]];
        w = [[lSize objectForKey:@"width"] integerValue];
        h = [[lSize objectForKey:@"height"] integerValue];
    
    }
    else {
        w = companyLogo.size.width;
        h = companyLogo.size.height;
    }
    
    //Check is company logo location has been set
    if ([defaults objectForKey:@"touchLocation"]) {
        logoLocation = CGPointFromString([NSString stringWithFormat:@"%@", [defaults objectForKey:@"touchLocation"]]);
        x = logoLocation.x;
        y = logoLocation.y;
    }
    else {
        x = logoView.bounds.size.width / 2;
        y = 200;
        logoLocation.x = x;
        logoLocation.y = y;
    }
    
    //UIImageView used to hold the splash company logo image
    cLogo = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    [cLogo setUserInteractionEnabled:YES];
    [cLogo setImage:companyLogo];
    cLogo.center = logoLocation;
    [logoView addSubview:cLogo];
    
    //UITapGesture used to navigate into the app
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGesture.numberOfTapsRequired = 1;
    [logoView addGestureRecognizer:tapGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(resizeImage:)];
    [cLogo addGestureRecognizer:pinchGesture];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // get touch event
    UITouch *touch = [[event allTouches] anyObject];
    if (touch.view == cLogo) {
        CGPoint touchLocation = [touch locationInView:self.view];
        cLogo.center = touchLocation;
        [defaults setValue:NSStringFromCGPoint(touchLocation) forKey:@"touchLocation"];
        [defaults synchronize];
    }
}

- (void)resizeImage:(UIPinchGestureRecognizer *)recognizer {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
    
    CGRect rect = recognizer.view.frame;
    int w = rect.size.width;
    int h = rect.size.height;
    
    NSMutableDictionary *cLogoSize = [NSMutableDictionary dictionary];
    [cLogoSize setObject:[NSNumber numberWithInt:w] forKey:@"width"];
    [cLogoSize setObject:[NSNumber numberWithInt:h] forKey:@"height"];
    
    [defaults setObject:cLogoSize forKey:@"logosize"];
    [defaults synchronize];
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
