//
//  LogoLoaderViewController.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 2/24/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "LogoLoaderViewController.h"
#import "BrandMeetsWorldViewController.h"
#import <Parse/Parse.h>

@interface LogoLoaderViewController ()
@property (strong, nonatomic) UIView *logoView;
@end

@implementation LogoLoaderViewController
@synthesize logoView;                //UIView
@synthesize companyName;

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //Everything is going to be done in view did load to conserve memory
    //after view did load completes the memory will be released
    
    logoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    logoView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:logoView];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self buldLogoLoader];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buldLogoLoader {
    // TODO: This needs to be loaded dynamically
    UIImageView *splashImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, logoView.bounds.size.width, logoView.bounds.size.height)];
    [splashImg setImage:[UIImage imageNamed:@"img-splash"]];
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

- (void)viewTapped:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BrandMeetsWorldViewController *bmwvc = (BrandMeetsWorldViewController *)[storyboard instantiateViewControllerWithIdentifier:@"brandMeetsWorldViewController"];
    [self.navigationController pushViewController:bmwvc animated:YES];
    [self removeEverything];
}

#pragma mark
#pragma mark - Memory Management
- (void)removeEverything {
    for (UIView *v in [logoView subviews]) {
        [v removeFromSuperview];
    }
    [logoView removeFromSuperview];
}
@end
