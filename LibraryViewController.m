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
#import "PDFViewController.h"
#import "Reachability.h"
#import "SMPageControl.h"
#import "NSString+HTML.h"
#import "UIImage+Resize.h"
#import "ParseDownload.h"
#import <Parse/Parse.h>

@interface LibraryViewController ()
@property (strong, nonatomic) UIView *background, *navBar, *filterSelection;
@property (strong, nonatomic) UIScrollView *pageScroll;
@property (strong, nonatomic) UIPageControl *caseStudyDots;
@property (strong, nonatomic) UIButton *favoriteContentButton;
@property NSMutableArray *nids, *nodeTitles, *sampleObjects, *filterArray;

@property (strong, nonatomic) SMPageControl *paginationDots;
@property (strong, nonatomic) ParseDownload *parsedownload;

@end

@implementation LibraryViewController

@synthesize content;                                        //LCPContent
@synthesize contentType;                                    //NSString
@synthesize background, navBar, filterSelection;            //UIView
@synthesize pageScroll;                                     //UIScrollView
@synthesize caseStudyDots;                                  //UIPageControl
@synthesize favoriteContentButton;                          //UIButton
@synthesize nids, nodeTitles, sampleObjects, filterArray;   //NSMutableArrays

@synthesize paginationDots;                                 //SMPageControll
@synthesize parsedownload;                                  //ParseDownload

- (BOOL)prefersStatusBarHidden {
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
    
    pageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 110, background.bounds.size.width, background.bounds.size.height - 206)];
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
    [allButton addTarget:self action:@selector(filterButtonPressed:)forControlEvents:UIControlEventTouchUpInside];
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
    [super viewWillAppear:animated];
    
    //NSUserDefaults to check if data has been downloaded.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"case_study"] isEqualToString:@"hasData"]) {
        //NSArray *termArray = [NSArray array];
        [self fetchDataFromLocalDataStore:filterArray];
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
                            NSMutableDictionary *lcpLibrary = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lcpContent"] mutableCopy];
                            
                            //Add selected objects the the array
                            for (PFObject *object in objects) {
                                //Add selected objects the the array
                                if ([[lcpLibrary objectForKey:[object objectForKey:@"nid"]] isEqualToString:@"show"]) {
                                    [selectedObjects addObject:object];
                                }
                            }
                            
                            if ([contentType isEqualToString:@"video"]) {
                                [self buildVideosView:selectedObjects];
                            }
                            else {
                                [self buildCaseStudyView:selectedObjects];
                            }
                        }
                    }];
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
            NSMutableDictionary *lcpLibrary = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lcpContent"] mutableCopy];
            
            //Add selected objects the the array
            for (PFObject *object in objects) {
                //Add selected objects the the array
                if ([[lcpLibrary objectForKey:[object objectForKey:@"nid"]] isEqualToString:@"show"]) {
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
    paginationDots.currentPage = pageNumber;
    
    //update the button color
    [self updateFavoriteButtonColor];
}

#pragma mark
#pragma mark - Build Views
- (void)buildVideosView:(NSArray *)objects {
    
    int x = 24, y = 48, count = 1, subcount = 1, totalCount = 1;
    int multiplier = 1, offset = 0;
    
    for (PFObject *object in objects){
        //add the nid for the object to nid array
        [nids addObject:object[@"nid"]];
        
        //add the node title to be added for
        [nodeTitles addObject:object[@"title"]];
        
        //int btntag = ([[object objectForKey:@"field_term_reference"] isEqual:@"N/A"]) ? 0 : [[object objectForKey:@"field_term_reference"] intValue];
        UIButton *detailsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [detailsButton setFrame:CGRectMake(x, y, 199, 117)];
        [detailsButton addTarget:self action:@selector(showVideoDetails:)forControlEvents:UIControlEventTouchUpInside];
        detailsButton.showsTouchWhenHighlighted = YES;
        [detailsButton setBackgroundColor:[UIColor clearColor]];
        [detailsButton setBackgroundImage:[UIImage imageNamed:@"tmb-video"] forState:UIControlStateNormal];
        detailsButton.tag = [[object objectForKey:@"nid"] intValue];
        [pageScroll addSubview:detailsButton];
        
        //Set the favorite icon if content has been favorited
        if([nids count] > 0){
            if([[[NSUserDefaults standardUserDefaults] objectForKey:@"contentFavorites"] objectForKey:[object objectForKey:@"nid"]] != nil){
                UIImageView *favItem = [[UIImageView alloc] initWithFrame:CGRectMake(x + 165, 83 + y, 24, 24)];
                favItem.image = [UIImage imageNamed:@"ico-fav-active"];
                [pageScroll addSubview:favItem];
            }
        }
        
        UILabel *tittleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y + 117, 199, 57)];
        [tittleLabel setFont:[UIFont fontWithName:@"Oswald" size:14.0f]];
        tittleLabel.textColor = [UIColor blackColor];
        tittleLabel.numberOfLines = 0;
        tittleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        tittleLabel.backgroundColor = [UIColor clearColor];
        tittleLabel.textAlignment = NSTextAlignmentCenter;
        tittleLabel.text = [object objectForKey:@"title"];
        [pageScroll addSubview:tittleLabel];
        
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
    
    if (multiplier > 1) {
        paginationDots = [[SMPageControl alloc] initWithFrame:CGRectMake(0, background.bounds.size.height - 145, background.bounds.size.width, 48)];
        paginationDots.numberOfPages = multiplier;
        paginationDots.backgroundColor = [UIColor clearColor];
        paginationDots.pageIndicatorImage = [UIImage imageNamed:@"ico-dot-inactive-black"];
        paginationDots.currentPageIndicatorImage = [UIImage imageNamed:@"ico-dot-active-black"];
        [background addSubview:paginationDots];
    }
    
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
        NSString *bodyString = @"Not Available";
        //NSMutableDictionary *bodyDict = bodyArray[1];
        for(NSDictionary *obj in bodyArray) {
            if ([obj objectForKey:@"value"]) {
                bodyString = [obj objectForKey:@"value"];
                break;
            }
        }

        NSString *temp = [NSString stringWithFormat:@"%@", bodyString];
        UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(39, y + 24, pageScroll.bounds.size.width - 237, 75)];
        myLabel.numberOfLines = 0;
        NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
        style.minimumLineHeight = 19.0f;
        style.maximumLineHeight = 19.0f;
        NSDictionary *attributtes = @{NSParagraphStyleAttributeName : style,};
        myLabel.attributedText = [[NSAttributedString alloc] initWithString:temp.stringByConvertingHTMLToPlainText attributes:attributtes];
        myLabel.font = [UIFont fontWithName:@"AktivGrotesk-Regular" size:16.0];
        myLabel.backgroundColor = [UIColor clearColor];
        myLabel.textColor = [UIColor blackColor];
        [pageScroll addSubview:myLabel];
        
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
    
    [pageScroll setContentSize:CGSizeMake(background.bounds.size.width - 48, 150 * objects.count)];
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
                    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [UIScreen mainScreen].scale > 1) {
                        UIButton *tempButton = [self navigationButtons:btnImg andtitle:[object objectForKey:@"name"] andXPos:x andYPos:15 andTag:[object objectForKey:@"tid"]];
                        [navBar addSubview:tempButton];
                    }
                    else {
                        UIButton *tempButton = [self navigationButtons:[self scaleImages:btnImg withSize:CGSizeMake(65, 65)] andtitle:[object objectForKey:@"name"] andXPos:x andYPos:15 andTag:[object objectForKey:@"tid"]];
                        [navBar addSubview:tempButton];
                    }
                }
            }];
        });

        x += 100;
    }
    
    filterSelection = [[UIView alloc] initWithFrame:CGRectMake((navBar.bounds.size.width / 2) - 342, 0, 80, 5)];
    [filterSelection setBackgroundColor:[UIColor colorWithRed:115.0f/255.0f green:115.0f/255.0f blue:115.0f/255.0f alpha:1.0]];
    [navBar addSubview:filterSelection];
}

- (UIButton *)navigationButtons:(UIImage *)imgData andtitle:(NSString *)buttonTitle andXPos:(int)xpos andYPos:(int)ypos andTag:(NSString *)buttonTag {
    //the grid of buttons
    UIButton *tempButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tempButton setFrame:CGRectMake(xpos, ypos, 65, 65)];
    [tempButton addTarget:self action:@selector(filterButtonPressed:)forControlEvents:UIControlEventTouchUpInside];
    tempButton.showsTouchWhenHighlighted = YES;
    [tempButton setBackgroundImage:imgData forState:UIControlStateNormal];
    [tempButton setTitle:buttonTitle forState:normal];
    [tempButton setTag:[buttonTag integerValue]];
    [tempButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    
    return tempButton;
}

-(void)filterButtonPressed:(UIButton *)sender {
    if (sender.tag == 99) {
        filterArray = [NSMutableArray array];
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
                    filterArray = [NSMutableArray array];
                    [filterArray addObject:[NSString stringWithFormat:@"%ld", (long)sender.tag]];
                    for (PFObject *obj in objects) {
                        [filterArray addObject:[obj objectForKey:@"tid"]];
                    }
                    [self fetchDataFromLocalDataStore:filterArray];
                }
            }];
        });
    }
    if (sender.tag == 44) {
        [filterSelection setFrame:CGRectMake((navBar.bounds.size.width / 2) - 242, 0, 80, 5)];
    }
    else if (sender.tag == 38) {
        [filterSelection setFrame:CGRectMake((navBar.bounds.size.width / 2) - 142, 0, 80, 5)];
    }
    else if (sender.tag == 43) {
        [filterSelection setFrame:CGRectMake((navBar.bounds.size.width / 2) - 42, 0, 80, 5)];
    }
    else if (sender.tag == 40) {
        [filterSelection setFrame:CGRectMake((navBar.bounds.size.width / 2) + 58, 0, 80, 5)];
    }
    else if (sender.tag == 41) {
        [filterSelection setFrame:CGRectMake((navBar.bounds.size.width / 2) + 158, 0, 80, 5)];
    }
    else if (sender.tag == 42) {
        [filterSelection setFrame:CGRectMake((navBar.bounds.size.width / 2) + 258, 0, 80, 5)];
    }
    else {
        [filterSelection setFrame:CGRectMake((navBar.bounds.size.width / 2) - 342, 0, 80, 5)];
    }
    
    [self removeEverything];
}

- (UIImage *)scaleImages:(UIImage *)originalImg withSize:(CGSize)size {
    CGSize destinationSize = size;
    UIGraphicsBeginImageContext(destinationSize);
    [originalImg drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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

-(void)backToDashboard:(id)sender {

    // Send the presenter back to the dashboard
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