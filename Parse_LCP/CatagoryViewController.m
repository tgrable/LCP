//
//  CatagoryViewController.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 2/11/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "CatagoryViewController.h"
#import "DetailsViewController.h"
#import "MeetTheTeamViewController.h"
#import "TestimonialsViewController.h"
#import "Reachability.h"
#import "SMPageControl.h"
#import "ParseDownload.h"
#import <Parse/Parse.h>

@interface CatagoryViewController () {
    long int index;
}

@property (strong, nonatomic) UIView *background, *pagination;
@property (strong, nonatomic) UIScrollView *navContainer;
@property (strong, nonatomic) UIImageView *logo, *overlay;
@property (strong, nonatomic) NSMutableArray *btnImageArray, *btnTitleArray, *btnTagArray;
@property (strong, nonatomic) NSTimer *time;
@property (nonatomic) MPMoviePlayerController *moviePlayerController;

@property (strong, nonatomic) Reachability *reachable;
@property (strong, nonatomic) SMPageControl *paginationDots;
@property (strong, nonatomic) ParseDownload *parsedownload;
@end

@implementation CatagoryViewController

@synthesize content;                                    //LCPContent
@synthesize background, pagination;                     //UIView
@synthesize navContainer;                               //UIScrollView
@synthesize logo, overlay;                              //UIImageView
@synthesize btnImageArray, btnTitleArray, btnTagArray;  //NSMutableArray
@synthesize time;                                       //NSTimer
@synthesize moviePlayerController;                      //MPMoviePlayerController

@synthesize reachable;                                  //Reachability
@synthesize paginationDots;                             //SMPageControl
@synthesize parsedownload;                              //ParseDownload

- (BOOL)prefersStatusBarHidden
{
    return YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *fonts = [UIFont fontNamesForFamilyName:@"Oswald"];
    NSLog(@"%@", fonts);
    for(NSString *string in fonts){
        NSLog(@"%@", string);
    }

    //This view is dependent on user input but these elements will not change
    //so they will only need to loaded one time.

    //UIView 36 pixels smaller than the device bounds used to hold the rest of the view objects
    background = [[UIView alloc] initWithFrame:CGRectMake(36, 36, (self.view.bounds.size.width - (36 * 2)), (self.view.bounds.size.height - (36 * 2)))];
    [background setBackgroundColor:[UIColor lightGrayColor]];
    [background setUserInteractionEnabled:YES];
    [self.view addSubview:background];

    //Logo and setting navigation buttons
    UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoButton setFrame:CGRectMake(60, 6.5f, 70, 23)];
    [logoButton addTarget:self action:@selector(hiddenSection:)forControlEvents:UIControlEventTouchUpInside];
    logoButton.showsTouchWhenHighlighted = YES;
    [logoButton setBackgroundImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
    [self.view addSubview:logoButton];
    
    //the following two views add a button for navigation back to the dashboard
    UIView *dashboardBackground = [[UIView alloc] initWithFrame:CGRectMake(150, 0, 45, 45)];
    dashboardBackground.backgroundColor = [UIColor whiteColor];
    dashboardBackground.layer.cornerRadius = (45/2);
    dashboardBackground.layer.masksToBounds = YES;
    [self.view addSubview:dashboardBackground];
    
    UIButton *dashboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dashboardButton setFrame:CGRectMake(4.5f, 4.5f, 36, 36)];
    [dashboardButton addTarget:self action:@selector(backToDashboard:)forControlEvents:UIControlEventTouchUpInside];
    dashboardButton.showsTouchWhenHighlighted = YES;
    [dashboardButton setBackgroundImage:[UIImage imageNamed:@"ico-gear"] forState:UIControlStateNormal];
    [dashboardBackground addSubview:dashboardButton];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake((self.view.bounds.size.width - 105), 0, 45, 45)];
    [backButton addTarget:self action:@selector(backHome:)forControlEvents:UIControlEventTouchUpInside];
    backButton.showsTouchWhenHighlighted = YES;
    backButton.tag = 0;
    [backButton setBackgroundImage:[UIImage imageNamed:@"ico-home.png"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
}

- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *videoDefaults = [NSUserDefaults standardUserDefaults];
    if ([[videoDefaults objectForKey:@"video"] isEqualToString:@"hasData"]) {
        //Get video title from NSUserDefaults whos field_term_reference is 0
        NSArray *videoName = [[videoDefaults objectForKey:@"VideoDataDictionary"] allKeysForObject:content.catagoryId];
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
                [moviePlayerController.view setFrame: CGRectMake(0, 0, background.bounds.size.width, background.bounds.size.height)];
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [parsedownload downloadVideoFile:self.view forTerm:content.termId];
        });
    }
    
    //Create the poster image overlay and header image after the video player has been added to background
    overlay = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 952, 696)];
    [overlay setBackgroundColor:[UIColor lightGrayColor]];
    [overlay setImage:content.imgPoster];
    [overlay setUserInteractionEnabled:YES];
    overlay.alpha = 1.0;
    [background addSubview:overlay];
    
    navContainer = [[UIScrollView alloc] initWithFrame:CGRectMake((background.bounds.size.width - (320 + 24)), 30, 320, background.bounds.size.height - 130)];
    [navContainer setBackgroundColor:[UIColor clearColor]];
    navContainer.layer.borderColor = [UIColor whiteColor].CGColor;
    navContainer.layer.borderWidth = 1.0f;
    [navContainer setUserInteractionEnabled:YES];
    navContainer.delegate = self;
    [background addSubview:navContainer];
    
    pagination = [[UIScrollView alloc] initWithFrame:CGRectMake((background.bounds.size.width - (320 + 24)), ((background.bounds.size.height - 100) - 1.0f), 320, 36)];
    [pagination setBackgroundColor:[UIColor clearColor]];
    pagination.layer.borderColor = [UIColor whiteColor].CGColor;
    pagination.layer.borderWidth = 1.0f;
    [pagination setUserInteractionEnabled:YES];
    [background addSubview:pagination];

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
        [query whereKey:@"parent" equalTo:content.catagoryId];
        [query orderByAscending:@"weight"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                [PFObject pinAllInBackground:objects block:^(BOOL succeded, NSError *error) {
                    if (!error) {
                        [self buildView:objects];
                        
                        //Once data is downloaded reset NSUserDefault for BrandMeetsWorldData to "hasData"
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setObject:@"hasData" forKey:@"term"];
                        [defaults synchronize];
                    }
                }];
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
    PFQuery *query = [PFQuery queryWithClassName:@"term"];
    [query fromLocalDatastore];
    [query whereKey:@"parent" equalTo:content.catagoryId];
    [query orderByDescending:@"weight"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self buildView:objects];
        }
    }];
}

//this function updates the dots for the current image the the user is on
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = navContainer.bounds.size.width;
    //display the appropriate dot when scrolled
    NSInteger pageNumber = floor((navContainer.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    paginationDots.currentPage = pageNumber;
}

#pragma mark
#pragma mark - Build View
- (void)buildView:(NSArray *)objects {
    
    //Create the cascading column of navigation buttons based on weight property
    int count = 0;
    [self createEmptyButtonArrays:objects.count];
    
    if (objects.count > 8) {
        paginationDots = [[SMPageControl alloc] initWithFrame:CGRectMake(0, 0, 320, 36)];
        paginationDots.numberOfPages = 2;
        paginationDots.pageIndicatorImage = [UIImage imageNamed:@"ico-dot-inactive-white"];
        paginationDots.currentPageIndicatorImage = [UIImage imageNamed:@"ico-dot-active-white"];
        [pagination addSubview:paginationDots];
        [navContainer setContentSize:CGSizeMake((324 * 2), background.bounds.size.height - 130)];
    }
    
    for (PFObject *object in objects) {
        int weight = [[object objectForKey:@"weight"] intValue];
        [btnTitleArray replaceObjectAtIndex:weight withObject:[object objectForKey:@"name"]];
        [btnTagArray replaceObjectAtIndex:weight withObject:[object objectForKey:@"tid"]];
        
        if (count == (objects.count - 1)) {
            [self timerCountdown];
        }

        count++;
    }
}

//The images get downloaded from the local datastore at different times. The empty array is created and filled with NSNull objects
//so we can insert the button images at specific locations based on the weight.
- (void)createEmptyButtonArrays:(long int)arrayCount {
    btnImageArray = [[NSMutableArray alloc] init];
    btnTitleArray = [[NSMutableArray alloc] init];
    btnTagArray = [[NSMutableArray alloc] init];
    index = (arrayCount - 1);
    
    for(int i = 0; i < arrayCount; i++) {
        [btnImageArray addObject: [NSNull null]];
        [btnTitleArray addObject: [NSNull null]];
        [btnTagArray addObject: [NSNull null]];
    }
}


- (void)imageTapped:(UITapGestureRecognizer *)sender
{
    [moviePlayerController play];
    [UIView animateWithDuration:1.5f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        overlay.alpha = 0.0;
    }completion:^(BOOL finished) {
        
    }];
}

- (void)timerCountdown
{
    time = [NSTimer scheduledTimerWithTimeInterval:0.08 target:self selector:@selector(buildNavigationButtons) userInfo:nil repeats:NO];
}

- (void)buildNavigationButtons {
    long xVal = 20, yVal = index * 54;
    if (index > 7) {
        xVal = (324 + 20);
        yVal = (index - 8) * 54;
    }
    if (![[btnImageArray objectAtIndex:index] isKindOfClass:[NSNull class]] || ![[btnTagArray objectAtIndex:index] isKindOfClass:[NSNull class]] || ![[btnTitleArray objectAtIndex:index] isKindOfClass:[NSNull class]]) {
        UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [customButton setFrame:CGRectMake(20, -40, 280, 44)];
        [customButton addTarget:self action:@selector(navigationButtonClick:)forControlEvents:UIControlEventTouchUpInside];
        customButton.showsTouchWhenHighlighted = YES;
        [customButton setBackgroundColor:[UIColor colorWithRed:115.0f/255.0f green:115.0f/255.0f blue:115.0f/255.0f alpha:1.0]];
        customButton.layer.borderColor = [UIColor whiteColor].CGColor;
        customButton.layer.borderWidth = 1.0f;
        customButton.tag = [[btnTagArray objectAtIndex:index] intValue];
        [customButton setTitle:[[btnTitleArray objectAtIndex:index] uppercaseString] forState:normal];
        [customButton.titleLabel setFont:[UIFont fontWithName:@"Oswald" size:18.0f]];
        [customButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        customButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        customButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [navContainer addSubview:customButton];
        
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            customButton.frame = CGRectMake(xVal, (yVal + 120), 280, 44);
        }completion:^(BOOL finished) {}];
        
        UIView *navHeader = [[UIView alloc] initWithFrame:CGRectMake((background.bounds.size.width - (320 + 24)), 30, 320, 106)];
        [navHeader setBackgroundColor:[UIColor colorWithRed:191.0f/255.0f green:191.0f/255.0f blue:191.0f/255.0f alpha:1.0]];
        navHeader.layer.borderWidth =  1.0f;
        navHeader.layer.borderColor = [UIColor whiteColor].CGColor;
        [background addSubview:navHeader];
        
        UIImageView *header = [[UIImageView alloc] initWithFrame:CGRectMake(20, 14, 80, 80)];
        [header setImage:content.imgIcon];
        [header setUserInteractionEnabled:YES];
        header.alpha = 1.0;
        header.tag = 90;
        [navHeader addSubview:header];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(114, 14, 186, 80)];
        [headerLabel setFont:[UIFont fontWithName:@"Oswald-Bold" size:22.0]];
        headerLabel.textColor = [UIColor blackColor];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.textAlignment = NSTextAlignmentLeft;
        headerLabel.numberOfLines = 0;
        headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
        headerLabel.text = [content.lblMainSectionTitle uppercaseString];
        [navHeader addSubview:headerLabel];
    }
    index--;
    
    if(index < [btnImageArray count]){
        [self timerCountdown];
    }else{
        [time invalidate];
    }
}

#pragma mark
#pragma mark - Navigation
- (void)navigationButtonClick:(UIButton *)sender {
    
    content.termId = [NSString stringWithFormat: @"%ld", (long)sender.tag];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    if ([sender.titleLabel.text rangeOfString:@"Testimonial"].location != NSNotFound) {
        //Pass LCPContent object to next view UINavigation View Controller
        TestimonialsViewController *tvc = (TestimonialsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"testimonialsViewController"];
        tvc.content = content;
        
        //Stop video and reset poster image alpha to 1.0
        [moviePlayerController stop];
        overlay.alpha = 1.0f;
        
        [self.navigationController pushViewController:tvc animated:YES];
    }
    else if ([sender.titleLabel.text rangeOfString:@"TEAM"].location != NSNotFound) {
        //Pass LCPContent object to next view UINavigation View Controller
        MeetTheTeamViewController *mvc = (MeetTheTeamViewController *)[storyboard instantiateViewControllerWithIdentifier:@"meetTheTeamViewController"];
        mvc.content = content;
        
        //Stop video and reset poster image alpha to 1.0
        [moviePlayerController stop];
        overlay.alpha = 1.0f;
        
        [self.navigationController pushViewController:mvc animated:YES];
    }
    else {
        NSLog(@"%@", sender.titleLabel.text);
        //Pass LCPContent object to next view UINavigation View Controller
        DetailsViewController *dvc = (DetailsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"detailsViewController"];
        dvc.content = content;
        
        //Stop video and reset poster image alpha to 1.0
        [moviePlayerController stop];
        overlay.alpha = 1.0f;
        
        [self.navigationController pushViewController:dvc animated:YES];
    }
    [self removeEverything];
}

- (void)backHome:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    [self removeEverything];
}
- (void)hiddenSection:(id)sender {
    
}

// Send the presenter back to the dashboard
-(void)backToDashboard:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self removeEverything];
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
#pragma mark - Memory Management
- (void)removeEverything {
    for (UIView *v in [background subviews]) {
        [v removeFromSuperview];
    }
    [btnImageArray removeAllObjects];
    [btnTitleArray removeAllObjects];
    [btnTagArray removeAllObjects];
}
@end
