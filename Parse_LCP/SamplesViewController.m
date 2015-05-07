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

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    parsedownload = [[ParseDownload alloc] init];
    
    //First Page Summary View
    background = [[UIView alloc] initWithFrame:CGRectMake(36, 36, 952, 696)];
    [background setBackgroundColor:[UIColor clearColor]];
    [background setUserInteractionEnabled:YES];
    [self.view addSubview:background];
    
    //Logo and setting navigation buttons
    UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoButton setFrame:CGRectMake(60, 6.5f, 70, 23)];
    //[logoButton addTarget:self action:@selector(hiddenSection:)forControlEvents:UIControlEventTouchUpInside];
    logoButton.showsTouchWhenHighlighted = YES;
    [logoButton setBackgroundImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
    [self.view addSubview:logoButton];
    
    UIButton *dashboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dashboardButton setFrame:CGRectMake((self.view.bounds.size.width - 105), 0, 45, 45)];
    [dashboardButton addTarget:self action:@selector(backToDashboard:)forControlEvents:UIControlEventTouchUpInside];
    dashboardButton.showsTouchWhenHighlighted = YES;
    [dashboardButton setBackgroundImage:[UIImage imageNamed:@"ico-settings"] forState:UIControlStateNormal];
    [self.view addSubview:dashboardButton];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake((self.view.bounds.size.width - 170), 0, 45, 45)];
    [backButton addTarget:self action:@selector(backNav:)forControlEvents:UIControlEventTouchUpInside];
    backButton.showsTouchWhenHighlighted = YES;
    backButton.tag = 1;
    [backButton setBackgroundImage:[UIImage imageNamed:@"ico-back"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    
    UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [homeButton setFrame:CGRectMake((self.view.bounds.size.width - 235), 0, 45, 45)];
    [homeButton addTarget:self action:@selector(backNav:)forControlEvents:UIControlEventTouchUpInside];
    homeButton.showsTouchWhenHighlighted = YES;
    homeButton.tag = 0;
    [homeButton setBackgroundImage:[UIImage imageNamed:@"ico-home"] forState:UIControlStateNormal];
    [self.view addSubview:homeButton];
    
    UIImageView *headerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, background.bounds.size.width, 110)];
    headerImgView.image = [UIImage imageNamed:@"hdr-casestudy"];
    [background addSubview:headerImgView];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerImgView.bounds.size.width, 110)];
    [headerLabel setFont:[UIFont fontWithName:@"Oswald-Bold" size:60.0f]];
    headerLabel.textColor = [UIColor whiteColor];
    [headerLabel setNumberOfLines:2];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    headerLabel.text = [NSString stringWithFormat:@"%@ SAMPLES", content.lblTitle];
    [background addSubview:headerLabel];
    
    pageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 110, background.bounds.size.width, background.bounds.size.width - 110)];
    pageScroll.showsHorizontalScrollIndicator = NO;
    pageScroll.showsVerticalScrollIndicator = YES;
    pageScroll.pagingEnabled = YES;
    pageScroll.scrollEnabled = YES;
    pageScroll.delegate = self;
    pageScroll.backgroundColor = [UIColor clearColor];
    [background addSubview:pageScroll];
    
    //array used to hold nids for the current index of the case study
    nids = [NSMutableArray array];
    nodeTitles = [NSMutableArray array];
    sampleObjects = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated {
    //NSUserDefaults to check if data has been downloaded.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"samples"] isEqualToString:@"hasData"]) {
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

#pragma
#pragma mark - Favorite Functionality

//pick the current nid of the content and save it to the NSUserDefault
-(void)setContentAsFavorite:(id)sender
{
    UIButton *favButton = (UIButton *)sender;
    
    NSLog(@"Selected nid %@" , [nids objectAtIndex:caseStudyDots.currentPage]);
    NSLog(@"Selected title %@" , [nodeTitles objectAtIndex:caseStudyDots.currentPage]);
    
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

#pragma mark
#pragma mark - Parse
- (void)fetchDataFromParse {
    
    if ([self connected]) {
        PFQuery *query = [PFQuery queryWithClassName:@"samples"];
        [query whereKey:@"field_term_reference" equalTo:content.termId];
        [query orderByAscending:@"createdAt"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                NSLog(@"objects: %lu", (unsigned long)objects.count);
                if (!error) {
                    [PFObject pinAllInBackground:objects block:^(BOOL succeded, NSError *error) {
                        if (!error) {
                            NSUserDefaults *csDefaults = [NSUserDefaults standardUserDefaults];
                            [csDefaults setObject:@"hasData" forKey:@"samples"];
                            [csDefaults synchronize];
                            
                            NSMutableArray *selectedObjects = [[NSMutableArray alloc] init];
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            for (PFObject *object in objects) {
                                if ([[defaults objectForKey:[object objectForKey:@"nid"]] isEqualToString:@"show"]) {
                                    [selectedObjects addObject:object];
                                }
                            }
                            [self buildSamplesView:selectedObjects];
                        }
                    }];
                }
                else {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        });
    }
    else {
        [self fetchDataFromLocalDataStore];
    }
}

//Query the local datastore to build the views
- (void)fetchDataFromLocalDataStore {
    //Query the Local Datastore
    PFQuery *query = [PFQuery queryWithClassName:@"samples"];
    [query fromLocalDatastore];
    [query whereKey:@"field_term_reference" equalTo:content.termId];
    [query orderByAscending:@"createdAt"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            NSMutableArray *selectedObjects = [[NSMutableArray alloc] init];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            for (PFObject *object in objects) {
                if ([[defaults objectForKey:[object objectForKey:@"nid"]] isEqualToString:@"show"]) {
                    [selectedObjects addObject:object];
                }
            }
            [self buildSamplesView:selectedObjects];
        }];
    });
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = pageScroll.bounds.size.width;
    //display the appropriate dot when scrolled
    NSInteger pageNumber = floor((pageScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    caseStudyDots.currentPage = pageNumber;
    
    //update the button color
    [self updateFavoriteButtonColor];
}

#pragma mark
#pragma mark - Build Views
- (void)buildSamplesView:(NSArray *)objects {
    
    int x = 24, y = 48, count = 1;
    int multiplier = 0;
    
    for (PFObject *object in objects){
        
        //add the nid for the object to nid array
        [nids addObject:object[@"nid"]];
        
        //add the node title to be added for
        [nodeTitles addObject:object[@"title"]];
        
        //add the sample objects to SampleObjects Array
        [sampleObjects addObject:object];
        
        //Sample Image
        PFFile *sampleFile = object[@"field_sample_image_img"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [sampleFile getDataInBackgroundWithBlock:^(NSData *sampleData, NSError *error) {
                
                UIImageView *sample = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 199, 117)];
                
                if ([self fileExistsAtPath:[NSString stringWithFormat:@"%@.png", [self cleanString:[object objectForKey:@"title"]]]]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
                        
                        NSString *pathForFile = [NSString stringWithFormat:@"%@/%@.png", basePath, [self cleanString:[object objectForKey:@"title"]]];
                        
                        UIImage *image = [UIImage imageWithContentsOfFile:pathForFile];
                        [sample setImage:image];
                    });
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [sample setImage:[self createImgThumbnails:sampleData andFileName:[object objectForKey:@"title"]]];
                    });
                }
                
                [sample setUserInteractionEnabled:YES];
                sample.alpha = 1.0;
                sample.tag = 90;
                [pageScroll addSubview:sample];
                
                if([nids count] > 0){
                    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"contentFavorites"] objectForKey:[object objectForKey:@"nid"]] != nil){
                        UIImageView *favItem = [[UIImageView alloc] initWithFrame:CGRectMake(x + 165, 83 + y, 24, 24)];
                        favItem.image = [UIImage imageNamed:@"ico-fav-active"];
                        [pageScroll addSubview:favItem];
                    }
                }
                
                UILabel *sampleTittleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y + 117, 199, 57)];
                [sampleTittleLabel setFont:[UIFont fontWithName:@"Oswald" size:14.0f]];
                sampleTittleLabel.textColor = [UIColor blackColor];
                sampleTittleLabel.numberOfLines = 0;
                sampleTittleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                sampleTittleLabel.backgroundColor = [UIColor clearColor];
                sampleTittleLabel.textAlignment = NSTextAlignmentCenter;
                sampleTittleLabel.text = [object objectForKey:@"title"];
                [pageScroll addSubview:sampleTittleLabel];
                
                UIButton *sampleDetailsButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [sampleDetailsButton setFrame:CGRectMake(x, y, 199, 174)];
                [sampleDetailsButton addTarget:self action:@selector(showDetails:)forControlEvents:UIControlEventTouchUpInside];
                sampleDetailsButton.showsTouchWhenHighlighted = YES;
                [sampleDetailsButton setBackgroundColor:[UIColor clearColor]];
                sampleDetailsButton.tag = count - 1;
                [pageScroll addSubview:sampleDetailsButton];
            }];
        });
        
        if(count % 4 == 0) {
            x = 24, y = 174 + 43;
        }
        else if (count % 8 == 0) {
            multiplier++;
        }
        else {
            x += 235;
        }

        [pageScroll setContentSize:CGSizeMake((background.bounds.size.width * multiplier), 400)];
        count++;
    }
    
    UIView *hDivider = [[UIView alloc] initWithFrame:CGRectMake(0, background.bounds.size.height - 144, background.bounds.size.width, 1)];
    [hDivider setBackgroundColor:[UIColor colorWithRed:218.0f/255.0f green:218.0f/255.0f blue:218.0f/255.0f alpha:1.0]];
    [background addSubview:hDivider];
    
    paginationDots = [[SMPageControl alloc] initWithFrame:CGRectMake(0, background.bounds.size.height - 145, background.bounds.size.width, 48)];
    paginationDots.numberOfPages = multiplier;
    paginationDots.backgroundColor = [UIColor clearColor];
    paginationDots.pageIndicatorImage = [UIImage imageNamed:@"ico-dot-inactive-black"];
    paginationDots.currentPageIndicatorImage = [UIImage imageNamed:@"ico-dot-active-black"];
    [background addSubview:paginationDots];
    
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
    
    //update the button color
    [self updateFavoriteButtonColor];
}

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

- (NSString *)cleanString:(NSString *)stringToClean {
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"/:.''"" ,!@#$%^&*(){}[]+-*"];
    stringToClean = [[stringToClean componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];

    return stringToClean;
}

- (void)saveThumbnailImgToDisk:(UIImage *)imageToSave andFileName:(NSString *)title {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSData *binaryImageData = UIImagePNGRepresentation(imageToSave);
    
    [binaryImageData writeToFile:[basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", title]] atomically:YES];
}

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
- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

#pragma mark -
#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
-(void)backNav:(UIButton *)sender {
    NSArray *array = [self.navigationController viewControllers];
    if (sender.tag == 0) {
        [self.navigationController popToViewController:[array objectAtIndex:2] animated:YES];
    }
    else {
        [self.navigationController popToViewController:[array objectAtIndex:3] animated:YES];
        //[self.navigationController popViewControllerAnimated:YES];
    }
    [self removeEverything];
}

- (void)navigateViewButton:(UIButton *)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if(sender.tag == 0){
        OverviewViewController *dvc = (OverviewViewController *)[storyboard instantiateViewControllerWithIdentifier:@"overviewViewController"];
        dvc.content = content;
        [self.navigationController pushViewController:dvc animated:YES];
        [self removeEverything];
    }else if(sender.tag == 1){
        CaseStudyViewController *cvc = (CaseStudyViewController *)[storyboard instantiateViewControllerWithIdentifier:@"caseStudyViewController"];
        cvc.content = content;
        [self.navigationController pushViewController:cvc animated:YES];
        [self removeEverything];
    }else if(sender.tag == 3){
        VideoViewController *vvc = (VideoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"videoViewController"];
        vvc.content = content;
        [self.navigationController pushViewController:vvc animated:YES];
        [self removeEverything];
    }
}

- (void)showDetails:(UIButton *)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailsViewController *svc = (DetailsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"detailsViewController"];

    PFObject *sampleObject = [sampleObjects objectAtIndex:sender.tag];
    svc.contentObject = sampleObject;
    svc.contentType = @"samples";

    [self.navigationController pushViewController:svc animated:YES];
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
    for (UIView *v in [pageScroll subviews]) {
        [v removeFromSuperview];
    }
}
@end
