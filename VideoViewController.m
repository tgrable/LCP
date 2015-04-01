//
//  VideoViewController.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 3/31/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "VideoViewController.h"
#import "Reachability.h"
#import <Parse/Parse.h>

@interface VideoViewController ()

@property (strong, nonatomic) UIView *background;
@property (strong, nonatomic) UIImageView *videoPoster;
@property (nonatomic) MPMoviePlayerController *moviePlayerController;

@end

@implementation VideoViewController

@synthesize content;
@synthesize background;
@synthesize videoPoster;
@synthesize moviePlayerController;

- (void)viewDidLoad {
    [super viewDidLoad];
    // TODO: Add a UIScrollView for multiple videos

    //UIView 36 pixels smaller than the device bounds used to hold the rest of the view objects
    background = [[UIView alloc] initWithFrame:CGRectMake(36, 36, (self.view.bounds.size.width - (36 * 2)), (self.view.bounds.size.height - (36 * 2)))];
    [background setBackgroundColor:[UIColor lightGrayColor]];
    [background setUserInteractionEnabled:YES];
    [self.view addSubview:background];
    
    //Logo, settings, and home buttons
    UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoButton setFrame:CGRectMake(56, 56, 108, 33)];
    //[logoButton addTarget:self action:@selector(hiddenSection:)forControlEvents:UIControlEventTouchUpInside];
    logoButton.showsTouchWhenHighlighted = YES;
    [logoButton setBackgroundImage:[UIImage imageNamed:@"logo.png"] forState:UIControlStateNormal];
    [self.view addSubview:logoButton];
    
    UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [homeButton setFrame:CGRectMake(56, 108, 50, 50)];
    [homeButton addTarget:self action:@selector(backHome:)forControlEvents:UIControlEventTouchUpInside];
    homeButton.showsTouchWhenHighlighted = YES;
    homeButton.tag = 80;
    [homeButton setBackgroundImage:[UIImage imageNamed:@"btn-back.png"] forState:UIControlStateNormal];
    [self.view addSubview:homeButton];
    
    //the following two views add a button for navigation back to the dashboard
    UIView *dashboardBackground = [[UIView alloc] initWithFrame:CGRectMake(184, 56, 33, 33)];
    dashboardBackground.backgroundColor = [UIColor blackColor];
    [self.view addSubview:dashboardBackground];
    
    UIButton *dashboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dashboardButton setFrame:CGRectMake(7, 7, 20, 20)];
    [dashboardButton addTarget:self action:@selector(backToDashboard:)forControlEvents:UIControlEventTouchUpInside];
    dashboardButton.showsTouchWhenHighlighted = YES;
    [dashboardButton setBackgroundImage:[UIImage imageNamed:@"cog-wheel"] forState:UIControlStateNormal];
    [dashboardBackground addSubview:dashboardButton];
    
    [self fetchVideoFromLocalDataStore];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark - Parse
- (void)fetchVideoFromLocalDataStore {
    
    //Using Reachability check if there is an internet connection
    //If there is download term data from Parse.com if not query the local datastore for what ever term data exists
    PFQuery *vidQuery = [PFQuery queryWithClassName:@"video"];
    [vidQuery fromLocalDatastore];
    [vidQuery whereKey:@"field_term_reference" equalTo:content.termId];
    [vidQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count > 0) {
                //Create Poster image before video plays
                PFFile *imageFile = objects[0][@"field_poster_image_img"];
                [imageFile getDataInBackgroundWithBlock:^(NSData *imgData, NSError *error) {
                    if (!error) {
                        UIImage *poster = [[UIImage alloc] initWithData:imgData];
                        
                        //Extract the video file name from the rackspace url then build the local path
                        //http://8f2161d9c4589de9f316-5aa980248e6d72557f77fd2618031fcc.r92.cf2.rackcdn.com/videos/BrandMeetsWorld.mp4
                        NSString *videoName = [[objects[0] objectForKey:@"field_video"] componentsSeparatedByString:@"/videos/"][1];
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        NSString *documentsDirectory = [paths objectAtIndex:0];
                        NSString *fullpath = [documentsDirectory stringByAppendingPathComponent:videoName];
                        NSURL *videoURL =[NSURL fileURLWithPath:fullpath];

                        @autoreleasepool {
                            moviePlayerController = nil;
                            moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
                            [moviePlayerController.view setFrame: CGRectMake(0, 0, 952, 696)];
                            moviePlayerController.view.backgroundColor = [UIColor clearColor];
                            moviePlayerController.view.tag = 22;
                            [moviePlayerController prepareToPlay];
                            moviePlayerController.shouldAutoplay = NO;
                            [background addSubview:moviePlayerController.view];
                        }
                        
                        videoPoster = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 952, 696)];
                        [videoPoster setImage:poster];
                        [videoPoster setUserInteractionEnabled:YES];
                        videoPoster.alpha = 1.0f;
                        videoPoster.tag = 50;
                        [background addSubview:videoPoster];
                    }
                    
                    //Start video and fade out poster
                    [UIView animateWithDuration:2.0f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                        [moviePlayerController play];
                        videoPoster.alpha = 0.0;
                    }completion:^(BOOL finished) {
                        
                    }];
                }];
            }
        }
        else {
            NSLog(@"%@", error);
        }
    }];
}

#pragma mark
#pragma mark - Reachability
- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

#pragma mark -
#pragma mark - Navigation
-(void)backHome:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    [self removeEverything];
}

// Send the presenter back to the dashboard
-(void)backToDashboard:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self removeEverything];
}

#pragma mark
#pragma mark - Memory Management
- (void)removeEverything {
    for (UIView *v in [background subviews]) {
        [v removeFromSuperview];
    }
    [moviePlayerController stop];
    [moviePlayerController.view removeFromSuperview];
    moviePlayerController = nil;
}
@end
