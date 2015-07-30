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
#import "PDFViewController.h"

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
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property NSMutableArray *nids, *nodeTitles, *casestudyMediaObjects;
@property NSMutableDictionary *csMediaDict, *csMediaObjectDict;

@property (strong, nonatomic) LCPCaseStudyMedia *csMedia;
@property (strong, nonatomic) SMPageControl *paginationDots;
@property (strong, nonatomic) ParseDownload *parsedownload;
@end

@implementation CaseStudyViewController

@synthesize nodeId;                                 //NSString
@synthesize isIndividualCaseStudy;                  //BOOL
@synthesize background;                             //UIView
@synthesize pageScroll, mediaColumnScroll;          //UIScrollView
@synthesize favoriteContentButton;                  //UIButton
@synthesize nids, nodeTitles, casestudyMediaObjects;//NSMutableArrays
@synthesize csMediaDict, csMediaObjectDict;

@synthesize csMedia;                                //LCPCaseStudyMedia
@synthesize content;                                //LCPContent
@synthesize paginationDots;                         //SMPageControll
@synthesize parsedownload;                          //ParseDownload
@synthesize activityIndicator;                      //ActivityIndicator

- (BOOL)prefersStatusBarHidden {
    //Hide status bar
    return YES;
}

#pragma mark
#pragma mark - ViewController Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    casestudyMediaObjects = [NSMutableArray array];
    
    if (content == nil) {
        content = [[LCPContent alloc] init];
    }

    //Check if data has been downloaded and pinned to local datastore.
    //If data has been downloaded pull from local datastore
    [self checkLocalDataStoreforData];
    
    parsedownload = [[ParseDownload alloc] init];
    
    //First Page Summary View
    background = [[UIView alloc] initWithFrame:CGRectMake(36, 36, 952, 696)];
    [background setBackgroundColor:[UIColor clearColor]];
    [background setUserInteractionEnabled:YES];
    [self.view addSubview:background];
    
    //UIImageView used to hold header image and text
    UIImageView *headerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(36, 36, background.bounds.size.width, 110)];
    headerImgView.image = [UIImage imageNamed:@"hdr-casestudy"];
    [self.view addSubview:headerImgView];
    
    //UILabel used to hold header text
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerImgView.bounds.size.width, 110)];
    [headerLabel setFont:[UIFont fontWithName:@"Oswald-Bold" size:60.0f]];
    headerLabel.textColor = [UIColor whiteColor];
    [headerLabel setNumberOfLines:2];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    headerLabel.text = @"CASE STUDIES";
    [headerImgView addSubview:headerLabel];
    
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
    
    if (!isIndividualCaseStudy) {
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
        
        //Set the color of the location indicator view
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
    }
    
    activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.frame = CGRectMake(484.0, 300.0, 35.0, 35.0);
    [activityIndicator setColor:[UIColor blackColor]];
    activityIndicator.alpha = 0.0;
    [activityIndicator startAnimating];
    [self.view addSubview:activityIndicator];
    
    //array used to hold nids for the current index of the case study
    nids = [NSMutableArray array];
    nodeTitles = [NSMutableArray array];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma
#pragma mark - Favorite Functionality

//pick the current nid of the content and save it to the NSUserDefault
-(void)setContentAsFavorite:(UIButton *)sender {
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
- (void)checkLocalDataStoreforData {
    
    csMediaDict = [NSMutableDictionary dictionary];
    
    PFQuery *query = [PFQuery queryWithClassName:@"case_study"];
    if (isIndividualCaseStudy) {
        [query whereKey:@"nid" equalTo:nodeId];
    }
    else {
        [query whereKey:@"field_term_reference" equalTo:content.termId];
    }
    [query fromLocalDatastore];
    //dispatch_async(dispatch_get_main_queue(), ^{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                
                int count = 1;
                BOOL isLast = NO;
                
                for (PFObject *object in objects) {

                    [csMediaDict setObject:[object objectForKey:@"field_case_study_media_reference"] forKey:[object objectForKey:@"nid"]];
                    isLast = (count == objects.count) ? YES : NO;
                    
                    [self fetchCaseStudyMediaFromLocalDataStore:[object objectForKey:@"field_case_study_media_reference"]
                                                  withcsNodeIds:[object objectForKey:@"nid"]
                                                  isLastElement:isLast];
                    
                    count++;
                }
            } else {
                // Log details of the failure
                NSLog(@"%s [Line %d] -- Error: %@ %@",__PRETTY_FUNCTION__, __LINE__,  error, [error userInfo]);
                
            }
        }];
    //});
}


//Query the local datastore for Case_Study_Media to build the views
- (void)fetchCaseStudyMediaFromLocalDataStore:(NSArray *)csMediaNodes withcsNodeIds:(NSString *)csNodeId isLastElement:(BOOL)last {
    csMediaObjectDict = [NSMutableDictionary dictionary];
    NSMutableArray *tempCsMediaArray = [NSMutableArray array];
    
    NSMutableArray *temp = [NSMutableArray array];
    NSArray *bodyArray = csMediaNodes;
    for (NSDictionary *obj in bodyArray) {
        if([obj objectForKey:@"nid"] != nil) {
            [temp addObject:[obj objectForKey:@"nid"]];
        }
    }
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"case_study_media"];
    [query fromLocalDatastore];
    [query whereKey:@"nid" containedIn:temp];
    //dispatch_async(dispatch_get_main_queue(), ^{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                    
                for (PFObject *object in objects) {
                    [tempCsMediaArray addObject:object];
                    [csMediaObjectDict setObject:tempCsMediaArray forKey:csNodeId];
                }
                
                PFQuery *query = [PFQuery queryWithClassName:@"samples"];
                [query fromLocalDatastore];
                [query whereKey:@"nid" containedIn:temp];
                //dispatch_async(dispatch_get_main_queue(), ^{
                    [query findObjectsInBackgroundWithBlock:^(NSArray *sampleobjects, NSError *error) {
                        if (!error) {
                            if (sampleobjects.count > 0) {
                                for (PFObject *sampleobject in sampleobjects) {
                                    [tempCsMediaArray addObject:sampleobject];
                                    [csMediaObjectDict setObject:tempCsMediaArray forKey:csNodeId];
                                }
                            }
                        } else {
                            // Log details of the failure
                            NSLog(@"%s [Line %d] -- Error: %@ %@",__PRETTY_FUNCTION__, __LINE__,  error, [error userInfo]);
                            
                        }
                        
                        
                        if (last) {
                            if ([tempCsMediaArray count] > 0) {
                                [self buildCaseStudyMediaView:tempCsMediaArray complete:^(BOOL completeFlag){
                                    if (completeFlag) {
                                        [self fetchDataFromLocalDataStore];
                                    }
                                }];
                            } else {
                                [self fetchDataFromLocalDataStore];
                            }
                            
                        } else {
                            if ([tempCsMediaArray count] > 0) {
                                [self buildCaseStudyMediaView:tempCsMediaArray complete:^(BOOL completeFlag){}];
                            }
                        }
                    }];
                //});
        
            }
        }];
    //});
}



//Query the local datastore for case_study to build the views
- (void)fetchDataFromLocalDataStore {
    PFQuery *query = [PFQuery queryWithClassName:@"case_study"];
    [query fromLocalDatastore];
    if (isIndividualCaseStudy) {
        [query whereKey:@"nid" equalTo:nodeId];
    }
    else {
        [query whereKey:@"field_term_reference" equalTo:content.termId];
    }
    
    //dispatch_async(dispatch_get_main_queue(), ^{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
          
            if (!error) {
                //Some case studies may have be disabled in the app dashboard
                //Check which one are set to "show" and use those to build the view
                NSMutableArray *selectedObjects = [[NSMutableArray alloc] init];
                NSMutableDictionary *lcpCaseStudy = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lcpContent"] mutableCopy];
                for (PFObject *object in objects) {
                    //Add selected objects the the array
                    if ([[lcpCaseStudy objectForKey:[object objectForKey:@"nid"]] isEqualToString:@"show"]) {
                        [selectedObjects addObject:object];
                    }
                }
                [self buildCaseStudyView:selectedObjects];
            } else {
                // Log details of the failure
                NSLog(@"%s [Line %d] -- Error: %@ %@",__PRETTY_FUNCTION__, __LINE__,  error, [error userInfo]);
                
            }
        }];
    //});
}



#pragma mark
#pragma mark - Build Views
- (void)buildCaseStudyView:(NSArray *)objects {
    //UIScrollView used to hold the case study objects
    if (!isIndividualCaseStudy) {
        pageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 110, background.bounds.size.width, background.bounds.size.height - 210)];
    }
    else {
        pageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 110, background.bounds.size.width, background.bounds.size.height - 160)];
    }
    
    pageScroll.showsHorizontalScrollIndicator = NO;
    pageScroll.showsVerticalScrollIndicator = YES;
    pageScroll.pagingEnabled = YES;
    pageScroll.scrollEnabled = YES;
    pageScroll.delegate = self;
    pageScroll.backgroundColor = [UIColor clearColor];
    [background addSubview:pageScroll];
    
    int x = 24;
    
    for(PFObject *object in objects) {
        //add the nid for the object to nid array
        [nids addObject:object[@"nid"]];
        
        //add the node title to be added for
        [nodeTitles addObject:object[@"title"]];
        
        UIView *caseStudy = [[UIView alloc] init];
        
        //If it's not an individual case study called from the case study library allow room for navigation bar
        if (!isIndividualCaseStudy) {
            [caseStudy setFrame:CGRectMake(x, 0, background.bounds.size.width - 48, background.bounds.size.height - 254)];
        }
        else {
            [caseStudy setFrame:CGRectMake(x, 0, background.bounds.size.width - 48, background.bounds.size.height - 110)];
        }
        [caseStudy setBackgroundColor:[UIColor clearColor]];
        [pageScroll addSubview:caseStudy];
        
        //UILabbel used to hold the case study title
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-2, 53, 141, caseStudy.bounds.size.height - 73)];
        titleLabel.numberOfLines = 0;
        NSMutableParagraphStyle *titleStyle  = [[NSMutableParagraphStyle alloc] init];
        titleStyle.minimumLineHeight = 34.0f;
        titleStyle.maximumLineHeight = 34.0f;
        NSDictionary *titleAttributtes = @{NSParagraphStyleAttributeName : titleStyle,};
        titleLabel.attributedText = [[NSAttributedString alloc] initWithString:[[object objectForKey:@"title"] uppercaseString] attributes:titleAttributtes];
        titleLabel.font = [UIFont fontWithName:@"Oswald-Bold" size:26.0f];
        [titleLabel sizeToFit];
        [caseStudy addSubview:titleLabel];
        
        //Case study body content
        UIView *bodyColumn = [[UIView alloc] initWithFrame:CGRectMake(173, 53, 556, caseStudy.bounds.size.height - 89)];
        [bodyColumn setBackgroundColor:[UIColor clearColor]];
        [caseStudy addSubview:bodyColumn];
        
        NSArray *bodyArray = [object objectForKey:@"body"];
        NSString *bodyString = @"Not Available";
        for(NSDictionary *obj in bodyArray) {
            if ([obj objectForKey:@"value"]) {
                bodyString = [obj objectForKey:@"value"];
                break;
            }
        }
        
        UIScrollView *bodyScroll = [[UIScrollView alloc] init];
        if (!isIndividualCaseStudy) {
            [bodyScroll setFrame:CGRectMake(0, 0, 556, 335)];
        }
        else {
            [bodyScroll setFrame:CGRectMake(0, 0, 556, background.bounds.size.height - 208)];
        }
        [bodyScroll setBackgroundColor:[UIColor clearColor]];
        [bodyColumn addSubview:bodyScroll];
        
        NSString *temp = [NSString stringWithFormat:@"%@", bodyString];
        UILabel *myLabel = [[UILabel alloc] init];
        if (!isIndividualCaseStudy) {
            [myLabel setFrame:CGRectMake(0, 0, 556, 355)];
        }
        else {
            [myLabel setFrame:CGRectMake(0, 0, 556, background.bounds.size.height - 208)];
        }
        myLabel.numberOfLines = 0;
        NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
        style.minimumLineHeight = 22.0f;
        style.maximumLineHeight = 22.0f;
        NSDictionary *attributtes = @{NSParagraphStyleAttributeName : style,};
        myLabel.attributedText = [[NSAttributedString alloc] initWithString:temp.stringByConvertingHTMLToPlainText attributes:attributtes];
        myLabel.font = [UIFont fontWithName:@"AktivGrotesk-Regular" size:19.0];
        [myLabel sizeToFit];
        myLabel.backgroundColor = [UIColor clearColor];
        [bodyScroll addSubview:myLabel];
        
        [bodyScroll setContentSize:CGSizeMake(556, myLabel.frame.size.height)];
        
        UIView *vDivider = [[UIView alloc] initWithFrame:CGRectMake(748, 53, 1, caseStudy.bounds.size.height - 73)];
        [vDivider setBackgroundColor:[UIColor colorWithRed:218.0f/255.0f green:218.0f/255.0f blue:218.0f/255.0f alpha:1.0]];
        [caseStudy addSubview:vDivider];
        
        //UIButton used to set favorite
        favoriteContentButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [favoriteContentButton setFrame:CGRectMake(caseStudy.bounds.size.width - 24, 14.5f, 24, 24)];
        [favoriteContentButton addTarget:self action:@selector(setContentAsFavorite:)forControlEvents:UIControlEventTouchUpInside];
        favoriteContentButton.showsTouchWhenHighlighted = YES;
        [favoriteContentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [favoriteContentButton setTag:[[object objectForKey:@"nid"] integerValue]];
        [caseStudy addSubview:favoriteContentButton];
        
        //Case Study media content
        mediaColumnScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(766, 53, 137, caseStudy.bounds.size.height - 73)];
        [mediaColumnScroll setBackgroundColor:[UIColor clearColor]];
        [caseStudy addSubview:mediaColumnScroll];
        
        // Get the object to grab the nid from it.
        NSArray *tempCSMArray = [object objectForKey:@"field_case_study_media_reference"];
        NSMutableArray *nidArray = [NSMutableArray array];
        
        for (NSDictionary *obj in tempCSMArray) {
            if([obj objectForKey:@"nid"] != nil) {
                [nidArray addObject:[obj objectForKey:@"nid"]];
            }
        }
        
        
        int i = 0;
        if (tempCSMArray.count > 0) {
            int y = 0;
            //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"csMediaTermReferenceId = %@", [object objectForKey:@"field_term_reference"]];
            //NSArray *filteredArray = [casestudyMediaObjects filteredArrayUsingPredicate:predicate];
            
            NSMutableArray *usedArray = [NSMutableArray array];
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"csMediaTitle" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            NSArray *sortedArray = [casestudyMediaObjects sortedArrayUsingDescriptors:sortDescriptors];

            for (LCPCaseStudyMedia *csm in sortedArray) {
                
                if ([nidArray containsObject:csm.csMediaNodeId] && ![usedArray containsObject:csm.csMediaNodeId]) {
                    UIButton *csMediaButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    [csMediaButton setFrame:CGRectMake(0, y, 137, 80)];
                    [csMediaButton addTarget:self action:@selector(showDetails:)forControlEvents:UIControlEventTouchUpInside];
                    csMediaButton.showsTouchWhenHighlighted = YES;
                    [csMediaButton setBackgroundColor:[UIColor clearColor]];
                    
                    // Tim, if there was a way to set whether we are dealing with a sample or case_study_reference then
                    // we could pass this content type as a hidden button title to the showDetails function and use this button
                    // title as query flag.  I looked at what it would take to achieve this and it looks like we have to backup the data lifecycle
                    // all the way to Drupal.  I will leave this up to you
                    
                    //NSLog(@"THE TAG BEING SET TO THE BUTTON: %d WITH THE Y VALUE %d", [csm.csMediaNodeId integerValue], y);
                    [csMediaButton setTag:[csm.csMediaNodeId integerValue]];
                    [csMediaButton setBackgroundImage:csm.csMediaThumb forState:UIControlStateNormal];
                    [mediaColumnScroll addSubview:csMediaButton];
                    
                    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"contentFavorites"] objectForKey:csm.csMediaNodeId] != nil) {
                        UIImageView *favItem = [[UIImageView alloc] initWithFrame:CGRectMake(103, y + 46, 24, 24)];
                        favItem.image = [UIImage imageNamed:@"ico-fav-active"];
                        [mediaColumnScroll addSubview:favItem];
                    }
                    [usedArray addObject:csm.csMediaNodeId];
                    y += 100;
                    i++;
                    [mediaColumnScroll setContentSize:CGSizeMake(137, 100 * tempCSMArray.count)];
                    activityIndicator.alpha = 0.0;
                }
                
            }
        }
        
        x += background.bounds.size.width;
        [pageScroll setContentSize:CGSizeMake(background.bounds.size.width * objects.count, 355)];
    }
    
    //If it's not an individual case study build the navigation bar
    if (!isIndividualCaseStudy) {
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
    }
    activityIndicator.alpha = 0.0;
    //update the button color
    [self updateFavoriteButtonColor];
}

//Create the case study media content items before the rest of the view so
//they will be available when running throught he loop
- (void)buildCaseStudyMediaView:(NSArray *)objects complete:(completeBlock)completeFlag {
    
    activityIndicator.alpha = 1.0;
    
    __block int i = 0;
    for (PFObject *object in objects) {
        
        PFFile *imageFile = object[@"field_image_img"];
        // Attempt to get samples
        if (imageFile == NULL)
            imageFile = object[@"field_sample_image_img"];
        
        if (imageFile != NULL) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [imageFile getDataInBackgroundWithBlock:^(NSData *imgData, NSError *error) {
                    //NSLog(@"Data returned");
                    if (!error) {
                        csMedia = [[LCPCaseStudyMedia alloc] init];
                        UIImage *btnImg = [[UIImage alloc] initWithData:imgData];
                        
                        NSArray *bodyArray = [object objectForKey:@"body"];
                        
                        NSString *bodyString = @"Not Available";
                        //NSMutableDictionary *bodyDict = bodyArray[1];
                        for(NSDictionary *obj in bodyArray) {
                            if ([obj objectForKey:@"value"]) {
                                bodyString = [obj objectForKey:@"value"];
                                //break;
                            }
                        }
                        csMedia.csMediaTitle = object[@"title"];
                        csMedia.csMediaBody = [NSString stringWithFormat:@"%@", bodyString];
                        csMedia.csMediaNodeId = object[@"nid"];
                        csMedia.csMediaTermReferenceId = object[@"field_term_reference"];
                        csMedia.csMediaImage = btnImg;
                        csMedia.csMediaThumb = [csMedia scaleImages:btnImg withSize:CGSizeMake(137, 80)];
                        
                        
                        //add the case study objects to caseStudyObjects Array
                        [casestudyMediaObjects addObject:csMedia];
                        
                        i++;
                        if (i == objects.count) {
                            activityIndicator.alpha = 0.0;
                            completeFlag(YES);
                        }
                        
                    } else {
                        // Log details of the failure
                        NSLog(@"%s [Line %d] -- Error: %@ %@",__PRETTY_FUNCTION__, __LINE__,  error, [error userInfo]);
                    }
                }];
            });
        } else {
            
            i++;
            csMedia = [[LCPCaseStudyMedia alloc] init];
            NSArray *bodyArray = [object objectForKey:@"body"];
            
            UIImage *btnImg = [UIImage imageNamed:@"default_thumb.png"];
            
            NSString *bodyString = @"Not Available";
            //NSMutableDictionary *bodyDict = bodyArray[1];
            for(NSDictionary *obj in bodyArray) {
                if ([obj objectForKey:@"value"]) {
                    bodyString = [obj objectForKey:@"value"];
                    //break;
                }
            }
            csMedia.csMediaTitle = object[@"title"];
            csMedia.csMediaBody = [NSString stringWithFormat:@"%@", bodyString];
            csMedia.csMediaNodeId = object[@"nid"];
            csMedia.csMediaTermReferenceId = object[@"field_term_reference"];
            csMedia.csMediaImage = btnImg;
            csMedia.csMediaThumb = [csMedia scaleImages:btnImg withSize:CGSizeMake(137, 80)];
            
            //add the case study objects to caseStudyObjects Array
            [casestudyMediaObjects addObject:csMedia];
            if (i == objects.count) {
                activityIndicator.alpha = 0.0;
                completeFlag(YES);
            }
        }
    }
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
    
    if(sender.tag == 0) {
        // Send the presenter to OverviewViewController
        OverviewViewController *dvc = (OverviewViewController *)[storyboard instantiateViewControllerWithIdentifier:@"overviewViewController"];
        dvc.content = content;
        [self.navigationController pushViewController:dvc animated:YES];
        [self removeEverything];
        
    } else if(sender.tag == 2) {
        
        // Send the presenter to SamplesViewController
        SamplesViewController *svc = (SamplesViewController *)[storyboard instantiateViewControllerWithIdentifier:@"samplesViewController"];
        svc.content = content;
        [self.navigationController pushViewController:svc animated:YES];
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
    DetailsViewController *dvc = (DetailsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"detailsViewController"];
    
    NSLog(@"Selected NID %@", [NSString stringWithFormat:@"%ld", (long)sender.tag]);
    
    
    // Attempt to make a query on the case study media first.
    // After this query returns with no error, check to see if there is results.
    // If no results are found make a query against samples.
    
    PFQuery *query = [PFQuery queryWithClassName:@"case_study_media"];
    [query fromLocalDatastore];
    [query whereKey:@"nid" equalTo:[NSString stringWithFormat:@"%ld", (long)sender.tag]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Case Study Media Results were returned");
        if (!error) {
            
            
            NSLog(@"Case Study Media Object Count %lu", (unsigned long)[objects count]);
            if ([objects count] > 0) {
                // Push the case study media reference item onto the stack
                dvc.contentObject = objects[0];
                dvc.contentType = @"Case Study Media";
                [self.navigationController pushViewController:dvc animated:YES];
                //[self removeEverything];
            } else {
                // Make a query against samples if no case_study_media results are returned
                PFQuery *query = [PFQuery queryWithClassName:@"samples"];
                [query fromLocalDatastore];
                [query whereKey:@"nid" equalTo:[NSString stringWithFormat:@"%ld", (long)sender.tag]];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    NSLog(@"Sample Results were returned");
                    if (!error) {
                        NSLog(@"Sample Object Count %lu", (unsigned long)[objects count]);
                        // Push the case study media reference item onto the stack
                        dvc.contentObject = objects[0];
                        dvc.contentType = @"samples";
                        [self.navigationController pushViewController:dvc animated:YES];
                        //[self removeEverything];
                        NSLog(@"%s [Line %d] -- Objects Count: %d",__PRETTY_FUNCTION__, __LINE__, objects.count);
                    } else {
                        // Log details of the failure
                        NSLog(@"%s [Line %d] -- Error: %@ %@",__PRETTY_FUNCTION__, __LINE__,  error, [error userInfo]);
                        
                    }
                }];
            }
        } else {
            // Log details of the failure
            NSLog(@"%s [Line %d] -- Error: %@ %@",__PRETTY_FUNCTION__, __LINE__,  error, [error userInfo]);
            
        }
    }];
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