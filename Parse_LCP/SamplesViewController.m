//
//  SamplesViewController.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 2/19/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "SamplesViewController.h"
#import "DetailsViewController.h"
#import "Reachability.h"
#import "NSString+HTML.h"
#import <Parse/Parse.h>

@interface SamplesViewController ()
@property (strong, nonatomic) UIView *background;
@property (strong, nonatomic) UIScrollView *pageScroll;
@property (strong, nonatomic) UIPageControl *caseStudyDots;
@end

@implementation SamplesViewController
@synthesize content;        //LCPContent
@synthesize background;     //UIView
@synthesize pageScroll;     //UIScrollView
@synthesize caseStudyDots;  //UIPageControl

- (BOOL)prefersStatusBarHidden
{
    return YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //First Page Summary View
    background = [[UIView alloc] initWithFrame:CGRectMake(36, 36, 952, 696)];
    [background setBackgroundColor:[UIColor grayColor]];
    [background setUserInteractionEnabled:YES];
    //[pageScroll addSubview:background];
    [self.view addSubview:background];
    
    UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoButton setFrame:CGRectMake(56, 56, 108, 33)];
    //[logoButton addTarget:self action:@selector(hiddenSection:)forControlEvents:UIControlEventTouchUpInside];
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
    
    pageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(56, 250, (background.bounds.size.width - (56 * 2)), 400)];
    pageScroll.showsHorizontalScrollIndicator = NO;
    pageScroll.showsVerticalScrollIndicator = YES;
    pageScroll.pagingEnabled = YES;
    pageScroll.scrollEnabled = YES;
    pageScroll.delegate = self;
    pageScroll.backgroundColor = [UIColor clearColor];
    [background addSubview:pageScroll];
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

#pragma mark
#pragma mark - Parse
- (void)fetchDataFromParse {
    
    if ([self connected]) {
        PFQuery *query = [PFQuery queryWithClassName:@"samples"];
        [query whereKey:@"field_sample_tag_reference" equalTo:content.termId];
        [query orderByAscending:@"createdAt"];
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
    [query whereKey:@"field_sample_tag_reference" equalTo:content.termId];
    [query orderByAscending:@"createdAt"];
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
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = pageScroll.bounds.size.width;
    //display the appropriate dot when scrolled
    NSInteger pageNumber = floor((pageScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    caseStudyDots.currentPage = pageNumber;
}

#pragma mark
#pragma mark - Build Views
- (void)buildSamplesView:(NSArray *)objects {
    
    pageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, background.bounds.size.width, background.bounds.size.height)];
    pageScroll.showsHorizontalScrollIndicator = NO;
    pageScroll.showsVerticalScrollIndicator = YES;
    pageScroll.pagingEnabled = YES;
    pageScroll.scrollEnabled = YES;
    pageScroll.delegate = self;
    pageScroll.backgroundColor = [UIColor clearColor];
    [background addSubview:pageScroll];
    
    int x = 0;
    
    for (PFObject *object in objects){        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake((x + 140), 15, 702, 30)];
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
        UITextView *body = [[UITextView alloc] initWithFrame:CGRectMake((x + 140), 55, 702, 125)];
        body.editable = NO;
        body.clipsToBounds = YES;
        body.font = [UIFont fontWithName:@"NimbusSanD-Regu" size:19.0];
        body.backgroundColor = [UIColor clearColor];
        body.scrollEnabled = YES;
        body.textColor = [UIColor whiteColor];
        body.text = temp.stringByConvertingHTMLToPlainText;
        [pageScroll addSubview:body];
        
        //Sample Image
        PFFile *sampleFile = object[@"field_sample_image_img"];
        [sampleFile getDataInBackgroundWithBlock:^(NSData *sampleData, NSError *error) {
            
            UIImage *sampleImg = [[UIImage alloc] initWithData:sampleData];
            UIImageView *sample = [[UIImageView alloc] initWithFrame:CGRectMake(x, 200, background.bounds.size.width, 500)];
            [sample setImage:sampleImg];
            [sample setUserInteractionEnabled:YES];
            sample.alpha = 1.0;
            sample.tag = 90;
            [pageScroll addSubview:sample];
        }];
        
        caseStudyDots = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 676, 952, 20)];
        caseStudyDots.currentPage = 0;
        caseStudyDots.backgroundColor = [UIColor clearColor];
        caseStudyDots.pageIndicatorTintColor = [UIColor blackColor];
        caseStudyDots.currentPageIndicatorTintColor = [UIColor whiteColor];
        caseStudyDots.numberOfPages = objects.count;
        [background addSubview:caseStudyDots];
        

        [pageScroll setContentSize:CGSizeMake((background.bounds.size.width * objects.count), 400)];
        x += background.bounds.size.width;
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
-(void)backHome:(id)sender
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
