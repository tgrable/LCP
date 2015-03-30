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
    UIImageView *l = [[UIImageView alloc] initWithFrame:CGRectMake(302, 250, 140, 140)];
    [l setImage:[UIImage imageNamed:@"logo-L.png"]];
    l.alpha = 0.0;
    [logoView addSubview:l];
    
    UIImageView *c = [[UIImageView alloc] initWithFrame:CGRectMake(442, 250, 140, 140)];
    [c setImage:[UIImage imageNamed:@"logo-C.png"]];
    c.alpha = 0.0;
    [logoView addSubview:c];
    
    UIImageView *p = [[UIImageView alloc] initWithFrame:CGRectMake(582, 250, 140, 140)];
    [p setImage:[UIImage imageNamed:@"logo-P.png"]];
    p.alpha = 0.0;
    [logoView addSubview:p];
    
    UIButton *title = [UIButton buttonWithType:UIButtonTypeCustom];
    [title setFrame:CGRectMake(302, 410, 420, 33)];
    [title addTarget:self action:@selector(goToSettings:)forControlEvents:UIControlEventTouchUpInside];
    title.showsTouchWhenHighlighted = YES;
    title.tag = 80;
    title.alpha = 0;
    [title setBackgroundImage:[UIImage imageNamed:@"logo-tag.png"] forState:UIControlStateNormal];
    [logoView addSubview:title];

    
    [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        //l animation
        l.alpha = 1.0;
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            //c animation
            c.alpha = 1.0;
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                //p animation
                p.alpha = 1.0;
            }completion:^(BOOL finished) {
                [UIView animateWithDuration:0.9f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                    //title animation
                    title.alpha = 1.0;
                }completion:^(BOOL finished) {
                    //timer function
                    //[self timerCountdown];
                    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
                    tapGesture.numberOfTapsRequired = 1;
                    [self.view addGestureRecognizer:tapGesture];
                }];
            }];
        }];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)goToSettings:(UIButton *)sender {
    //[self performSegueWithIdentifier:@"showSettings" sender:sender];
    //[self removeEverything];
}
- (void)viewTapped:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BrandMeetsWorldViewController *bmwvc = (BrandMeetsWorldViewController *)[storyboard instantiateViewControllerWithIdentifier:@"brandMeetsWorldViewController"];
    [self.navigationController pushViewController:bmwvc animated:YES];    
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
