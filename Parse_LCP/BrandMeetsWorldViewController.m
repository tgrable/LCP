//
//  BrandMeetsWorldViewController.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 2/11/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "BrandMeetsWorldViewController.h"
#import "CatagoryViewController.h"
#import "LibraryViewController.h"
#import "PDFViewController.h"
#import "Reachability.h"
#import "SMPageControl.h"
#import "ParseDownload.h"
#import <Parse/Parse.h>

@interface BrandMeetsWorldViewController ()

@property (strong, nonatomic) NSString *catagoryId, *catagoryType, *termId;
@property (strong, nonatomic) UIImage *posterImage, *headerImage;
@property (strong, nonatomic) UIView *background, *pagination;
@property (strong, nonatomic) UIScrollView *navContainer;
@property (strong, nonatomic) UIImageView *overlay;
@property (strong, nonatomic) NSMutableDictionary *posterDict, *headerDict, *teamDict, *iconDict;
@property (nonatomic) MPMoviePlayerController *moviePlayerController;

@property (strong, nonatomic) Reachability *reachable;
@property (strong, nonatomic) SMPageControl *paginationDots;
@property (strong, nonatomic) ParseDownload *parsedownload;

@end

@implementation BrandMeetsWorldViewController

@synthesize catagoryId, catagoryType, termId;               //NSString
@synthesize posterImage, headerImage;                       //UIImage
@synthesize background, pagination;                         //UIView
@synthesize navContainer;                                   //UIScrollView
@synthesize overlay;                                        //UIImageView
@synthesize posterDict, headerDict, teamDict, iconDict;     //NSMutableDictionary
@synthesize moviePlayerController;                          //MPMoviePlayerController

@synthesize content;                                        //LCPContent
@synthesize reachable;                                      //Reachability
@synthesize paginationDots;                                 //SMPageControl
@synthesize parsedownload;                                  //ParseDownload

- (BOOL)prefersStatusBarHidden {
    //Hide status bar
    return YES;
}

#pragma mark
#pragma mark - ViewController Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    //This view is independent of any user input and will not change
    //so all data will only need to loaded one time.
    
    iconDict = [[NSMutableDictionary alloc] init];
    posterDict = [[NSMutableDictionary alloc] init];
    headerDict = [[NSMutableDictionary alloc] init];
    teamDict = [[NSMutableDictionary alloc] init];
    
    //UIView 36 pixels smaller than the device bounds used to hold the rest of the view objects
    background = [[UIView alloc] initWithFrame:CGRectMake(36, 36, (self.view.bounds.size.width - (36 * 2)), (self.view.bounds.size.height - (36 * 2)))];
    [background setBackgroundColor:[UIColor colorWithRed:191.0f/255.0f green:191.0f/255.0f blue:191.0f/255.0f alpha:1.0]];
    [background setUserInteractionEnabled:YES];
    [self.view addSubview:background];
    
    //NSUserDefaults to check if data has been downloaded.
    //If data has been downloaded pull from local datastore
    NSUserDefaults *videoDefaults = [NSUserDefaults standardUserDefaults];
    if ([[videoDefaults objectForKey:@"video"] isEqualToString:@"hasData"]) {
        
        //Get video title from NSUserDefaults whos field_term_reference is 0
        NSArray *videoName = [[videoDefaults objectForKey:@"VideoDataDictionary"] allKeysForObject:@"N/A"];
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
            
            //UITapGesture used to start the video
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
            tapGesture.numberOfTapsRequired = 1;
            [background addGestureRecognizer:tapGesture];
        }
    }
    else {
        //Video has not been downloaded
        dispatch_async(dispatch_get_main_queue(), ^{
            [parsedownload downloadVideoFile:self.view forTerm:@"N/A"];
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
    navContainer = [[UIScrollView alloc] initWithFrame:CGRectMake((background.bounds.size.width - (320 + 24)), 30, 320, (background.bounds.size.height - 130))];
    [navContainer setBackgroundColor:[UIColor colorWithRed:179.0f/255.0f green:179.0f/255.0f blue:179.0f/255.0f alpha:1.0]];
    navContainer.layer.borderColor = [UIColor whiteColor].CGColor;
    navContainer.layer.borderWidth = 1.0f;
    [navContainer setUserInteractionEnabled:YES];
    navContainer.delegate = self;
    [background addSubview:navContainer];
    [navContainer setContentSize:CGSizeMake((320 * 2), (background.bounds.size.height - (36 * 4)))];
    
    //UIScrollView used to hold pagination dots
    pagination = [[UIScrollView alloc] initWithFrame:CGRectMake((background.bounds.size.width - (320 + 24)), ((background.bounds.size.height - 100) - 1.0f), 320, 36)];
    [pagination setBackgroundColor:[UIColor colorWithRed:179.0f/255.0f green:179.0f/255.0f blue:179.0f/255.0f alpha:1.0]];
    pagination.layer.borderColor = [UIColor whiteColor].CGColor;
    pagination.layer.borderWidth = 1.0f;
    [pagination setUserInteractionEnabled:YES];
    [background addSubview:pagination];
    
    paginationDots = [[SMPageControl alloc] initWithFrame:CGRectMake(0, 0, 320, 36)];
    paginationDots.numberOfPages = 2;
    paginationDots.pageIndicatorImage = [UIImage imageNamed:@"ico-dot-inactive-white"];
    paginationDots.currentPageIndicatorImage = [UIImage imageNamed:@"ico-dot-active-white"];
    [pagination addSubview:paginationDots];
    
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
    
    //If content.navigationIcons, content.navigationTerms, content.navigationTids all have data
    //build the view with the content passed in else fetch the data from local datastore or Parse.com
    if (content.navigationIcons != NULL && content.navigationTerms != NULL && content.navigationTids != NULL) {
        [self buildViewWithLCPContentData];
    }
    else {
        //NSUserDefaults used to check if data has been downloaded.
        //If data has been downloaded pull from local datastore else fetch data from Parse.com
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([[defaults objectForKey:@"term"] isEqualToString:@"hasData"]) {
            [self fetchDataFromLocalDataStore];
        }
        else {
            [self fetchDataFromParse];
        }
    }
}

//this function updates the dots for the current image the the user is on
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = navContainer.bounds.size.width;
    //display the appropriate dot when scrolled
    NSInteger pageNumber = floor((navContainer.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    paginationDots.currentPage = pageNumber;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark - Parse
//Query the local datastore to build the views
- (void)fetchDataFromLocalDataStore {

    PFQuery *query = [PFQuery queryWithClassName:@"term"];
    [query whereKey:@"parent" equalTo:@"0"];
    [query fromLocalDatastore];
    [query orderByAscending:@"weight"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                
                //Call buildView: with objects returned from query
                [self buildView:objects];
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
        [query whereKey:@"parent" equalTo:@"0"];
        [query orderByAscending:@"weight"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    [PFObject pinAllInBackground:objects block:^(BOOL succeded, NSError *error) {
                        if (!error) {
                            
                            //Set NSUserDefaults to "hasData" for key "term"
                            NSUserDefaults *csDefaults = [NSUserDefaults standardUserDefaults];
                            [csDefaults setObject:@"hasData" forKey:@"term"];
                            [csDefaults synchronize];
                            
                            //Call buildView: with objects returned from query
                            [self buildView:objects];
                        }
                    }];
                }
            }];
        });
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


#pragma mark
#pragma mark - Build View
- (void)buildViewWithLCPContentData {
    
    //Build the view with the data passed in from the content dashboard
    int count = 0;
    int x = 0, y = -143;
    
    for (int i = 0; i < content.navigationIcons.count; i++) {
        if (count % 2 == 0) {
            x = 30;
            y = y + 178;
        }
        else {
            x = (190);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //Create button image for navigation
            UIButton *tempButton = [self navigationButtons:[content.navigationIcons objectForKey:[NSString stringWithFormat:@"%d", count]]
                                                  andtitle:[content.navigationTerms objectForKey:[NSString stringWithFormat:@"%d", count]]
                                                   andXPos:x
                                                   andYPos:y
                                                    andTag:[content.navigationTids objectForKey:[NSString stringWithFormat:@"%d", count]]];
            [iconDict setObject:[content.navigationIcons objectForKey:[NSString stringWithFormat:@"%d", count]] forKey:[content.navigationTids objectForKey:[NSString stringWithFormat:@"%d", count]]];
            [navContainer addSubview:tempButton];
            
            //UIlabel for navigation
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(x, (y + 114), 100, 42)];
            [title setFont:[UIFont fontWithName:@"Oswald" size:14.0]];
            title.textColor = [UIColor blackColor];
            title.backgroundColor = [UIColor clearColor];
            title.textAlignment = NSTextAlignmentCenter;
            title.numberOfLines = 0;
            title.lineBreakMode = NSLineBreakByWordWrapping;
            title.text = [content.navigationTerms objectForKey:[NSString stringWithFormat:@"%d", count]];
            [navContainer addSubview:title];
        });
        count++;
    }
    [self addLibraryButtons];
}

- (void)buildView:(NSArray *)objects {
    
    //Build the view with data fetched from the local datastore or Parse.com
    //This method is more of a fail safe in case all the term data wasn't loaded in the app dashboard
    int count = 0;
    int x = 0, y = -143;
    
    for (PFObject *object in objects) {
        if (count % 2 == 0) {
            x = 30;
            y = y + 178;
        }
        else {
            x = (190);
        }

        //Button Image
        PFFile *imageFile = object[@"field_button_image_img"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [imageFile getDataInBackgroundWithBlock:^(NSData *imgData, NSError *error) {
                if (!error) {
                    
                    //Create button image for navigation
                    UIImage *btnImg = [[UIImage alloc] initWithData:imgData];
                    [iconDict setObject:btnImg forKey:object[@"tid"]];
                    UIButton *tempButton = [self navigationButtons:btnImg
                                                          andtitle:[object objectForKey:@"name"]
                                                           andXPos:x
                                                           andYPos:y
                                                            andTag:[object objectForKey:@"tid"]];
                    [navContainer addSubview:tempButton];
                    
                    //UIlabel for navigation
                    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(x, (y + 114), 100, 42)];
                    [title setFont:[UIFont fontWithName:@"Oswald" size:14.0]];
                    title.textColor = [UIColor blackColor];
                    title.backgroundColor = [UIColor clearColor];
                    title.textAlignment = NSTextAlignmentCenter;
                    title.numberOfLines = 0;
                    title.lineBreakMode = NSLineBreakByWordWrapping;
                    title.text = [object objectForKey:@"name"];
                    [navContainer addSubview:title];
                }
            }];
        });
        count++;
        
        /*//Poster Image
        PFFile *posterFile = object[@"field_poster_image_img"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [posterFile getDataInBackgroundWithBlock:^(NSData *posterData, NSError *error) {
                UIImage *posterImg = [[UIImage alloc] initWithData:posterData];
                [posterDict setObject:posterImg forKey:object[@"tid"]];
            }];
        });*/
        
        //Header Image
        PFFile *headerFile = object[@"field_header_image_img"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [headerFile getDataInBackgroundWithBlock:^(NSData *headerData, NSError *error) {
                UIImage *headerImg = [[UIImage alloc] initWithData:headerData];
                [headerDict setObject:headerImg forKey:object[@"tid"]];
            }];
        });
    }
    [self addLibraryButtons];
}

- (void)addLibraryButtons {
    //Add video & case study library buttons and labels
    UIButton *videoLibraryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [videoLibraryButton setFrame:CGRectMake((320 + 36), 36, 100, 100)];
    [videoLibraryButton addTarget:self action:@selector(libraryNavigationButtonPressed:)forControlEvents:UIControlEventTouchUpInside];
    videoLibraryButton.showsTouchWhenHighlighted = YES;
    [videoLibraryButton setTag:0];
    [videoLibraryButton setBackgroundColor:[UIColor clearColor]];
    [videoLibraryButton setBackgroundImage:[UIImage imageNamed:@"ico-video"] forState:UIControlStateNormal];
    [navContainer addSubview:videoLibraryButton];
    
    UILabel *videoLibraryLabel = [[UILabel alloc] initWithFrame:CGRectMake((320 + 36), (36 + 118), 100, 41)];
    [videoLibraryLabel setFont:[UIFont fontWithName:@"Oswald" size:14.0]];
    videoLibraryLabel.textColor = [UIColor blackColor];
    videoLibraryLabel.backgroundColor = [UIColor clearColor];
    videoLibraryLabel.textAlignment = NSTextAlignmentCenter;
    videoLibraryLabel.numberOfLines = 0;
    videoLibraryLabel.lineBreakMode = NSLineBreakByWordWrapping;
    videoLibraryLabel.text = @"VIDEO LIBRARY";
    [navContainer addSubview:videoLibraryLabel];
    
    UIButton *caseStudiesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [caseStudiesButton setFrame:CGRectMake((320 + 108 + (36 * 2)), 36, 100, 100)];
    [caseStudiesButton addTarget:self action:@selector(libraryNavigationButtonPressed:)forControlEvents:UIControlEventTouchUpInside];
    caseStudiesButton.showsTouchWhenHighlighted = YES;
    [caseStudiesButton setTag:1];
    [caseStudiesButton setBackgroundColor:[UIColor clearColor]];
    [caseStudiesButton setBackgroundImage:[UIImage imageNamed:@"ico-casestudy"] forState:UIControlStateNormal];
    [navContainer addSubview:caseStudiesButton];
    
    UILabel *caseStudiesLabel = [[UILabel alloc] initWithFrame:CGRectMake((320 + 108 + (36 * 2)), (36 + 118), 100, 41)];
    [caseStudiesLabel setFont:[UIFont fontWithName:@"Oswald" size:14.0]];
    caseStudiesLabel.textColor = [UIColor blackColor];
    caseStudiesLabel.backgroundColor = [UIColor clearColor];
    caseStudiesLabel.textAlignment = NSTextAlignmentCenter;
    caseStudiesLabel.numberOfLines = 0;
    caseStudiesLabel.lineBreakMode = NSLineBreakByWordWrapping;
    caseStudiesLabel.text = @"CASE STUDIES";
    [navContainer addSubview:caseStudiesLabel];
}

#pragma mark
#pragma mark - UITapGestureRecognizer
- (void)imageTapped:(UITapGestureRecognizer *)sender {
    
    //Start the LCP video
    [moviePlayerController play];
    
    //Fade out the overlay poster image
    [UIView animateWithDuration:2.0f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        overlay.alpha = 0.0;
    }completion:^(BOOL finished) {
        
    }];
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
#pragma mark - Navigation
- (UIButton *)navigationButtons:(UIImage *)imgData andtitle:(NSString *)buttonTitle andXPos:(int)xpos andYPos:(int)ypos andTag:(NSString *)buttonTag {
    //the grid of buttons
    UIButton *tempButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tempButton setFrame:CGRectMake(xpos, ypos, 100, 100)];
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
    content.catagoryId = [NSString stringWithFormat: @"%ld", (long)sender.tag];
    content.lblMainSectionTitle = sender.titleLabel.text;
    content.imgIcon = [iconDict objectForKey:[NSString stringWithFormat: @"%ld", (long)sender.tag]];
    //content.imgPoster = [posterDict objectForKey:[NSString stringWithFormat: @"%ld", (long)sender.tag]];
    content.imgHeader = [headerDict objectForKey:[NSString stringWithFormat: @"%ld", (long)sender.tag]];
    
    //Pass LCPContent object to next view UINavigation View Controller
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CatagoryViewController *cvc = (CatagoryViewController *)[storyboard instantiateViewControllerWithIdentifier:@"catagoryViewController"];
    cvc.content = content;
    
    //Stop video and reset poster image alpha to 1.0
    [moviePlayerController stop];
    overlay.alpha = 1.0f;
    
    //Push next view controller into the stack
    [self.navigationController pushViewController:cvc animated:YES];
}

- (void)libraryNavigationButtonPressed:(UIButton *)sender {
    
    //Pass contentType to next view UINavigation View Controller
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LibraryViewController *vvc = (LibraryViewController *)[storyboard instantiateViewControllerWithIdentifier:@"libraryViewController"];
    if (sender.tag == 0) {
        vvc.contentType = @"video";
    }
    else {
        vvc.contentType = @"case_study";
    }

    //Stop video and reset poster image alpha to 1.0
    [moviePlayerController stop];
    overlay.alpha = 1.0f;
    
    //Push next view controller into the stack
    [self.navigationController pushViewController:vvc animated:YES];
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
#pragma mark - Memory Management
- (void)removeEverything {
    for (UIView *v in [background subviews]) {
        [v removeFromSuperview];
    }
    [background removeFromSuperview];
}
@end
