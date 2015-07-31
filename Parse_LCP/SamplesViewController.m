//
//  SamplesViewController.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 2/19/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "SamplesViewController.h"
#import "DetailsViewController.h"
#import "OverviewViewController.h"
#import "CaseStudyViewController.h"
#import "VideoViewController.h"
#import "PDFViewController.h"
#import "Reachability.h"
#import "SMPageControl.h"
#import "NSString+HTML.h"
#import "ParseDownload.h"
#import <Parse/Parse.h>

@interface SamplesViewController ()
@property (strong, nonatomic) UIView *background;
@property (strong, nonatomic) UIScrollView *pageScroll;
@property (strong, nonatomic) UIPageControl *caseStudyDots;
@property (strong, nonatomic) UIButton *favoriteContentButton;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property NSMutableArray *nids, *nodeTitles, *sampleObjects;

@property (strong, nonatomic) SMPageControl *paginationDots;
@property (strong, nonatomic) ParseDownload *parsedownload;
@end

@implementation SamplesViewController
@synthesize content;                            //LCPContent
@synthesize background;                         //UIView
@synthesize pageScroll;                         //UIScrollView
@synthesize caseStudyDots;                      //UIPageControl
@synthesize favoriteContentButton;              //UIButton
@synthesize nids, nodeTitles, sampleObjects;    //NSMutableArrays

@synthesize paginationDots;                     //SMPageControll
@synthesize parsedownload;                      //ParseDownload
@synthesize activityIndicator;                  //ActivityIndicator

- (BOOL)prefersStatusBarHidden {
    //Hide status bar
    return YES;
}

#pragma mark -
#pragma mark - ViewController Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    parsedownload = [[ParseDownload alloc] init];
    
    //First Page Summary View
    background = [[UIView alloc] initWithFrame:CGRectMake(36, 36, 952, 696)];
    [background setBackgroundColor:[UIColor clearColor]];
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
    
    //UIButton used to navigate back to CatagoryViewController
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake((self.view.bounds.size.width - 170), 0, 45, 45)];
    [backButton addTarget:self action:@selector(backNav:)forControlEvents:UIControlEventTouchUpInside];
    backButton.showsTouchWhenHighlighted = YES;
    backButton.tag = 1;
    [backButton setBackgroundImage:[UIImage imageNamed:@"ico-back.png"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    
    //UIButton used to navigate back to BrandMeetsWorldViewController
    UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [homeButton setFrame:CGRectMake((self.view.bounds.size.width - 235), 0, 45, 45)];
    [homeButton addTarget:self action:@selector(backNav:)forControlEvents:UIControlEventTouchUpInside];
    homeButton.showsTouchWhenHighlighted = YES;
    homeButton.tag = 0;
    [homeButton setBackgroundImage:[UIImage imageNamed:@"ico-home"] forState:UIControlStateNormal];
    [self.view addSubview:homeButton];
    
    //Navigation Bar content
    UIView *navBar = [[UIView alloc] initWithFrame:CGRectMake(0, (background.bounds.size.height - 96), background.bounds.size.width, 96)];
    [navBar setBackgroundColor:[UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0]];
    [background addSubview:navBar];
    
    UIButton *overviewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [overviewButton setFrame:CGRectMake((navBar.bounds.size.width / 2) - (97.5f + 45), 10, 45, 45)];
    [overviewButton addTarget:self action:@selector(navigateViewButton:)forControlEvents:UIControlEventTouchUpInside];
    overviewButton.showsTouchWhenHighlighted = YES;
    [overviewButton setBackgroundImage:[UIImage imageNamed:@"ico-overview"] forState:UIControlStateNormal];
    [overviewButton setBackgroundColor:[UIColor clearColor]];
    overviewButton.tag = 0;
    [navBar addSubview:overviewButton];
    
    UILabel *overviewLabel = [[UILabel alloc] initWithFrame:CGRectMake((navBar.bounds.size.width / 2) - 160, navBar.bounds.size.height - 32, 80, 32)];
    [overviewLabel setFont:[UIFont fontWithName:@"Oswald" size:12.0]];
    overviewLabel.textColor = [UIColor blackColor];
    overviewLabel.numberOfLines = 1;
    overviewLabel.backgroundColor = [UIColor clearColor];
    overviewLabel.textAlignment = NSTextAlignmentCenter;
    overviewLabel.text = @"OVERVIEW";
    [navBar addSubview:overviewLabel];
    
    UIButton *caseStudiesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [caseStudiesButton setFrame:CGRectMake((navBar.bounds.size.width / 2) - (17.5f + 45), 10, 45, 45)];
    [caseStudiesButton addTarget:self action:@selector(navigateViewButton:)forControlEvents:UIControlEventTouchUpInside];
    caseStudiesButton.showsTouchWhenHighlighted = YES;
    [caseStudiesButton setBackgroundImage:[UIImage imageNamed:@"ico-casestudy2"] forState:UIControlStateNormal];
    caseStudiesButton.tag = 1;
    [navBar addSubview:caseStudiesButton];
    
    UILabel *casestudyLabel = [[UILabel alloc] initWithFrame:CGRectMake((navBar.bounds.size.width / 2) - 80, navBar.bounds.size.height - 32, 80, 32)];
    [casestudyLabel setFont:[UIFont fontWithName:@"Oswald" size:12.0]];
    casestudyLabel.textColor = [UIColor blackColor];
    casestudyLabel.numberOfLines = 1;
    casestudyLabel.backgroundColor = [UIColor clearColor];
    casestudyLabel.textAlignment = NSTextAlignmentCenter;
    casestudyLabel.text = @"CASE STUDIES";
    [navBar addSubview:casestudyLabel];
    
    UIButton *samplesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [samplesButton setFrame:CGRectMake((navBar.bounds.size.width / 2) + 17.5f, 10, 45, 45)];
    [samplesButton addTarget:self action:@selector(navigateViewButton:)forControlEvents:UIControlEventTouchUpInside];
    samplesButton.showsTouchWhenHighlighted = YES;
    [samplesButton setBackgroundImage:[UIImage imageNamed:@"ico-samples"] forState:UIControlStateNormal];
    samplesButton.tag = 2;
    [navBar addSubview:samplesButton];
    
    UILabel *samplesLabel = [[UILabel alloc] initWithFrame:CGRectMake((navBar.bounds.size.width / 2), navBar.bounds.size.height - 32, 80, 32)];
    [samplesLabel setFont:[UIFont fontWithName:@"Oswald" size:12.0]];
    samplesLabel.textColor = [UIColor blackColor];
    samplesLabel.numberOfLines = 1;
    samplesLabel.backgroundColor = [UIColor clearColor];
    samplesLabel.textAlignment = NSTextAlignmentCenter;
    samplesLabel.text = @"SAMPLES";
    [navBar addSubview:samplesLabel];
    
    UIButton *videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [videoButton setFrame:CGRectMake((navBar.bounds.size.width / 2) + 97.5f, 10, 45, 45)];
    [videoButton addTarget:self action:@selector(navigateViewButton:)forControlEvents:UIControlEventTouchUpInside];
    videoButton.showsTouchWhenHighlighted = YES;
    [videoButton setBackgroundImage:[UIImage imageNamed:@"ico-video2"] forState:UIControlStateNormal];
    videoButton.tag = 3;
    [navBar addSubview:videoButton];
    
    UILabel *videosLabel = [[UILabel alloc] initWithFrame:CGRectMake((navBar.bounds.size.width / 2) + 80, navBar.bounds.size.height - 32, 80, 32)];
    [videosLabel setFont:[UIFont fontWithName:@"Oswald" size:12.0]];
    videosLabel.textColor = [UIColor blackColor];
    videosLabel.numberOfLines = 1;
    videosLabel.backgroundColor = [UIColor clearColor];
    videosLabel.textAlignment = NSTextAlignmentCenter;
    videosLabel.text = @"VIDEOS";
    [navBar addSubview:videosLabel];
    
    activityIndicator  = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
    [activityIndicator setCenter:CGPointMake(150, 20)];
    activityIndicator.transform = CGAffineTransformMakeScale(0.65, 0.65);
    [activityIndicator setColor:[UIColor blackColor]];
    [activityIndicator startAnimating];
    activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:activityIndicator];
    
    //Set the color of the location indicator view
    UIView *locationIndicator = [[UIView alloc] initWithFrame:CGRectMake((navBar.bounds.size.width / 2), 0, 80, 5)];
    if ([content.catagoryId isEqualToString:@"38"]) {
        [locationIndicator setBackgroundColor:[UIColor yellowColor]];
    }
    else if ([content.catagoryId isEqualToString:@"40"]) {
        [locationIndicator setBackgroundColor:[UIColor blueColor]];
    }
    else if ([content.catagoryId isEqualToString:@"41"]) {
        [locationIndicator setBackgroundColor:[UIColor purpleColor]];
    }
    else if ([content.catagoryId isEqualToString:@"42"]) {
        [locationIndicator setBackgroundColor:[UIColor greenColor]];
    }
    else if ([content.catagoryId isEqualToString:@"43"]) {
        [locationIndicator setBackgroundColor:[UIColor orangeColor]];
    }
    else if ([content.catagoryId isEqualToString:@"44"]) {
        [locationIndicator setBackgroundColor:[UIColor redColor]];
    }
    else {
        
    }
    [navBar addSubview:locationIndicator];
    
    //array used to hold nids for the current index of the sample
    nids = [NSMutableArray array];
    nodeTitles = [NSMutableArray array];
    sampleObjects = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    //Check if data has been downloaded and pinned to local datastore.
    //If data has been downloaded pull from local datastore
    [self checkLocalDataStoreforData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Favorite Functionality

//pick the current nid of the content and save it to the NSUserDefault
-(void)setContentAsFavorite:(id)sender
{
    UIButton *favButton = (UIButton *)sender;
    
    if(favButton.backgroundColor == [UIColor whiteColor]){
        //add favorite
        [parsedownload addOrRemoveFavoriteNodeID:[nids objectAtIndex:caseStudyDots.currentPage]
                                       nodeTitle:[nodeTitles objectAtIndex:caseStudyDots.currentPage]
                                        nodeType:@"Sample"
                             withAddOrRemoveFlag:YES];
        //update button also
        favoriteContentButton.backgroundColor = [UIColor lightGrayColor];
        [favoriteContentButton setTitle:@"Favorited" forState:UIControlStateNormal];
        
    }else if(favButton.backgroundColor == [UIColor lightGrayColor]){
        //remove favorite
        [parsedownload addOrRemoveFavoriteNodeID:[nids objectAtIndex:caseStudyDots.currentPage]
                                       nodeTitle:@""
                                        nodeType:@""
                             withAddOrRemoveFlag:NO];
        //update button also
        favoriteContentButton.backgroundColor = [UIColor whiteColor];
        [favoriteContentButton setTitle:@"Favorite" forState:UIControlStateNormal];
    }
    
}


//this function updates the button background color to reflect if it is stored as a favorite or not
-(void)updateFavoriteButtonColor
{
    if([nids count] > 0){
        NSString *nid = [NSString stringWithFormat:@"%@", [nids objectAtIndex:caseStudyDots.currentPage]];
        
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"contentFavorites"] objectForKey:nid] != nil){
            favoriteContentButton.backgroundColor = [UIColor lightGrayColor];
            [favoriteContentButton setTitle:@"Favorited" forState:UIControlStateNormal];
        }else{
            favoriteContentButton.backgroundColor = [UIColor whiteColor];
            [favoriteContentButton setTitle:@"Favorite" forState:UIControlStateNormal];
        }
    }
}

#pragma mark -
#pragma mark - Parse
//Query the local datastore to build the views
- (void)checkLocalDataStoreforData {
    PFQuery *query = [PFQuery queryWithClassName:@"samples"];
    [query fromLocalDatastore];
    [query whereKey:@"field_term_reference" equalTo:content.termId];
    [query orderByAscending:@"createdAt"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                if (objects.count > 0) {
                    
                    //Some samples may have be disabled in the app dashboard
                    //Check which one are set to "show" and use those to build the view
                    NSMutableArray *selectedObjects = [[NSMutableArray alloc] init];
                    NSMutableDictionary *lcpSamples = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lcpContent"] mutableCopy];
                    
                    //Add selected objects the the array
                    for (PFObject *object in objects) {
                        //Add selected objects the the array
                        if ([[lcpSamples objectForKey:[object objectForKey:@"nid"]] isEqualToString:@"show"]) {
                            [selectedObjects addObject:object];
                        }
                    }
                    [self buildSamplesView:selectedObjects];
                }
                else {
                    [self fetchDataFromParse];
                }
            }
        }];
    });
}

- (void)fetchDataFromParse {
    
    //Using Reachability check if there is an internet connection
    //If there is download term data from Parse.com if not alert the user there needs to be an internet connection
    if ([self connected]) {
        PFQuery *query = [PFQuery queryWithClassName:@"samples"];
        [query whereKey:@"field_term_reference" equalTo:content.termId];
        [query orderByAscending:@"createdAt"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    [PFObject pinAllInBackground:objects block:^(BOOL succeded, NSError *error) {
                        if (!error) {
                            NSUserDefaults *csDefaults = [NSUserDefaults standardUserDefaults];
                            [csDefaults setObject:@"hasData" forKey:@"samples"];
                            [csDefaults synchronize];
                            
                            //Some samples may have be disabled in the app dashboard
                            //Check which one are set to "show" and use those to build the view
                            NSMutableArray *selectedObjects = [[NSMutableArray alloc] init];
                            NSMutableDictionary *lcpSamples = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lcpContent"] mutableCopy];
                            
                            //Add selected objects the the array
                            for (PFObject *object in objects) {
                                //Add selected objects the the array
                                if ([[lcpSamples objectForKey:[object objectForKey:@"nid"]] isEqualToString:@"show"]) {
                                    [selectedObjects addObject:object];
                                }
                            }
                            [self buildSamplesView:selectedObjects];
                        }
                    }];
                }
                else {
                    NSLog(@"%s [Line %d] -- Error: %@ %@",__PRETTY_FUNCTION__, __LINE__,  error, [error userInfo]);
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = pageScroll.bounds.size.width;
    //display the appropriate dot when scrolled
    NSInteger pageNumber = floor((pageScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    paginationDots.currentPage = pageNumber;
    
    //update the button color
    [self updateFavoriteButtonColor];
}

#pragma mark -
#pragma mark - Build Views
- (void)buildSamplesView:(NSArray *)objects {
    //UIImageView used to hold header image and text
    UIImageView *headerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, background.bounds.size.width, 110)];
    headerImgView.image = [UIImage imageNamed:@"hdr-casestudy"];
    [background addSubview:headerImgView];
    
    //UILabel used to hold header text
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerImgView.bounds.size.width, 110)];
    [headerLabel setFont:[UIFont fontWithName:@"Oswald-Bold" size:60.0f]];
    headerLabel.textColor = [UIColor whiteColor];
    [headerLabel setNumberOfLines:2];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    headerLabel.text = [NSString stringWithFormat:@"%@ SAMPLES", content.lblTitle];
    [background addSubview:headerLabel];

    //UIScrollView used to hold the case study objects
    pageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 110, background.bounds.size.width, background.bounds.size.height - 210)];
    pageScroll.showsHorizontalScrollIndicator = NO;
    pageScroll.showsVerticalScrollIndicator = YES;
    pageScroll.pagingEnabled = YES;
    pageScroll.scrollEnabled = YES;
    pageScroll.delegate = self;
    pageScroll.backgroundColor = [UIColor clearColor];
    [background addSubview:pageScroll];

    int x = 24, y = 48, count = 1, subcount = 1, totalCount = 1;
    int multiplier = 1, offset = 0;
    
    for (PFObject *object in objects){
        
        //add the nid for the object to nid array
        [nids addObject:object[@"nid"]];
        
        //add the node title to be added for
        [nodeTitles addObject:object[@"title"]];
        
        //add the sample objects to SampleObjects Array
        [sampleObjects addObject:object];

        //Sample Image
        //PFFile *sampleFile = object[@"field_image_img"];
        PFFile *sampleFile = object[@"field_sample_image_img"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [sampleFile getDataInBackgroundWithBlock:^(NSData *sampleData, NSError *error) {
                
                //UIButton for sample images
                UIButton *sampleDetailsButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [sampleDetailsButton setFrame:CGRectMake(x, y, 199, 117)];
                [sampleDetailsButton addTarget:self action:@selector(showDetails:)forControlEvents:UIControlEventTouchUpInside];
                sampleDetailsButton.showsTouchWhenHighlighted = YES;
                [sampleDetailsButton setBackgroundColor:[UIColor clearColor]];
                sampleDetailsButton.tag = count - 1;
                
                //If its a retnia device create the image thumb nails from NSData
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [UIScreen mainScreen].scale > 1)
                {
                    [sampleDetailsButton setBackgroundImage:[UIImage imageWithData:sampleData] forState:UIControlStateNormal];
                }
                //Else create a thumb nail image and save it to the device
                else {
                    
                    //If the file already exists load it
                    if ([self fileExistsAtPath:[NSString stringWithFormat:@"%@.png", [self cleanString:[object objectForKey:@"title"]]]]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                            NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
                            
                            NSString *pathForFile = [NSString stringWithFormat:@"%@/%@.png", basePath, [self cleanString:[object objectForKey:@"title"]]];
                            
                            UIImage *image = [UIImage imageWithContentsOfFile:pathForFile];
                            [sampleDetailsButton setBackgroundImage:image forState:UIControlStateNormal];
                        });
                    }
                    //Else create a new thumb nail image, this will be slow
                    else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [sampleDetailsButton setBackgroundImage:[self createImgThumbnails:sampleData andFileName:[object objectForKey:@"title"]] forState:UIControlStateNormal];
                        });
                    }
                }
                [pageScroll addSubview:sampleDetailsButton];
                
                //Set the favorite icon if content has been favorited
                if([nids count] > 0){
                    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"contentFavorites"] objectForKey:[object objectForKey:@"nid"]] != nil){
                        UIImageView *favItem = [[UIImageView alloc] initWithFrame:CGRectMake(x + 165, 83 + y, 24, 24)];
                        favItem.image = [UIImage imageNamed:@"ico-fav-active"];
                        [pageScroll addSubview:favItem];
                    }
                }
                
                //UILabel used to hold the title of the sample
                UILabel *sampleTittleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y + 117, 199, 57)];
                [sampleTittleLabel setFont:[UIFont fontWithName:@"Oswald" size:14.0f]];
                sampleTittleLabel.textColor = [UIColor blackColor];
                sampleTittleLabel.numberOfLines = 0;
                sampleTittleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                sampleTittleLabel.backgroundColor = [UIColor clearColor];
                sampleTittleLabel.textAlignment = NSTextAlignmentCenter;
                sampleTittleLabel.text = [object objectForKey:@"title"];
                [pageScroll addSubview:sampleTittleLabel];
            }];
        });
        
        //Create the four column two row grid with pagination
        if (count < 8) {
            if (subcount < 4) {
                x += 235;
                subcount++;
            }
            else {
                x = 24 + offset, y = 174 + 43;
                subcount = 1;
            }
        }
        else {
            offset += background.bounds.size.width;
            x = offset + 24, y = 48;
            subcount = 1;
            count = 0;
        }
        count++;
        
        if (totalCount > 8) {
            multiplier++;
            totalCount = 1;
        }
        
        totalCount++;

        [pageScroll setContentSize:CGSizeMake((pageScroll.bounds.size.width * multiplier), 400)];
    }
    
    UIView *hDivider = [[UIView alloc] initWithFrame:CGRectMake(0, background.bounds.size.height - 144, background.bounds.size.width, 1)];
    [hDivider setBackgroundColor:[UIColor colorWithRed:218.0f/255.0f green:218.0f/255.0f blue:218.0f/255.0f alpha:1.0]];
    [background addSubview:hDivider];
    
    //If there is more than one page of content add pagination dots
    if (multiplier > 1) {
        paginationDots = [[SMPageControl alloc] initWithFrame:CGRectMake(0, background.bounds.size.height - 145, background.bounds.size.width, 48)];
        paginationDots.numberOfPages = multiplier;
        paginationDots.backgroundColor = [UIColor clearColor];
        paginationDots.pageIndicatorImage = [UIImage imageNamed:@"ico-dot-inactive-black"];
        paginationDots.currentPageIndicatorImage = [UIImage imageNamed:@"ico-dot-active-black"];
        [background addSubview:paginationDots];
    }
   
    //update the button color
    [activityIndicator stopAnimating];
    [self updateFavoriteButtonColor];
}

#pragma mark -
#pragma mark - Thumbnails
//Create thumbnail images
- (UIImage *)createImgThumbnails:(NSData *)originalImgData andFileName:(NSString *)title {
    UIImage *originalImg = [[UIImage alloc] initWithData:originalImgData];
    CGSize destinationSize = CGSizeMake(199, 117);
    UIGraphicsBeginImageContext(destinationSize);
    [originalImg drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self saveThumbnailImgToDisk:newImage andFileName:[self cleanString:title]];
    return newImage;
}

//Clean the image title to create file path name
- (NSString *)cleanString:(NSString *)stringToClean {
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"/:.''"" ,!@#$%^&*(){}[]+-*"];
    stringToClean = [[stringToClean componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];

    return stringToClean;
}

//Save images to disk
- (void)saveThumbnailImgToDisk:(UIImage *)imageToSave andFileName:(NSString *)title {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSData *binaryImageData = UIImagePNGRepresentation(imageToSave);
    
    [binaryImageData writeToFile:[basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", title]] atomically:YES];
}

//Check if the file exists
- (BOOL)fileExistsAtPath:(NSString *)fileName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSString *pathForFile = [NSString stringWithFormat:@"%@/%@", basePath, fileName];
    
    if ([fileManager fileExistsAtPath:pathForFile]){
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark
#pragma mark - Reachability
- (BOOL)connected {
    
    //Check if there is an internet connection
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

#pragma mark -
#pragma mark - Navigation
-(void)backNav:(UIButton *)sender {
    
    //NSArry used to hold all view controllers in the navigation stack
    NSArray *array = [self.navigationController viewControllers];
    
    if (sender.tag == 0) {
        //Send the presenter back to the 2nd view in the stack, BrandMeetsWorldViewController
        [self.navigationController popToViewController:[array objectAtIndex:2] animated:YES];
    }
    else {
        //Send the presenter back to the 3nd view in the stack, CatagoryViewController
        [self.navigationController popToViewController:[array objectAtIndex:3] animated:YES];
    }
    [self removeEverything];
}

-(void)backToDashboard:(id)sender {
    
    // Send the presenter back to the dashboard
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self removeEverything];
}

- (void)navigateViewButton:(UIButton *)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if(sender.tag == 0){
        // Send the presenter to OverviewViewController
        OverviewViewController *ovc = (OverviewViewController *)[storyboard instantiateViewControllerWithIdentifier:@"overviewViewController"];
        ovc.content = content;
        [self.navigationController pushViewController:ovc animated:YES];
        [self removeEverything];
        
    } else if(sender.tag == 1) {
        
        // Send the presenter to CaseStudyViewController
        CaseStudyViewController *cvc = (CaseStudyViewController *)[storyboard instantiateViewControllerWithIdentifier:@"caseStudyViewController"];
        cvc.content = content;
        [self.navigationController pushViewController:cvc animated:YES];
        [self removeEverything];
        
    } else if(sender.tag == 3) {
        
        // Send the presenter to VideoViewController
        VideoViewController *vvc = (VideoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"videoViewController"];
        vvc.content = content;
        [self.navigationController pushViewController:vvc animated:YES];
        [self removeEverything];
    }
}

- (void)showDetails:(UIButton *)sender {
    
    // Send the presenter to DetailsViewController
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailsViewController *svc = (DetailsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"detailsViewController"];

    PFObject *sampleObject = [sampleObjects objectAtIndex:sender.tag];
    svc.contentObject = sampleObject;
    svc.contentType = @"samples";

    [self.navigationController pushViewController:svc animated:YES];
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
    for (UIView *v in [pageScroll subviews]) {
        [v removeFromSuperview];
    }
    [paginationDots removeFromSuperview];
}
@end
