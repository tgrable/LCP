//
//  VideoViewController.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 3/31/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "VideoViewController.h"
#import "ParseDownload.h"
#import "Reachability.h"
#import <Parse/Parse.h>

@interface VideoViewController ()

@property (strong, nonatomic) UIView *background;
@property (strong, nonatomic) UIImageView *videoPoster;
@property (nonatomic) MPMoviePlayerController *moviePlayerController;
@property (strong, nonatomic) ParseDownload *parsedownload;
@property (strong, nonatomic) UIButton *favoriteContentButton;
@property NSString *nid, *nodeTitle;

@end

@implementation VideoViewController

@synthesize content;
@synthesize background;
@synthesize videoPoster;
@synthesize moviePlayerController;
@synthesize favoriteContentButton;                   //UIButton
@synthesize parsedownload;                           //ParseDownload
@synthesize nid, nodeTitle;                        //NSMutableArrays

- (void)viewDidLoad {
    [super viewDidLoad];
    
    parsedownload = [[ParseDownload alloc] init];

    //UIView 36 pixels smaller than the device bounds used to hold the rest of the view objects
    background = [[UIView alloc] initWithFrame:CGRectMake(36, 36, (self.view.bounds.size.width - (36 * 2)), (self.view.bounds.size.height - (36 * 2)))];
    [background setBackgroundColor:[UIColor lightGrayColor]];
    [background setUserInteractionEnabled:YES];
    [self.view addSubview:background];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setFrame:CGRectMake(self.view.bounds.size.width - 116, 56, 60, 30)];
    [doneButton addTarget:self action:@selector(backHome:)forControlEvents:UIControlEventTouchUpInside];
    doneButton.showsTouchWhenHighlighted = YES;
    doneButton.tag = 1;
    [doneButton setBackgroundImage:[UIImage imageNamed:@"btn-done-white"] forState:UIControlStateNormal];
    [self.view addSubview:doneButton];
    
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
                nid = [objects[0] objectForKey:@"nid"];
                nodeTitle = [objects[0] objectForKey:@"title"];
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
                        
                        favoriteContentButton = [UIButton buttonWithType:UIButtonTypeCustom];
                        [favoriteContentButton setFrame:CGRectMake((background.bounds.size.width - 124), 20, 24, 24)];
                        [favoriteContentButton addTarget:self action:@selector(setContentAsFavorite:)forControlEvents:UIControlEventTouchUpInside];
                        favoriteContentButton.showsTouchWhenHighlighted = YES;
                        favoriteContentButton.tag = [nid integerValue];
                        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"contentFavorites"] objectForKey:[objects[0] objectForKey:@"nid"]] != nil){
                            [favoriteContentButton setBackgroundImage:[UIImage imageNamed:@"ico-fav-active"] forState:UIControlStateNormal];
                        }else{
                            [favoriteContentButton setBackgroundImage:[UIImage imageNamed:@"ico-fav-inactive"] forState:UIControlStateNormal];
                        }
                        [background addSubview:favoriteContentButton];
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

//pick the current nid of the content and save it to the NSUserDefault
-(void)setContentAsFavorite:(UIButton *)sender
{
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"contentFavorites"] objectForKey:[NSString stringWithFormat:@"%ld", (long)sender.tag]] == nil){
        NSLog(@"YES");
        [parsedownload addOrRemoveFavoriteNodeID:nid
                                       nodeTitle:nodeTitle
                                        nodeType:@"Video"
                             withAddOrRemoveFlag:YES];
        [sender setBackgroundImage:[UIImage imageNamed:@"ico-fav-active"] forState:UIControlStateNormal];
    }else{
        NSLog(@"NO");
        [parsedownload addOrRemoveFavoriteNodeID:nid
                                       nodeTitle:@""
                                        nodeType:@""
                             withAddOrRemoveFlag:NO];
        [sender setBackgroundImage:[UIImage imageNamed:@"ico-fav-inactive"] forState:UIControlStateNormal];
    }
}

//this function updates the button background color to reflect if it is stored as a favorite or not
-(void)updateFavoriteButtonColor
{
    if(nid){
        UIButton *favbutton = (UIButton *)[self.view viewWithTag:[nid integerValue]];
        
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"contentFavorites"] objectForKey:nid] != nil){
            [favbutton setBackgroundImage:[UIImage imageNamed:@"ico-fav-active"] forState:UIControlStateNormal];
        }else{
            [favbutton setBackgroundImage:[UIImage imageNamed:@"ico-fav-inactive"] forState:UIControlStateNormal];
        }
    }
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
