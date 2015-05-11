//
//  CaseStudyViewController.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 2/18/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "CaseStudyViewController.h"
#import "OverviewViewController.h"
#import "BrandMeetsWorldViewController.h"
#import "CatagoryViewController.h"
#import "SamplesViewController.h"
#import "VideoViewController.h"
#import "DetailsViewController.h"

#import "LCPCaseStudyMedia.h"
#import "Reachability.h"
#import "NSString+HTML.h"
#import "ParseDownload.h"
#import "SMPageControl.h"
#import <Parse/Parse.h>

@interface CaseStudyViewController ()
@property (strong, nonatomic) UIView *background;
@property (strong, nonatomic) UIScrollView *pageScroll, *mediaColumnScroll;
@property (strong, nonatomic) UIButton *favoriteContentButton;
@property NSMutableArray *nids, *nodeTitles, *casestudyMediaObjects;

@property (strong, nonatomic) LCPCaseStudyMedia *csMedia;
@property (strong, nonatomic) SMPageControl *paginationDots;
@property (strong, nonatomic) ParseDownload *parsedownload;
@end

@implementation CaseStudyViewController

@synthesize nodeId;                             //NSString
@synthesize isIndividualCaseStudy;              //Bool
@synthesize background;                         //UIView
@synthesize pageScroll, mediaColumnScroll;      //UIScrollView
@synthesize favoriteContentButton;              //UIButton
@synthesize nids, nodeTitles, casestudyMediaObjects; //NSMutableArrays

@synthesize csMedia;                             //LCPCaseStudyMedia
@synthesize content;                            //LCPContent
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
    headerLabel.text = @"CASE STUDIES";
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
    casestudyMediaObjects = [NSMutableArray array];
    
    //NSUserDefaults to check if data has been downloaded.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"case_study"] isEqualToString:@"hasData"]) {
        if (content == nil) {
            PFQuery *query = [PFQuery queryWithClassName:@"case_study"];
            [query fromLocalDatastore];
            [query whereKey:@"nid" equalTo:nodeId];
            dispatch_async(dispatch_get_main_queue(), ^{
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        content = [[LCPContent alloc] init];
                        for (PFObject *object in objects) {
                            content.termId = [object objectForKey:@"field_term_reference"];
                            [self fetchCaseStudyMediaFromLocalDataStore];
                            [self fetchCaseTermDataFromLocalDataStore];
                        }
                    }
                }];
            });
        }
        else {
            [self fetchCaseStudyMediaFromLocalDataStore];
        }
    }
    else {
        [self fetchDataFromParse];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    /*if (content.termId == nil) {
        content = [[LCPContent alloc] init];
    }*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma
#pragma mark - Favorite Functionality

//pick the current nid of the content and save it to the NSUserDefault
-(void)setContentAsFavorite:(UIButton *)sender
{
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"contentFavorites"] objectForKey:[NSString stringWithFormat:@"%ld", (long)sender.tag]] == nil){
        [parsedownload addOrRemoveFavoriteNodeID:[nids objectAtIndex:paginationDots.currentPage]
                                       nodeTitle:[nodeTitles objectAtIndex:paginationDots.currentPage]
                                        nodeType:@"Case Study"
                             withAddOrRemoveFlag:YES];
        [sender setBackgroundImage:[UIImage imageNamed:@"ico-fav-active"] forState:UIControlStateNormal];
    }else{
        [parsedownload addOrRemoveFavoriteNodeID:[nids objectAtIndex:paginationDots.currentPage]
                                       nodeTitle:@""
                                        nodeType:@""
                             withAddOrRemoveFlag:NO];
        [sender setBackgroundImage:[UIImage imageNamed:@"ico-fav-inactive"] forState:UIControlStateNormal];
    }
}


//this function updates the button background color to reflect if it is stored as a favorite or not
-(void)updateFavoriteButtonColor
{
    if([nids count] > 0){
        NSString *nid = [NSString stringWithFormat:@"%@", [nids objectAtIndex:paginationDots.currentPage]];
        UIButton *favbutton = (UIButton *)[self.view viewWithTag:[nid integerValue]];
        
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"contentFavorites"] objectForKey:nid] != nil){
            [favbutton setBackgroundImage:[UIImage imageNamed:@"ico-fav-active"] forState:UIControlStateNormal];
        }else{
            [favbutton setBackgroundImage:[UIImage imageNamed:@"ico-fav-inactive"] forState:UIControlStateNormal];
        }
    }
}


#pragma mark
#pragma mark - Parse
- (void)fetchDataFromParse {
    if ([self connected]) {
        PFQuery *query = [PFQuery queryWithClassName:@"case_study"];
        if (isIndividualCaseStudy) {
            [query whereKey:@"nid" equalTo:nodeId];
        }
        else {
            [query whereKey:@"field_term_reference" equalTo:content.termId];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    [PFObject pinAllInBackground:objects block:^(BOOL succeded, NSError *error) {
                        if (!error) {
                            NSUserDefaults *csDefaults = [NSUserDefaults standardUserDefaults];
                            [csDefaults setObject:@"hasData" forKey:@"case_study"];
                            [csDefaults synchronize];
                            
                            NSMutableArray *selectedObjects = [[NSMutableArray alloc] init];
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            for (PFObject *object in objects) {
                                if ([[defaults objectForKey:[object objectForKey:@"nid"]] isEqualToString:@"show"]) {
                                    [selectedObjects addObject:object];
                                }
                            }
                            [self buildCaseStudyView:selectedObjects];
                        }
                    }];
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
    PFQuery *query = [PFQuery queryWithClassName:@"case_study"];
    [query fromLocalDatastore];
    if (isIndividualCaseStudy) {
        [query whereKey:@"nid" equalTo:nodeId];
    }
    else {
        [query whereKey:@"field_term_reference" equalTo:content.termId];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            NSMutableArray *selectedObjects = [[NSMutableArray alloc] init];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            for (PFObject *object in objects) {
                if ([[defaults objectForKey:[object objectForKey:@"nid"]] isEqualToString:@"show"]) {
                    [selectedObjects addObject:object];
                }
                content.termId = [object objectForKey:@"field_term_reference"];
            }
            [self buildCaseStudyView:selectedObjects];
        }];
    });
}

//Query the local datastore to build the views
- (void)fetchCaseStudyMediaFromLocalDataStore {
    //Query the Local Datastore
    PFQuery *query = [PFQuery queryWithClassName:@"case_study_media"];
    [query fromLocalDatastore];
    [query whereKey:@"field_term_reference" equalTo:content.termId];
    dispatch_async(dispatch_get_main_queue(), ^{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                if (objects.count > 0) {
                    [self buildCaseStudyMediaView:objects];
                }
                else {
                    [self fetchDataFromLocalDataStore];
                }
            }
        }];
    });
}

//Query the local datastore to build the views
- (void)fetchCaseTermDataFromLocalDataStore {
    //Query the Local Datastore
    PFQuery *query = [PFQuery queryWithClassName:@"term"];
    [query fromLocalDatastore];
    [query whereKey:@"tid" equalTo:content.termId];
    dispatch_async(dispatch_get_main_queue(), ^{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                for (PFObject *object in objects) {
                    content.lblTitle = object[@"name"];
                }
            }
        }];
    });
}

#pragma mark
#pragma mark - Build Views
- (void)buildCaseStudyView:(NSArray *)objects {
    int x = 24;
    
    for(PFObject *object in objects) {
        
        //add the nid for the object to nid array
        [nids addObject:object[@"nid"]];
        
        //add the node title to be added for
        [nodeTitles addObject:object[@"title"]];

        UIView *caseStudy = [[UIView alloc] initWithFrame:CGRectMake(x, 0, background.bounds.size.width - 48, background.bounds.size.height - 254)];
        [caseStudy setBackgroundColor:[UIColor clearColor]];
        [pageScroll addSubview:caseStudy];
        
        UITextView *title = [[UITextView alloc] initWithFrame:CGRectMake(-2, 53, 141, caseStudy.bounds.size.height - 73)];
        title.editable = NO;
        title.clipsToBounds = YES;
        title.scrollEnabled = NO;
        [title setFont:[UIFont fontWithName:@"Oswald-Bold" size:26.0f]];
        title.textColor = [UIColor blackColor];
        title.backgroundColor = [UIColor clearColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.text = [[object objectForKey:@"title"] uppercaseString];
        [caseStudy addSubview:title];
        
        UIView *bodyColumn = [[UIView alloc] initWithFrame:CGRectMake(173, 53, 556, caseStudy.bounds.size.height - 89)];
        [bodyColumn setBackgroundColor:[UIColor clearColor]];
        [caseStudy addSubview:bodyColumn];

        NSArray *bodyArray = [object objectForKey:@"body"];
        NSMutableDictionary *bodyDict = [[NSMutableDictionary alloc] init];
        bodyDict = bodyArray[1];
        
        UIScrollView *bodyScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 556, 335)];
        [bodyScroll setBackgroundColor:[UIColor clearColor]];
        [bodyColumn addSubview:bodyScroll];

        NSString *temp = [NSString stringWithFormat:@"%@", [bodyDict objectForKey:@"value"]];

        UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 556, 355)];
        myLabel.numberOfLines = 0;
        NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
        style.minimumLineHeight = 22.0f;
        style.maximumLineHeight = 22.0f;
        NSDictionary *attributtes = @{NSParagraphStyleAttributeName : style,};
        myLabel.attributedText = [[NSAttributedString alloc] initWithString:temp.stringByConvertingHTMLToPlainText attributes:attributtes];
        myLabel.font = [UIFont fontWithName:@"AktivGrotesk-Regular" size:19.0];
        [myLabel sizeToFit];
        [bodyScroll addSubview:myLabel];
        
        [bodyScroll setContentSize:CGSizeMake(556, myLabel.frame.size.height)];
        
        UIView *vDivider = [[UIView alloc] initWithFrame:CGRectMake(748, 53, 1, caseStudy.bounds.size.height - 73)];
        [vDivider setBackgroundColor:[UIColor colorWithRed:218.0f/255.0f green:218.0f/255.0f blue:218.0f/255.0f alpha:1.0]];
        [caseStudy addSubview:vDivider];
        
        favoriteContentButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [favoriteContentButton setFrame:CGRectMake(caseStudy.bounds.size.width - 24, 14.5f, 24, 24)];
        [favoriteContentButton addTarget:self action:@selector(setContentAsFavorite:)forControlEvents:UIControlEventTouchUpInside];
        favoriteContentButton.showsTouchWhenHighlighted = YES;
        //[favoriteContentButton setBackgroundImage:[UIImage imageNamed:@"ico-fav-inactive"] forState:UIControlStateNormal];
        [favoriteContentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [favoriteContentButton setTag:[[object objectForKey:@"nid"] integerValue]];
        [caseStudy addSubview:favoriteContentButton];
        
        mediaColumnScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(766, 53, 137, caseStudy.bounds.size.height - 73)];
        [mediaColumnScroll setBackgroundColor:[UIColor clearColor]];
        [caseStudy addSubview:mediaColumnScroll];
        
        int y = 0;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"csMediaTermReferenceId = %@", [object objectForKey:@"field_term_reference"]];
        NSArray *filteredArray = [casestudyMediaObjects filteredArrayUsingPredicate:predicate];
        for (LCPCaseStudyMedia *csm in filteredArray) {
            
            UIButton *csMediaButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [csMediaButton setFrame:CGRectMake(0, y, 137, 80)];
            [csMediaButton addTarget:self action:@selector(showDetails:)forControlEvents:UIControlEventTouchUpInside];
            csMediaButton.showsTouchWhenHighlighted = YES;
            [csMediaButton setBackgroundColor:[UIColor clearColor]];
            [csMediaButton setTag:[csm.csMediaNodeId integerValue]];
            [csMediaButton setBackgroundImage:csm.csMediaThumb forState:UIControlStateNormal];
             
            [mediaColumnScroll addSubview:csMediaButton];
             
            y += 100;
        }
        x += background.bounds.size.width;
        [pageScroll setContentSize:CGSizeMake(background.bounds.size.width * objects.count, 355)];
    }
    
    UIView *hDivider = [[UIView alloc] initWithFrame:CGRectMake(0, background.bounds.size.height - 144, background.bounds.size.width, 1)];
    [hDivider setBackgroundColor:[UIColor colorWithRed:218.0f/255.0f green:218.0f/255.0f blue:218.0f/255.0f alpha:1.0]];
    [background addSubview:hDivider];
    
    if (objects.count > 1) {
        paginationDots = [[SMPageControl alloc] initWithFrame:CGRectMake(0, background.bounds.size.height - 145, background.bounds.size.width, 48)];
        paginationDots.numberOfPages = objects.count;
        paginationDots.backgroundColor = [UIColor clearColor];
        paginationDots.pageIndicatorImage = [UIImage imageNamed:@"ico-dot-inactive-black"];
        paginationDots.currentPageIndicatorImage = [UIImage imageNamed:@"ico-dot-active-black"];
        [background addSubview:paginationDots];
    }

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
    
    UIView *locationIndicator = [[UIView alloc] initWithFrame:CGRectMake((navBar.bounds.size.width / 2) - 80, 0, 80, 5)];
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

- (void)buildCaseStudyMediaView:(NSArray *)objects {

    int __block count = 0;
    for (PFObject *object in objects) {

        PFFile *imageFile = object[@"field_image_img"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [imageFile getDataInBackgroundWithBlock:^(NSData *imgData, NSError *error) {
                if (!error) {
                    csMedia = [[LCPCaseStudyMedia alloc] init];
                    UIImage *btnImg = [[UIImage alloc] initWithData:imgData];
                    
                    NSArray *bodyArray = [object objectForKey:@"body"];
                    NSMutableDictionary *bodyDict = [[NSMutableDictionary alloc] init];
                    bodyDict = bodyArray[1];

                    csMedia.csMediaTitle = object[@"title"];
                    csMedia.csMediaBody = [NSString stringWithFormat:@"%@", [bodyDict objectForKey:@"value"]];
                    csMedia.csMediaNodeId = object[@"nid"];
                    csMedia.csMediaTermReferenceId = object[@"field_term_reference"];
                    csMedia.csMediaImage = btnImg;
                    csMedia.csMediaThumb = [csMedia scaleImages:btnImg withSize:CGSizeMake(137, 80)];
                    
                    //add the case study objects to caseStudyObjects Array
                    [casestudyMediaObjects addObject:csMedia];
                    
                    count++;
                    
                    if (count == objects.count) {
                        [self fetchDataFromLocalDataStore];
                    }
                }
            }];
        });
    }
    
    [mediaColumnScroll setContentSize:CGSizeMake(137, 100 * objects.count)];
}
//this function updates the dots for the current image the the user is on
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = pageScroll.bounds.size.width;
    //display the appropriate dot when scrolled
    NSInteger pageNumber = floor((pageScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    paginationDots.currentPage = pageNumber;
    
    //update the button color
    [self updateFavoriteButtonColor];
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
-(void)backNav:(UIButton *)sender
{
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
    }else if(sender.tag == 2){
        SamplesViewController *svc = (SamplesViewController *)[storyboard instantiateViewControllerWithIdentifier:@"samplesViewController"];
        svc.content = content;
        [self.navigationController pushViewController:svc animated:YES];
        [self removeEverything];
    }else if(sender.tag == 3){
        VideoViewController *vvc = (VideoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"videoViewController"];
        vvc.content = content;
        [self.navigationController pushViewController:vvc animated:YES];
        [self removeEverything];
    }
}

// Send the presenter back to the dashboard
-(void)backToDashboard:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self removeEverything];
}

- (void)showDetails:(UIButton *)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailsViewController *dvc = (DetailsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"detailsViewController"];
    
    PFQuery *query = [PFQuery queryWithClassName:@"case_study_media"];
    [query fromLocalDatastore];
    [query whereKey:@"nid" equalTo:[NSString stringWithFormat:@"%d", sender.tag]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        dvc.contentObject = objects[0];
        [self.navigationController pushViewController:dvc animated:YES];
    }];
}

#pragma mark
#pragma mark - Memory Management
- (void)removeEverything {
    for (UIView *v in [pageScroll subviews]) {
        [v removeFromSuperview];
    }
}
@end
