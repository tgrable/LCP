//
//  LogoLoaderViewController.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 2/24/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "LogoLoaderViewController.h"
#import "BrandMeetsWorldViewController.h"
#import "Reachability.h"
#import <Parse/Parse.h>

@interface LogoLoaderViewController ()
@property (strong, nonatomic) UIView *logoView;
@end

@implementation LogoLoaderViewController
@synthesize logoView;                       //UIView
@synthesize companyName;                    //NSString

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark -
#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    logoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    logoView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:logoView];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    //NSUserDefaults to check if data has been downloaded.
    //If data has been downloaded pull from local datastore else fetch data from Parse.com
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"splash_screen"] isEqualToString:@"hasData"]) {
        [self fetchDataFromLocalDataStore];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark - Parse
- (void)fetchDataFromLocalDataStore {
    PFQuery *query = [PFQuery queryWithClassName:@"splash_screen"];
    query.limit = 1;
    [query fromLocalDatastore];
    [query orderByAscending:@"updatedAt"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    PFFile *imageFile = [objects[0] objectForKey:@"field_background_image_img"];
                    [imageFile getDataInBackgroundWithBlock:^(NSData *imgData, NSError *error) {
                        if (!error) {
                            UIImage *backgroundImg = [[UIImage alloc] initWithData:imgData];
                            [self buldLogoLoader:backgroundImg];
                        }
                    }];
                });
            }
        }];
    });
}

#pragma mark -
#pragma mark - Build View
- (void)buldLogoLoader:(UIImage *)image {
    UIImageView *splashImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, logoView.bounds.size.width, logoView.bounds.size.height)];
    [splashImg setImage:image];
    [logoView addSubview:splashImg];
    
    NSString *name = (companyName == (id)[NSNull null] || companyName.length == 0 ) ? @"<COMPANY NAME HERE>" : companyName;
    UILabel *presentedTo = [[UILabel alloc] initWithFrame:CGRectMake(0, 520, logoView.bounds.size.width, 30)];
    [presentedTo setFont:[UIFont fontWithName:@"Oswald-light" size:24.0]];
    presentedTo.textColor = [UIColor whiteColor];
    presentedTo.numberOfLines = 1;
    presentedTo.backgroundColor = [UIColor clearColor];
    presentedTo.textAlignment = NSTextAlignmentCenter;
    presentedTo.text = [NSString stringWithFormat:@"PRESENTED TO %@", name];
    [logoView addSubview:presentedTo];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGesture.numberOfTapsRequired = 1;
    [logoView addGestureRecognizer:tapGesture];
}

#pragma mark -
#pragma mark - Navigation
- (void)viewTapped:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BrandMeetsWorldViewController *bmwvc = (BrandMeetsWorldViewController *)[storyboard instantiateViewControllerWithIdentifier:@"brandMeetsWorldViewController"];
    [self.navigationController pushViewController:bmwvc animated:YES];
    [self removeEverything];
}

#pragma mark -
#pragma mark - Reachability
- (BOOL)connected
{
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
