//
//  VideoLibraryViewController.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 5/5/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "LibraryViewController.h"
#import "VideoViewController.h"
#import "CaseStudyViewController.h"
#import "Reachability.h"
#import "SMPageControl.h"
#import "NSString+HTML.h"
#import "UIImage+Resize.h"
#import "ParseDownload.h"
#import <Parse/Parse.h>

@interface LibraryViewController ()
@property (strong, nonatomic) UIView *background, *navBar;
@property (strong, nonatomic) UIScrollView *pageScroll;
@property (strong, nonatomic) UIPageControl *caseStudyDots;
@property (strong, nonatomic) UIButton *favoriteContentButton;

@property NSMutableArray *nids, *nodeTitles, *sampleObjects;

@property (strong, nonatomic) SMPageControl *paginationDots;
@property (strong, nonatomic) ParseDownload *parsedownload;

@end

@implementation LibraryViewController

@synthesize content;                                        //LCPContent
@synthesize contentType;
@synthesize background, navBar; //UIView
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
    parsedownload = [[ParseDownload alloc] init];
    
    NSString *pageTitle;
    if ([contentType isEqualToString:@"case_study"]) {
        pageTitle = @"Case Study";
    }
    else {
        pageTitle = @"video";
    }

    //First Page Summary View
    background = [[UIView alloc] initWithFrame:CGRectMake(36, 36, self.view.bounds.size.width - (36 * 2), self.view.bounds.size.height - (36 * 2))];
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
    headerImgView.image = [UIImage imageNamed:@"hdr-caseVideo"];
    [background addSubview:headerImgView];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerImgView.bounds.size.width, 110)];
    [headerLabel setFont:[UIFont fontWithName:@"Oswald-Bold" size:60.0f]];
    headerLabel.textColor = [UIColor whiteColor];
    [headerLabel setNumberOfLines:2];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    headerLabel.text = [[NSString stringWithFormat:@"%@ library", pageTitle] uppercaseString];
    [background addSubview:headerLabel];
    
    pageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(24, 110, background.bounds.size.width - 48, background.bounds.size.height - 206)];
    pageScroll.showsHorizontalScrollIndicator = NO;
    pageScroll.showsVerticalScrollIndicator = YES;
    pageScroll.pagingEnabled = YES;
    pageScroll.scrollEnabled = YES;
    pageScroll.delegate = self;
    pageScroll.backgroundColor = [UIColor clearColor];
    [background addSubview:pageScroll];
    
    navBar = [[UIView alloc] initWithFrame:CGRectMake(0, (background.bounds.size.height - 96), background.bounds.size.width, 96)];
    [navBar setBackgroundColor:[UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0]];
    [background addSubview:navBar];
    
    UIButton *allButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [allButton setFrame:CGRectMake((navBar.bounds.size.width / 2) - 332.5, 15, 65, 65)];
    [allButton addTarget:self action:@selector(firstLevelNavigationButtonPressed:)forControlEvents:UIControlEventTouchUpInside];
    allButton.showsTouchWhenHighlighted = YES;
    [allButton setBackgroundImage:[UIImage imageNamed:@"ico-all-filter"] forState:UIControlStateNormal];
    [allButton setTag:99];
    [allButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [navBar addSubview:allButton];

    
    [self fetchTermsFromLocalDataStore];
    
    //array used to hold nids for the current index of the case study
    nids = [NSMutableArray array];
    nodeTitles = [NSMutableArray array];
    sampleObjects = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated {
    //NSUserDefaults to check if data has been downloaded.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"samples"] isEqualToString:@"hasData"]) {
        NSArray *termArray = [NSArray array];
        [self fetchDataFromLocalDataStore:termArray];
        
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
        PFQuery *query = [PFQuery queryWithClassName:@"video"];
        [query orderByAscending:@"createdAt"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    [PFObject pinAllInBackground:objects block:^(BOOL succeded, NSError *error) {
                        if (!error) {
                            NSUserDefaults *csDefaults = [NSUserDefaults standardUserDefaults];
                            [csDefaults setObject:@"hasData" forKey:@"video"];
                            [csDefaults synchronize];
                            
                            NSMutableArray *selectedObjects = [[NSMutableArray alloc] init];
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            for (PFObject *object in objects) {
                                if ([[defaults objectForKey:[object objectForKey:@"nid"]] isEqualToString:@"show"]) {
                                    [selectedObjects addObject:object];
                                }
                            }
                            [self buildVideosView:selectedObjects];
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
        NSArray *termArray = [NSArray array];
        [self fetchDataFromLocalDataStore:termArray];
    }
}

//Query the local datastore to build the views
//- (void)fetchDataFromLocalDataStore:(NSString *)key {
- (void)fetchDataFromLocalDataStore:(NSArray *)termArray {
    //Query the Local Datastore
    PFQuery *query = [PFQuery queryWithClassName:contentType];
    if (termArray.count > 0) {
        //[query whereKey:@"field_term_reference" equalTo:key];
        [query whereKey:@"field_term_reference" containedIn:termArray];
    }
    [query fromLocalDatastore];
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
            if ([contentType isEqualToString:@"video"]) {
                [self buildVideosView:selectedObjects];
            }
            else {
                [self buildCaseStudyView:selectedObjects];
            }
            
        }];
    });
}

- (void)fetchTermsFromLocalDataStore {
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
- (void)buildVideosView:(NSArray *)objects {
    
    int x = 24, y = 48, count = 1;
    int multiplier = 0;
    
    for (PFObject *object in objects){
        
        //add the nid for the object to nid array
        [nids addObject:object[@"nid"]];
        
        //add the node title to be added for
        [nodeTitles addObject:object[@"title"]];
        
        //Sample Image
        PFFile *sampleFile = object[@"field_poster_image_img"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [sampleFile getDataInBackgroundWithBlock:^(NSData *sampleData, NSError *error) {
                
                UIImage *videothumb = [UIImage imageWithData:sampleData];
                UIImageView *sample = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 199, 117)];
                
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [UIScreen mainScreen].scale > 1)
                {
                    NSLog(@"This should be retnia");
                    [sample setImage:videothumb];
                }
                else {
                    NSLog(@"This should be non-retnia");
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
                
                int btntag = ([[object objectForKey:@"field_term_reference"] isEqual:@"N/A"]) ? 0 : [[object objectForKey:@"field_term_reference"] integerValue];
                UIButton *sampleDetailsButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [sampleDetailsButton setFrame:CGRectMake(x, y, 199, 174)];
                [sampleDetailsButton addTarget:self action:@selector(showVideoDetails:)forControlEvents:UIControlEventTouchUpInside];
                sampleDetailsButton.showsTouchWhenHighlighted = YES;
                [sampleDetailsButton setBackgroundColor:[UIColor clearColor]];
                sampleDetailsButton.tag = btntag;
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
    
    //update the button color
    [self updateFavoriteButtonColor];
}

- (void)buildCaseStudyView:(NSArray *)objects {
    int y = 48;
    for (PFObject *object in objects){
        
        //add the nid for the object to nid array
        [nids addObject:object[@"nid"]];
        
        //add the node title to be added for
        [nodeTitles addObject:object[@"title"]];
        
        if([nids count] > 0){
            if([[[NSUserDefaults standardUserDefaults] objectForKey:@"contentFavorites"] objectForKey:[object objectForKey:@"nid"]] != nil){
                UIImageView *favItem = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, 24, 24)];
                favItem.image = [UIImage imageNamed:@"ico-fav-active"];
                [pageScroll addSubview:favItem];
            }
        }
        
        UILabel *casestudyTittleLabel = [[UILabel alloc] initWithFrame:CGRectMake(39, y, pageScroll.bounds.size.width, 24)];
        [casestudyTittleLabel setFont:[UIFont fontWithName:@"Oswald-Bold" size:18.0f]];
        casestudyTittleLabel.textColor = [UIColor blackColor];
        casestudyTittleLabel.numberOfLines = 1;
        casestudyTittleLabel.backgroundColor = [UIColor clearColor];
        casestudyTittleLabel.textAlignment = NSTextAlignmentLeft;
        casestudyTittleLabel.text = [object objectForKey:@"title"];
        [pageScroll addSubview:casestudyTittleLabel];
        
        NSArray *bodyArray = [object objectForKey:@"body"];
        NSMutableDictionary *bodyDict = [[NSMutableDictionary alloc] init];
        bodyDict = bodyArray[1];
        
        NSString *temp = [NSString stringWithFormat:@"%@", [bodyDict objectForKey:@"value"]];
        UITextView *body = [[UITextView alloc] initWithFrame:CGRectMake(33, y + 24, pageScroll.bounds.size.width - 237, 75)];
        body.editable = NO;
        body.clipsToBounds = YES;
        body.font = [UIFont fontWithName:@"AktivGrotesk-Regular" size:16.0f];
        body.backgroundColor = [UIColor clearColor];
        body.scrollEnabled = NO;
        body.textColor = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0];
        body.text = temp.stringByConvertingHTMLToPlainText;
        [pageScroll addSubview:body];
        
        UIButton *viewCaseStudyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [viewCaseStudyButton setFrame:CGRectMake(pageScroll.bounds.size.width - 175, y + 24, 150, 30)];
        [viewCaseStudyButton addTarget:self action:@selector(showCasestudyDetails:)forControlEvents:UIControlEventTouchUpInside];
        viewCaseStudyButton.showsTouchWhenHighlighted = YES;
        [viewCaseStudyButton setBackgroundColor:[UIColor clearColor]];
        viewCaseStudyButton.tag = [[object objectForKey:@"nid"] integerValue];
        [viewCaseStudyButton setBackgroundImage:[UIImage imageNamed:@"btn-view"] forState:UIControlStateNormal];
        [pageScroll addSubview:viewCaseStudyButton];
        
        UIView *hDivider = [[UIView alloc] initWithFrame:CGRectMake(39, y + 117, pageScroll.bounds.size.width, 1)];
        [hDivider setBackgroundColor:[UIColor colorWithRed:218.0f/255.0f green:218.0f/255.0f blue:218.0f/255.0f alpha:1.0]];
        [pageScroll addSubview:hDivider];
        
        y += 147;
    }
    
    [pageScroll setContentSize:CGSizeMake(background.bounds.size.width - 48, 250 * objects.count)];
}

- (void)buildView:(NSArray *)objects {
    int x = (navBar.bounds.size.width / 2) - 232.5;
    
    for (PFObject *object in objects) {
        //Button Image
        PFFile *imageFile = object[@"field_button_image_img"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [imageFile getDataInBackgroundWithBlock:^(NSData *imgData, NSError *error) {
                if (!error) {
                    UIImage *btnImg = [[UIImage alloc] initWithData:imgData];
                    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [UIScreen mainScreen].scale > 1)
                    {
                        NSLog(@"This should be retnia");
                        UIButton *tempButton = [self navigationButtons:btnImg andtitle:[object objectForKey:@"name"] andXPos:x andYPos:15 andTag:[object objectForKey:@"tid"]];
                        [navBar addSubview:tempButton];
                    }
                    else {
                        NSLog(@"This should be non-retnia");
                        UIButton *tempButton = [self navigationButtons:[self scaleImages:btnImg withSize:CGSizeMake(65, 65)] andtitle:[object objectForKey:@"name"] andXPos:x andYPos:15 andTag:[object objectForKey:@"tid"]];
                        [navBar addSubview:tempButton];
                    }
                }
            }];
        });

        x += 100;
    }
}

- (UIButton *)navigationButtons:(UIImage *)imgData andtitle:(NSString *)buttonTitle andXPos:(int)xpos andYPos:(int)ypos andTag:(NSString *)buttonTag {
    //the grid of buttons
    UIButton *tempButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tempButton setFrame:CGRectMake(xpos, ypos, 65, 65)];
    [tempButton addTarget:self action:@selector(firstLevelNavigationButtonPressed:)forControlEvents:UIControlEventTouchUpInside];
    tempButton.showsTouchWhenHighlighted = YES;
    [tempButton setBackgroundImage:imgData forState:UIControlStateNormal];
    [tempButton setTitle:buttonTitle forState:normal];
    [tempButton setTag:[buttonTag integerValue]];
    [tempButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    
    return tempButton;
}

- (UIImage *)scaleImages:(UIImage *)originalImg withSize:(CGSize)size {
    CGSize destinationSize = size;
    UIGraphicsBeginImageContext(destinationSize);
    [originalImg drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
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

-(void)firstLevelNavigationButtonPressed:(UIButton *)sender {
    if (sender.tag == 99) {
        NSArray *termArray = [NSArray array];
        [self fetchDataFromLocalDataStore:termArray];
    }
    else {
        PFQuery *query = [PFQuery queryWithClassName:@"term"];
        [query whereKey:@"parent" equalTo:[NSString stringWithFormat:@"%ld", (long)sender.tag]];
        [query fromLocalDatastore];
        [query orderByAscending:@"weight"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                    [tempArray addObject:[NSString stringWithFormat:@"%ld", (long)sender.tag]];
                    for (PFObject *obj in objects) {
                        [tempArray addObject:[obj objectForKey:@"tid"]];
                    }
                    [self fetchDataFromLocalDataStore:tempArray];
                }
            }];
        });
    }
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

#pragma mark -
#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
-(void)backNav:(UIButton *)sender {
    NSArray *array = [self.navigationController viewControllers];
    if (sender.tag == 0) {
        [self.navigationController popToViewController:[array objectAtIndex:2] animated:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self removeEverything];
}

// Send the presenter back to the dashboard
-(void)backToDashboard:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self removeEverything];
}

- (void)showVideoDetails:(UIButton *)sender {
    NSString *btntag = (sender.tag == 0) ? @"N/A" : [NSString stringWithFormat:@"%ld", (long)sender.tag];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    VideoViewController *vvc = (VideoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"videoViewController"];
    vvc.videoNid = btntag;
    vvc.isFromVideoLibrary = YES;
    
    [self.navigationController pushViewController:vvc animated:YES];
    [self removeEverything];
}

- (void)showCasestudyDetails:(UIButton *)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CaseStudyViewController *cvc = (CaseStudyViewController *)[storyboard instantiateViewControllerWithIdentifier:@"caseStudyViewController"];
    cvc.isIndividualCaseStudy = YES;
    cvc.nodeId = [NSString stringWithFormat:@"%ld", (long)sender.tag];
    
    [self.navigationController pushViewController:cvc animated:YES];
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