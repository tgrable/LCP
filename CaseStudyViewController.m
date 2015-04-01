//
//  CaseStudyViewController.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 2/18/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "CaseStudyViewController.h"
#import "DetailsViewController.h"
#import "Reachability.h"
#import "NSString+HTML.h"
#import "ParseDownload.h"
#import <Parse/Parse.h>

@interface CaseStudyViewController ()
@property (strong, nonatomic) UIView *background;
@property (strong, nonatomic) UIScrollView *pageScroll;
@property (strong, nonatomic) UIPageControl *caseStudyDots;
@property (strong, nonatomic) ParseDownload *parsedownload;
@property (strong, nonatomic) UIButton *favoriteContentButton;
@property NSMutableArray *nids, *nodeTitles;
@end

@implementation CaseStudyViewController
@synthesize content;        //LCPContent
@synthesize background;     //UIView
@synthesize pageScroll;     //UIScrollView
@synthesize caseStudyDots;  //UIPageControl
@synthesize favoriteContentButton;                   //UIButton
@synthesize nids, nodeTitles;                        //NSMutableArrays
@synthesize parsedownload;                           //ParseDownload

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
    [background setBackgroundColor:[UIColor grayColor]];
    [background setUserInteractionEnabled:YES];
    //[pageScroll addSubview:background];
    [self.view addSubview:background];
    
    UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoButton setFrame:CGRectMake(56, 56, 108, 33)];
    //[logoButton addTarget:self action:@selector(configPage:)forControlEvents:UIControlEventTouchUpInside];
    logoButton.showsTouchWhenHighlighted = YES;
    [logoButton setBackgroundImage:[UIImage imageNamed:@"logo.png"] forState:UIControlStateNormal];
    [self.view addSubview:logoButton];
    
    UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [homeButton setFrame:CGRectMake(56, 108, 50, 50)];
    [homeButton addTarget:self action:@selector(backHome:)forControlEvents:UIControlEventTouchUpInside];
    homeButton.showsTouchWhenHighlighted = YES;
    homeButton.tag = 80;
    [homeButton setBackgroundImage:[UIImage imageNamed:@"btn-back.png"] forState:UIControlStateNormal];
    [self.view addSubview:homeButton];
    
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
    
    favoriteContentButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [favoriteContentButton setFrame:CGRectMake(860, 56, 108, 33)];
    [favoriteContentButton addTarget:self action:@selector(setContentAsFavorite:)forControlEvents:UIControlEventTouchUpInside];
    favoriteContentButton.showsTouchWhenHighlighted = YES;
    [favoriteContentButton setTitle:@"Favorite" forState:UIControlStateNormal];
    favoriteContentButton.backgroundColor = [UIColor whiteColor];
    [favoriteContentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:favoriteContentButton];
    
    pageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(56, 250, (background.bounds.size.width - (56 * 2)), 400)];
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
}

- (void)viewWillAppear:(BOOL)animated {
    UIImageView *caseStudyHeader = [[UIImageView alloc] initWithFrame:CGRectMake(422, 25, 95, 95)];
    [caseStudyHeader setImage:content.imgIcon];
    [background addSubview:caseStudyHeader];
    
    NSString *titleLabel = [NSString stringWithFormat:@"%@ CASE STUDY", content.lblTitle];
    UILabel *summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 110, 952, 70)];
    [summaryLabel setFont:[UIFont fontWithName:@"NimbusSanD-Bold" size:40.0]];
    summaryLabel.textColor = [UIColor whiteColor];
    summaryLabel.numberOfLines = 1;
    summaryLabel.backgroundColor = [UIColor clearColor];
    summaryLabel.textAlignment = NSTextAlignmentCenter;
    summaryLabel.text = titleLabel;
    [background addSubview:summaryLabel];
    
    UIView *rule = [[UIView alloc] initWithFrame:CGRectMake(180, 201, 590, 2)];
    rule.backgroundColor = [UIColor whiteColor];
    [background addSubview:rule];
    
    //NSUserDefaults to check if data has been downloaded.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"case_study"] isEqualToString:@"hasData"]) {
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
                                        nodeType:@"Case Study"
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
        PFQuery *query = [PFQuery queryWithClassName:@"case_study"];
        [query whereKey:@"field_case_study_tag_reference" equalTo:content.termId];
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
    PFQuery *query = [PFQuery queryWithClassName:@"case_study"];
    [query fromLocalDatastore];
    [query whereKey:@"field_case_study_tag_reference" equalTo:content.termId];
    dispatch_async(dispatch_get_main_queue(), ^{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            NSMutableArray *selectedObjects = [[NSMutableArray alloc] init];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            for (PFObject *object in objects) {
                if ([[defaults objectForKey:[object objectForKey:@"nid"]] isEqualToString:@"show"]) {
                    [selectedObjects addObject:object];
                }
            }
            [self buildCaseStudyView:selectedObjects];
        }];
    });
}

#pragma mark
#pragma mark - Build Views
- (void)buildCaseStudyView:(NSArray *)objects {
    int x = 0;
    
    for(PFObject *object in objects) {
        
        //add the nid for the object to nid array
        [nids addObject:object[@"nid"]];
        
        //add the node title to be added for
        [nodeTitles addObject:object[@"title"]];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(x, 15, 802, 30)];
        [title setFont:[UIFont fontWithName:@"NimbusSanD-Bold" size:22.0]];
        title.textColor = [UIColor whiteColor];
        title.numberOfLines = 1;
        title.backgroundColor = [UIColor clearColor];
        title.textAlignment = NSTextAlignmentLeft;
        title.text = [object objectForKey:@"title"];
        [pageScroll addSubview:title];
        
        NSArray *bodyArray = [object objectForKey:@"body"];
        NSMutableDictionary *bodyDict = [[NSMutableDictionary alloc] init];
        bodyDict = bodyArray[1];

        NSString *temp = [NSString stringWithFormat:@"%@", [bodyDict objectForKey:@"value"]];        
        UITextView *body = [[UITextView alloc] initWithFrame:CGRectMake(x, 55, 802, 325)];
        body.editable = NO;
        body.clipsToBounds = YES;
        body.font = [UIFont fontWithName:@"NimbusSanD-Regu" size:19.0];
        body.backgroundColor = [UIColor clearColor];
        body.scrollEnabled = YES;
        body.textColor = [UIColor whiteColor];
        body.text = temp.stringByConvertingHTMLToPlainText;

        [pageScroll addSubview:body];
        
        x += (background.bounds.size.width - (56 * 2));
        
        [pageScroll setContentSize:CGSizeMake(((background.bounds.size.width - (56 * 2)) * objects.count), 355)];

    }
    
    caseStudyDots = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 676, 952, 20)];
    caseStudyDots.currentPage = 0;
    caseStudyDots.backgroundColor = [UIColor clearColor];
    caseStudyDots.pageIndicatorTintColor = [UIColor blackColor];
    caseStudyDots.currentPageIndicatorTintColor = [UIColor whiteColor];
    caseStudyDots.numberOfPages = objects.count;
    [background addSubview:caseStudyDots];
}

//this function updates the dots for the current image the the user is on
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = pageScroll.bounds.size.width;
    //display the appropriate dot when scrolled
    NSInteger pageNumber = floor((pageScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    caseStudyDots.currentPage = pageNumber;
    
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
- (void)backHome:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
