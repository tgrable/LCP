//
//  BrandMeetsWorldViewController.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 2/11/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "BrandMeetsWorldViewController.h"
#import "CatagoryViewController.h"
#import "Reachability.h"
#import "ParseDownload.h"
#import <Parse/Parse.h>

@interface BrandMeetsWorldViewController ()

@property (strong, nonatomic) Reachability *reachable;
@property (strong, nonatomic) NSString *catagoryId, *catagoryType, *termId;
@property (strong, nonatomic) UIImage *posterImage, *headerImage;
@property (strong, nonatomic) UIView *background;
@property (strong, nonatomic) UIImageView *logo, *overlay;
@property (strong, nonatomic) NSMutableDictionary *posterDict, *headerDict, *teamDict;
@property (nonatomic) MPMoviePlayerController *moviePlayerController;
@property (strong, nonatomic) ParseDownload *parsedownload;

@end

@implementation BrandMeetsWorldViewController
@synthesize reachable;                          //Reachability
@synthesize content;                            //LCPContent
@synthesize catagoryType, catagoryId, termId;   //NSString
@synthesize posterImage, headerImage;           //UIImage
@synthesize background;                         //UIView
@synthesize logo, overlay;                      //UIImageView
@synthesize posterDict, headerDict, teamDict;   //NSMutableDictionary
@synthesize moviePlayerController;              //MPMoviePlayerController
@synthesize parsedownload;                      //ParseDownload

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark
#pragma mark - ViewController Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //This view is independent of any user input and will not change
    //so all data will only need to loaded one time.
    
    posterDict = [[NSMutableDictionary alloc] init];
    headerDict = [[NSMutableDictionary alloc] init];
    teamDict = [[NSMutableDictionary alloc] init];
    
    //UIView 36 pixels smaller than the device bounds used to hold the rest of the view objects
    background = [[UIView alloc] initWithFrame:CGRectMake(36, 36, (self.view.bounds.size.width - (36 * 2)), (self.view.bounds.size.height - (36 * 2)))];
    [background setBackgroundColor:[UIColor lightGrayColor]];
    [background setUserInteractionEnabled:YES];
    [self.view addSubview:background];

    //NSUserDefaults to check if data has been downloaded.
    //If data has been downloaded pull from local datastore
    NSUserDefaults *videoDefaults = [NSUserDefaults standardUserDefaults];
    if ([[videoDefaults objectForKey:@"video"] isEqualToString:@"hasData"]) {
        
        //Get video title from NSUserDefaults whos field_term_reference is 0
        NSArray *videoName = [[videoDefaults objectForKey:@"VideoDataDictionary"] allKeysForObject:@"0"];
        if (videoName.count > 0) {
            //Extract the video file name from the rackspace url then build the local path
            //http://8f2161d9c4589de9f316-5aa980248e6d72557f77fd2618031fcc.r92.cf2.rackcdn.com/videos/BrandMeetsWorld.mp4
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *fullpath = [documentsDirectory stringByAppendingPathComponent:videoName[0]];
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
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
            tapGesture.numberOfTapsRequired = 1;
            
            [background addGestureRecognizer:tapGesture];
        }
    }
    else {
        // TODO: Look into downloading a single video file instead of all videos again
        dispatch_async(dispatch_get_main_queue(), ^{
          [parsedownload downloadVideoFile];
        });
    }

    //Create the poster image overlay after the video player has been added to background
    overlay = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 952, 696)];
    [overlay setBackgroundColor:[UIColor lightGrayColor]];
    [overlay setImage:[UIImage imageNamed:@"bmwposter.png"]];
    [overlay setUserInteractionEnabled:YES];
    overlay.alpha = 1.0;
    [background addSubview:overlay];
    
    //Logo and setting navigation buttons
    UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoButton setFrame:CGRectMake(56, 56, 108, 33)];
    [logoButton addTarget:self action:@selector(hiddenSection:)forControlEvents:UIControlEventTouchUpInside];
    logoButton.showsTouchWhenHighlighted = YES;
    [logoButton setBackgroundImage:[UIImage imageNamed:@"logo.png"] forState:UIControlStateNormal];
    [self.view addSubview:logoButton];
    
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
    
    //NSUserDefaults to check if data has been downloaded.
    //If data has been downloaded pull from local datastore else fetch data from Parse.com
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"term"] isEqualToString:@"hasData"]) {
        [self fetchDataFromLocalDataStore];
    }
    else {
        [self fetchDataFromParse];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark - Parse
- (void)fetchDataFromParse {
    
    //Using Reachability check if there is an internet connection
    //If there is download term data from Parse.com if not query the local datastore for what ever term data exists
    if ([self connected]) {
        PFQuery *query = [PFQuery queryWithClassName:@"term"];
        [query whereKey:@"parent" equalTo:@"0"];
        [query orderByAscending:@"weight"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [PFObject pinAllInBackground:objects block:^(BOOL succeded, NSError *error) {
                        if (!error) {
                            [self buildView:objects];
                            
                            //Once data is downloaded reset NSUserDefault for BrandMeetsWorldData to "hasData"
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            [defaults setObject:@"hasData" forKey:@"BrandMeetsWorldData"];
                            [defaults synchronize];
                        }
                    }];
                });
            }
            else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
    else {
        [self fetchDataFromLocalDataStore];
    }
}

- (void)fetchDataFromLocalDataStore {
    
    // Query the Local Datastore for term data
    PFQuery *query = [PFQuery queryWithClassName:@"term"];
    [query whereKey:@"parent" equalTo:@"0"];
    [query fromLocalDatastore];
    [query orderByAscending:@"weight"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                [self buildView:objects];
            }
        }];
    });
}

#pragma mark
#pragma mark - Build View
- (void)buildView:(NSArray *)objects {
    
    //Create the 3 X 2 grid of navigation buttons
    int count = 0;
    int x = 0, y = -185;
    
    for (PFObject *object in objects) {
        if (count % 2 == 0) {
            x = 528;
            y = y + 205;
        }
        else {
            x = 735;
        }
        
        //Button Image
        PFFile *imageFile = object[@"field_button_image_img"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [imageFile getDataInBackgroundWithBlock:^(NSData *imgData, NSError *error) {
                if (!error) {
                    UIImage *btnImg = [[UIImage alloc] initWithData:imgData];
                    UIButton *tempButton = [self navigationButtons:btnImg andtitle:[object objectForKey:@"name"] andXPos:x andYPos:y andTag:[object objectForKey:@"tid"]];
                    [background addSubview:tempButton];
                }
            }];
        });
        count++;
        
        //Poster Image
        PFFile *posterFile = object[@"field_poster_image_img"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [posterFile getDataInBackgroundWithBlock:^(NSData *posterData, NSError *error) {
                UIImage *posterImg = [[UIImage alloc] initWithData:posterData];
                [posterDict setObject:posterImg forKey:object[@"tid"]];
            }];
        });
        
        //Header Image
        PFFile *headerFile = object[@"field_header_image_img"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [headerFile getDataInBackgroundWithBlock:^(NSData *headerData, NSError *error) {
                UIImage *headerImg = [[UIImage alloc] initWithData:headerData];
                [headerDict setObject:headerImg forKey:object[@"tid"]];
            }];
        });
    }
}

- (void)imageTapped:(UITapGestureRecognizer *)sender
{
    [moviePlayerController play];
    [UIView animateWithDuration:2.0f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        overlay.alpha = 0.0;
    }completion:^(BOOL finished) {
        
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

#pragma mark
#pragma mark - Navigation
- (UIButton *)navigationButtons:(UIImage *)imgData andtitle:(NSString *)buttonTitle andXPos:(int)xpos andYPos:(int)ypos andTag:(NSString *)buttonTag {
    //the grid of buttons
    UIButton *tempButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tempButton setFrame:CGRectMake(xpos, ypos, 197, 197)];
    [tempButton addTarget:self action:@selector(firstLevelNavigationButtonPressed:)forControlEvents:UIControlEventTouchUpInside];
    tempButton.showsTouchWhenHighlighted = YES;
    [tempButton setBackgroundImage:imgData forState:UIControlStateNormal];
    [tempButton setTitle:buttonTitle forState:normal];
    [tempButton setTag:[buttonTag integerValue]];
    [tempButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    return tempButton;
}

- (void)firstLevelNavigationButtonPressed:(UIButton *)sender {    
    //Create LCPContent object and assign catagoryId, imgPoster, and imgHeader properties
    content = [[LCPContent alloc] init];
    content.catagoryId = [NSString stringWithFormat: @"%ld", (long)sender.tag];
    content.imgPoster = [posterDict objectForKey:[NSString stringWithFormat: @"%ld", (long)sender.tag]];
    content.imgHeader = [headerDict objectForKey:[NSString stringWithFormat: @"%ld", (long)sender.tag]];
    
    //Pass LCPContent object to next view UINavigation View Controller
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CatagoryViewController *cvc = (CatagoryViewController *)[storyboard instantiateViewControllerWithIdentifier:@"catagoryViewController"];
    cvc.content = content;
    
    //Stop video and reset poster image alpha to 1.0
    [moviePlayerController stop];
    overlay.alpha = 1.0f;
    
    [self.navigationController pushViewController:cvc animated:YES];
}

- (void)hiddenSection:(UIButton *)sender {
    // TODO: add hidden slide deck.
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
}
@end
