//
//  CatagoryViewController.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 2/11/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "CatagoryViewController.h"
#import "OverviewViewController.h"
#import "MeetTheTeamViewController.h"
#import "TestimonialsViewController.h"
#import "PDFViewController.h"
#import "Reachability.h"
#import "SMPageControl.h"
#import "ParseDownload.h"
#import <Parse/Parse.h>

@interface CatagoryViewController () {
    long int index;
}

@property (strong, nonatomic) UIView *background, *pagination;
@property (strong, nonatomic) UIScrollView *navContainer;
@property (strong, nonatomic) UIImageView *overlay;
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
@synthesize overlay;                                    //UIImageView
@synthesize btnImageArray, btnTitleArray, btnTagArray;  //NSMutableArray
@synthesize time;                                       //NSTimer
@synthesize moviePlayerController;                      //MPMoviePlayerController

@synthesize reachable;                                  //Reachability
@synthesize paginationDots;                             //SMPageControl
@synthesize parsedownload;                              //ParseDownload

- (BOOL)prefersStatusBarHidden {
    //Hide status bar
    return YES;
}

#pragma mark
#pragma mark - ViewController Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"content.catagoryId: %@",content.catagoryId);

    //This view is dependent on user input but these elements will not change
    //so they will only need to loaded one time.

    //UIView 36 pixels smaller than the device bounds used to hold the rest of the view objects
    background = [[UIView alloc] initWithFrame:CGRectMake(36, 36, (self.view.bounds.size.width - (36 * 2)), (self.view.bounds.size.height - (36 * 2)))];
    [background setBackgroundColor:[UIColor lightGrayColor]];
    [background setUserInteractionEnabled:YES];
    [self.view addSubview:background];

    /******** Logo and setting navigation buttons ********/    
    UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoButton setFrame:CGRectMake(60, 6.5f, 70, 23)];
    [logoButton addTarget:self action:@selector(hiddenSection:)forControlEvents:UIControlEventTouchUpInside];
    logoButton.showsTouchWhenHighlighted = YES;
    [logoButton setBackgroundImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
    [self.view addSubview:logoButton];
    
    //UIButton used to navigate back to content dashboard
    UIButton *dashboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dashboardButton setFrame:CGRectMake((self.view.bounds.size.width - 105), 0, 45, 45)];
    [dashboardButton addTarget:self action:@selector(backToDashboard:)forControlEvents:UIControlEventTouchUpInside];
    dashboardButton.showsTouchWhenHighlighted = YES;
    [dashboardButton setBackgroundImage:[UIImage imageNamed:@"ico-settings"] forState:UIControlStateNormal];
    [self.view addSubview:dashboardButton];
    
    //UIButton used to navigate back to BrandMeetsWorldViewController
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake((self.view.bounds.size.width - 170), 0, 45, 45)];
    [backButton addTarget:self action:@selector(backHome:)forControlEvents:UIControlEventTouchUpInside];
    backButton.showsTouchWhenHighlighted = YES;
    backButton.tag = 0;
    [backButton setBackgroundImage:[UIImage imageNamed:@"ico-home.png"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //NSUserDefaults to check if data has been downloaded.
    //If data has been downloaded pull from local datastore
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
            
            //UITapGesture used to start the video
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
            tapGesture.numberOfTapsRequired = 1;
            [background addGestureRecognizer:tapGesture];
        }
    }
    else {
        //Video has not been downloaded
        dispatch_async(dispatch_get_main_queue(), ^{
            [parsedownload downloadVideoFile:self.view forTerm:content.termId];
        });
    }
    
    //Create the poster image overlay after the video player has been added to background
    overlay = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 952, 696)];
    [overlay setBackgroundColor:[UIColor clearColor]];
    [overlay setImage:[UIImage imageNamed:@"poster"]];
    [overlay setUserInteractionEnabled:YES];
    overlay.alpha = 1.0;
    [background addSubview:overlay];
    
    //UIScrollView used to hold navigation icons
    navContainer = [[UIScrollView alloc] initWithFrame:CGRectMake((background.bounds.size.width - (320 + 24)), 30, 320, background.bounds.size.height - 130)];
    [navContainer setBackgroundColor:[UIColor colorWithRed:179.0f/255.0f green:179.0f/255.0f blue:179.0f/255.0f alpha:1.0]];
    navContainer.layer.borderColor = [UIColor whiteColor].CGColor;
    navContainer.layer.borderWidth = 1.0f;
    [navContainer setUserInteractionEnabled:YES];
    navContainer.delegate = self;
    [background addSubview:navContainer];
    
    //UIScrollView used to hold pagination dots
    pagination = [[UIScrollView alloc] initWithFrame:CGRectMake((background.bounds.size.width - (320 + 24)), ((background.bounds.size.height - 100) - 1.0f), 320, 36)];
    [pagination setBackgroundColor:[UIColor colorWithRed:179.0f/255.0f green:179.0f/255.0f blue:179.0f/255.0f alpha:1.0]];
    pagination.layer.borderColor = [UIColor whiteColor].CGColor;
    pagination.layer.borderWidth = 1.0f;
    [pagination setUserInteractionEnabled:YES];
    [background addSubview:pagination];

    //Check if data has been downloaded and pinned to local datastore.
    //If data has been downloaded pull from local datastore
    [self checkLocalDataStoreforData];}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark - Parse
//Query the local datastore to build the views
- (void)checkLocalDataStoreforData {
    PFQuery *query = [PFQuery queryWithClassName:@"term"];
    [query fromLocalDatastore];
    [query whereKey:@"parent" equalTo:content.catagoryId];
    [query orderByDescending:@"weight"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                if (objects.count > 0) {
                    NSLog(@"fetchDataFromLocalDataStore");
                    NSLog(@"objects.count %d", objects.count);
                    [self buildView:objects];
                }
                else {
                    [self fetchDataFromParse];
                    NSLog(@"fetchDataFromParse");
                }
            }
        }];
    });
}

//Query the parse.com to build the views
- (void)fetchDataFromParse {
    
    //Using Reachability check if there is an internet connection
    //If there is download term data from Parse.com if not alert the user there needs to be an internet connection
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
        }];
    }
    else {
        //Alert the user there is no internet connection
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Error"
                                                        message:@"You need an internet connection to download data."
                                                       delegate:self cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
        [alert show];
    }
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
    
    //If there are more than 8 terms build the pagination dots
    if (objects.count > 8) {
        paginationDots = [[SMPageControl alloc] initWithFrame:CGRectMake(0, 0, 320, 36)];
        paginationDots.numberOfPages = 2;
        paginationDots.pageIndicatorImage = [UIImage imageNamed:@"ico-dot-inactive-white"];
        paginationDots.currentPageIndicatorImage = [UIImage imageNamed:@"ico-dot-active-white"];
        [pagination addSubview:paginationDots];
        [navContainer setContentSize:CGSizeMake((324 * 2), background.bounds.size.height - 130)];
    }
    
    //Load the navigation buttons
    for (PFObject *object in objects) {
        int weight = [[object objectForKey:@"weight"] intValue];
        //[btnTitleArray replaceObjectAtIndex:weight withObject:[object objectForKey:@"name"]];
        //[btnTagArray replaceObjectAtIndex:weight withObject:[object objectForKey:@"tid"]];
        [btnTitleArray setObject:[object objectForKey:@"name"] atIndexedSubscript:weight];
        [btnTagArray setObject:[object objectForKey:@"tid"] atIndexedSubscript:weight];
        
        if (count == (objects.count - 1)) {
            [self timerCountdown];
        }
        count++;
    }
}

//The images get downloaded from the local datastore at different times. The empty array is created and filled with NSNull objects
//so we can insert the button images at specific locations based on the weight.
- (void)createEmptyButtonArrays:(long int)arrayCount {
    /*
    btnImageArray = [[NSMutableArray alloc] init];
    btnTitleArray = [[NSMutableArray alloc] init];
    btnTagArray = [[NSMutableArray alloc] init];
    */
    btnImageArray = [NSMutableArray array];
    btnTitleArray = [NSMutableArray array];
    btnTagArray = [NSMutableArray array];
     
    index = (arrayCount - 1);
    
    for(int i = 0; i < arrayCount; i++) {
        [btnImageArray addObject: [NSNull null]];
        [btnTitleArray addObject: [NSNull null]];
        [btnTagArray addObject: [NSNull null]];
    }
}

- (void)timerCountdown {
    time = [NSTimer scheduledTimerWithTimeInterval:0.08 target:self selector:@selector(buildNavigationButtons) userInfo:nil repeats:NO];
}

- (void)buildNavigationButtons {
    
    //Local variables used for the layout of the navigations
    //If there is more than seven move over to the next page.
    long xVal = 20, yVal = index * 54;
    if (index > 7) {
        xVal = (324 + 20);
        yVal = (index - 8) * 54;
    }
    
    
    //Create the navigation buttons
    //if (![[btnImageArray objectAtIndex:index] isKindOfClass:[NSNull class]] || ![[btnTagArray objectAtIndex:index] isKindOfClass:[NSNull class]] || ![[btnTitleArray objectAtIndex:index] isKindOfClass:[NSNull class]]) {
    if (![[btnTagArray objectAtIndex:index] isKindOfClass:[NSNull class]] || ![[btnTitleArray objectAtIndex:index] isKindOfClass:[NSNull class]]) {
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
        
        //Cascading animation
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            customButton.frame = CGRectMake(xVal, (yVal + 120), 280, 44);
        }completion:^(BOOL finished) {}];
        
        //UIView used to hold Header icon and title
        UIView *navHeader = [[UIView alloc] initWithFrame:CGRectMake((background.bounds.size.width - (320 + 24)), 30, 320, 106)];
        [navHeader setBackgroundColor:[UIColor colorWithRed:179.0f/255.0f green:179.0f/255.0f blue:179.0f/255.0f alpha:1.0]];
        navHeader.layer.borderWidth =  1.0f;
        navHeader.layer.borderColor = [UIColor whiteColor].CGColor;
        [background addSubview:navHeader];
        
        //UIImageView used to hold header icon
        UIImageView *header = [[UIImageView alloc] initWithFrame:CGRectMake(20, 14, 80, 80)];
        [header setImage:content.imgIcon];
        [header setUserInteractionEnabled:YES];
        header.alpha = 1.0;
        header.tag = 90;
        [navHeader addSubview:header];
        
        //UIlabel used to hold the title
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
        //Start the timer countdown
        [self timerCountdown];
    }else{
        //Time is invalad
        [time invalidate];
    }
}

#pragma mark
#pragma mark - UITapGestureRecognizer
- (void)imageTapped:(UITapGestureRecognizer *)sender {
    
    //Start the LCP video
    [moviePlayerController play];
    
    //Fade out the overlay poster image
    [UIView animateWithDuration:1.5f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        overlay.alpha = 0.0;
    }completion:^(BOOL finished) {
        
    }];
}

#pragma mark
#pragma mark - Navigation
- (void)navigationButtonClick:(UIButton *)sender {
    
    content.termId = [NSString stringWithFormat: @"%ld", (long)sender.tag];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    if ([sender.titleLabel.text rangeOfString:@"TESTIMONIALS"].location != NSNotFound) {
        
        //Pass LCPContent object to next view UINavigation View Controller
        TestimonialsViewController *tvc = (TestimonialsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"testimonialsViewController"];
        tvc.content = content;
        
        //Stop video and reset poster image alpha to 1.0
        [moviePlayerController stop];
        overlay.alpha = 1.0f;
        
        //Push next view controller into the stack
        [self.navigationController pushViewController:tvc animated:YES];
    }
    else if ([sender.titleLabel.text rangeOfString:@"TEAM"].location != NSNotFound) {
        
        //Pass LCPContent object to next view UINavigation View Controller
        MeetTheTeamViewController *mvc = (MeetTheTeamViewController *)[storyboard instantiateViewControllerWithIdentifier:@"meetTheTeamViewController"];
        mvc.content = content;
        
        //Stop video and reset poster image alpha to 1.0
        [moviePlayerController stop];
        overlay.alpha = 1.0f;
        
        //Push next view controller into the stack
        [self.navigationController pushViewController:mvc animated:YES];
    }
    else {
        
        //Pass LCPContent object to next view UINavigation View Controller
        OverviewViewController *dvc = (OverviewViewController *)[storyboard instantiateViewControllerWithIdentifier:@"overviewViewController"];
        dvc.content = content;
        
        //Stop video and reset poster image alpha to 1.0
        [moviePlayerController stop];
        overlay.alpha = 1.0f;
        
        //Push next view controller into the stack
        [self.navigationController pushViewController:dvc animated:YES];
    }
    
    //Remove everything from the view once you navigate to the new view
    [self removeEverything];
}

- (void)backHome:(id)sender {
    
    // Send the presenter back to the BrandMeetsWorldViewController
    [self.navigationController popViewControllerAnimated:YES];
    [self removeEverything];
}

-(void)backToDashboard:(id)sender {
    
    // Send the presenter back to the dashboard
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self removeEverything];
}

- (void)hiddenSection:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PDFViewController *pvc = (PDFViewController *)[storyboard instantiateViewControllerWithIdentifier:@"pdfViewController"];
    [self.navigationController pushViewController:pvc animated:YES];
}

#pragma mark
#pragma mark - Reachability
- (BOOL)connected {
    
    //Check if there is an internet connection
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

#pragma mark
#pragma mark - Memory Management
- (void)removeEverything {
    
    //Loop through and remove all the views in background
    for (UIView *v in [background subviews]) {
        [v removeFromSuperview];
    }

    //Remove all objects in the three arrays
    [btnImageArray removeAllObjects];
    [btnTitleArray removeAllObjects];
    [btnTagArray removeAllObjects];
}
@end
