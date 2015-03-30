//
//  DetailsViewController.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 2/13/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "DetailsViewController.h"
#import "CatagoryViewController.h"
#import "CaseStudyViewController.h"
#import "SamplesViewController.h"
#import "Reachability.h"
#import "NSString+HTML.h"
#import <Parse/Parse.h>

@interface DetailsViewController ()

@property (strong, nonatomic) UIImage *ovImg, *csImg, *sImg, *vImg;
@property (strong, nonatomic) UIView *background, *summaryView, *overviewView;
@property (strong, nonatomic) UIScrollView *pageScroll;

@end

@implementation DetailsViewController

@synthesize content;                   //LCPContent
@synthesize ovImg, csImg, sImg, vImg;  //UIImage
@synthesize summaryView, overviewView; //UIView
@synthesize pageScroll;                //UIScrollView

- (BOOL)prefersStatusBarHidden
{
    return YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    //we do as much as we can in view did load to conserve memory
    pageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    pageScroll.showsHorizontalScrollIndicator = NO;
    pageScroll.showsVerticalScrollIndicator = YES;
    pageScroll.pagingEnabled = YES;
    pageScroll.scrollEnabled = YES;
    pageScroll.delegate = self;
    pageScroll.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:pageScroll];

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


}

- (void)viewWillAppear:(BOOL)animated {
    //First Page Summary View
    summaryView = [[UIView alloc] initWithFrame:CGRectMake(36, 36, 952, 696)];
    [summaryView setBackgroundColor:[UIColor grayColor]];
    [summaryView setUserInteractionEnabled:YES];
    [pageScroll addSubview:summaryView];
    
    //Second Page OverView Bullets
    overviewView = [[UIView alloc] initWithFrame:CGRectMake(36, (768 + 36), 952, 696)];
    [overviewView setBackgroundColor:[UIColor grayColor]];
    [overviewView setUserInteractionEnabled:YES];
    [pageScroll addSubview:overviewView];

    [self catagoryNavigation];
    
    //NSUserDefaults to check if data has been downloaded.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"overview"] isEqualToString:@"hasData"]) {
        [self fetchDataFromLocalDataStore];
    }
    else {
        [self fetchDataFromParse];
    }

    
    [pageScroll setContentSize:CGSizeMake(1024, (self.view.bounds.size.height * 2))];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark
#pragma mark - Parse
- (void)fetchDataFromParse {
    if ([self connected]) {
        PFQuery *query = [PFQuery queryWithClassName:@"overview"];
        [query whereKey:@"field_overview_tag_reference" equalTo:content.termId];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                [PFObject pinAllInBackground:objects block:^(BOOL succeded, NSError *error) {
                    if (!error) {
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setObject:@"hasData" forKey:@"overview"];
                        [defaults synchronize];
                        [self buildSummaryView:objects];
                        [self buildOverviewView:objects];
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
    PFQuery *query = [PFQuery queryWithClassName:@"overview"];
    [query fromLocalDatastore];
    [query whereKey:@"field_overview_tag_reference" equalTo:content.termId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self buildSummaryView:objects];
        [self buildOverviewView:objects];

    }];
}

#pragma mark
#pragma mark - Build Views
- (void)buildSummaryView:(NSArray *)objects {
    for(PFObject *object in objects) {
        
        PFFile *imageFile = object[@"field_detail_image_img"];
        [imageFile getDataInBackgroundWithBlock:^(NSData *imgData, NSError *error) {
            if (!error) {
                content.imgIcon = [[UIImage alloc] initWithData:imgData];
                
                UIImageView *summaryHeader = [[UIImageView alloc] initWithFrame:CGRectMake(422, 25, 95, 95)];
                [summaryHeader setImage:content.imgIcon];
                [summaryView addSubview:summaryHeader];
                
                UIImageView *overViewHeader = [[UIImageView alloc] initWithFrame:CGRectMake(443, 56, 65, 65)];
                [overViewHeader setImage:content.imgIcon];
                [overviewView addSubview:overViewHeader];
            }
        }];
        
        UIView *rule = [[UIView alloc] initWithFrame:CGRectMake(335, 135, 280, 2)];
        rule.backgroundColor = [UIColor whiteColor];
        [summaryView addSubview:rule];
        
        content.lblTitle = object[@"title"];
        UILabel *summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 160, 952, 70)];
        [summaryLabel setFont:[UIFont fontWithName:@"NimbusSanD-Bold" size:70.0]];
        summaryLabel.textColor = [UIColor whiteColor];
        summaryLabel.numberOfLines = 1;
        summaryLabel.backgroundColor = [UIColor clearColor];
        summaryLabel.textAlignment = NSTextAlignmentCenter;
        summaryLabel.text = content.lblTitle;
        [summaryView addSubview:summaryLabel];
        
        NSArray *bodyArray = [object objectForKey:@"body"];
        NSMutableDictionary *bodyDict = [[NSMutableDictionary alloc] init];
        bodyDict = bodyArray[1];
        
        NSString *introText = [NSString stringWithFormat:@"%@",[bodyDict objectForKey:@"value"]];
        UILabel *intro = [[UILabel alloc] initWithFrame:CGRectMake(120, 254, 712, 135)];
        [intro setFont:[UIFont fontWithName:@"NimbusSanD-Regu" size:19.0]];
        intro.textColor = [UIColor whiteColor];
        intro.numberOfLines = 8;
        intro.textAlignment = NSTextAlignmentCenter;
        intro.backgroundColor = [UIColor clearColor];
        intro.text = introText.stringByConvertingHTMLToPlainText;
        [summaryView addSubview:intro];
        
        NSArray *fieldContentList = [object objectForKey:@"field_content_option_list_"];
        NSMutableDictionary *contentDict = [[NSMutableDictionary alloc] init];
        int x = 265;
        
        UIButton *overviewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [overviewButton setFrame:CGRectMake(36, 424, 193, 236)];
        [overviewButton addTarget:self action:@selector(navigateViewButton:)forControlEvents:UIControlEventTouchUpInside];
        overviewButton.showsTouchWhenHighlighted = YES;
        [overviewButton setBackgroundImage:ovImg forState:UIControlStateNormal];
        overviewButton.tag = 0;
        [summaryView addSubview:overviewButton];
        
        for (int i = 0; i < fieldContentList.count; i++) {
            contentDict = fieldContentList[i];
            
            if([[NSString stringWithFormat:@"%@", [contentDict objectForKey:@"value"]] isEqualToString:@"Case Studies"]) {
                UIButton *caseStudiesButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [caseStudiesButton setFrame:CGRectMake(x, 424, 193, 236)];
                [caseStudiesButton addTarget:self action:@selector(navigateViewButton:)forControlEvents:UIControlEventTouchUpInside];
                caseStudiesButton.showsTouchWhenHighlighted = YES;
                [caseStudiesButton setBackgroundImage:csImg forState:UIControlStateNormal];
                caseStudiesButton.tag = 1;
                [summaryView addSubview:caseStudiesButton];
                x += 229;
            }
            else if ([[NSString stringWithFormat:@"%@", [contentDict objectForKey:@"value"]] isEqualToString:@"Samples"]) {
                UIButton *samplesButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [samplesButton setFrame:CGRectMake(x, 424, 193, 236)];
                [samplesButton addTarget:self action:@selector(navigateViewButton:)forControlEvents:UIControlEventTouchUpInside];
                samplesButton.showsTouchWhenHighlighted = YES;
                [samplesButton setBackgroundImage:sImg forState:UIControlStateNormal];
                samplesButton.tag = 2;
                [summaryView addSubview:samplesButton];
                x += 229;
                
            }
            else if ([[NSString stringWithFormat:@"%@", [contentDict objectForKey:@"value"]] isEqualToString:@"Videos"]) {
                UIButton *videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [videoButton setFrame:CGRectMake(x, 424, 193, 236)];
                //[videoButton addTarget:self action:@selector(overviewButton:)forControlEvents:UIControlEventTouchUpInside];
                videoButton.showsTouchWhenHighlighted = YES;
                [videoButton setBackgroundImage:vImg forState:UIControlStateNormal];
                videoButton.tag = 3;
                [summaryView addSubview:videoButton];
            }
            else {
                NSLog(@"No Content");
            }
        } //End fieldContentList for loop
    } //End objects for loop
}

- (void)buildOverviewView:(NSArray *)objects {
    for (PFObject *object in objects) {
        UILabel *overViewHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(305, 141, 340, 40)];
        [overViewHeaderLabel setFont:[UIFont fontWithName:@"NimbusSanD-Regu" size:40.0]];
        overViewHeaderLabel.textColor = [UIColor whiteColor];
        overViewHeaderLabel.numberOfLines = 1;
        overViewHeaderLabel.backgroundColor = [UIColor clearColor];
        overViewHeaderLabel.textAlignment = NSTextAlignmentCenter;
        overViewHeaderLabel.text = [NSString stringWithFormat:@"%@ OVERVIEW", object[@"title"]];
        [overviewView addSubview:overViewHeaderLabel];
        
        UIView *rule2 = [[UIView alloc] initWithFrame:CGRectMake(335, 201, 280, 2)];
        rule2.backgroundColor = [UIColor whiteColor];
        [overviewView addSubview:rule2];
        
        NSArray *bulletArray = [object objectForKey:@"field_overview_bullets"];
        NSMutableDictionary *bulletDict = [[NSMutableDictionary alloc] init];
        int y = 229;
        for (int i = 0; i < bulletArray.count; i++) {
            bulletDict = bulletArray[i];
            
            UILabel *bulletText = [[UILabel alloc] initWithFrame:CGRectMake(95, y, 772, 50)];
            [bulletText setFont:[UIFont fontWithName:@"NimbusSanD-Regu" size:19.0]];
            bulletText.textColor = [UIColor whiteColor];
            bulletText.numberOfLines = 3;
            bulletText.backgroundColor = [UIColor clearColor];
            bulletText.textAlignment = NSTextAlignmentCenter;
            bulletText.text = [bulletDict objectForKey:@"value"];
            [overviewView addSubview:bulletText];
            
            if (i < (bulletArray.count - 1)) {
                UIImageView *bulletOne = [[UIImageView alloc] initWithFrame:CGRectMake(471, (y + 60), 10, 10)];
                bulletOne.backgroundColor = [UIColor redColor];
                [overviewView addSubview:bulletOne];
            }
            y += 90;
            
        } //End bulletArray for loop
    } //End objects for loop
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"backToCatagory"]) {
        CatagoryViewController *vc = [segue destinationViewController];
        vc.content = content;
    }
    else if ([[segue identifier] isEqualToString:@"sample"]) {
        SamplesViewController *vc = [segue destinationViewController];
        vc.content = content;
    }
    else {
        
    }
}

-(void)backHome:(id)sender
{
    //remove all assets here for future memory enhancements
    if(pageScroll.contentOffset.y >= 768 ){
        [UIView animateWithDuration:1.2f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            [pageScroll setContentOffset:CGPointMake(0, 0) animated:NO];
        }completion:^(BOOL finished) {
            if(pageScroll.contentOffset.y == 3072){
                [UIView animateWithDuration:1.2f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                    //videoPoster.alpha = 0.0;
                }completion:^(BOOL finished) {
                    //[moviePlayerController play];
                }];
                //videoFlag = YES;
            }
        }];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
        [self removeEverything];
    }
}

- (void)navigateViewButton:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIButton *b = (UIButton *)sender;
    
    int y = 0;
    if(b.tag == 0){
        y = 768;
    }else if(b.tag == 1){
        CaseStudyViewController *cvc = (CaseStudyViewController *)[storyboard instantiateViewControllerWithIdentifier:@"caseStudyViewController"];
        cvc.content = content;
        [self.navigationController pushViewController:cvc animated:YES];
        [self removeEverything];
    }else if(b.tag == 2){
        SamplesViewController *svc = (SamplesViewController *)[storyboard instantiateViewControllerWithIdentifier:@"samplesViewController"];
        svc.content = content;
        [self.navigationController pushViewController:svc animated:YES];
        [self removeEverything];
    }else if(b.tag == 3){
        y = 3072;
    }
    
    [UIView animateWithDuration:1.2f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        [pageScroll setContentOffset:CGPointMake(0, y) animated:NO];
    }completion:^(BOOL finished) {}];
}

- (void)catagoryNavigation {
    if ([content.catagoryId isEqualToString:@"38"]) {
        ovImg = [UIImage imageNamed:@"btn-printed-overview.png"];
        csImg = [UIImage imageNamed:@"btn-printed-casestudy.png"];
        sImg = [UIImage imageNamed:@"btn-printed-samples.png"];
        vImg = [UIImage imageNamed:@"btn-printed-video.png"];
    }
    else if ([content.catagoryId isEqualToString:@"40"]) {
        ovImg = [UIImage imageNamed:@"btn-vision-overview.png"];
        csImg = [UIImage imageNamed:@"btn-vision-casestudy.png"];
        sImg = [UIImage imageNamed:@"btn-vision-samples.png"];
        vImg = [UIImage imageNamed:@"btn-vision-video.png"];
    }
    else if ([content.catagoryId isEqualToString:@"41"]) {
        ovImg = [UIImage imageNamed:@"btn-customer-overview.png"];
        csImg = [UIImage imageNamed:@"btn-customer-casestudy.png"];
        sImg = [UIImage imageNamed:@"btn-customer-samples.png"];
        vImg = [UIImage imageNamed:@"btn-customer-video.png"];
    }
    else if ([content.catagoryId isEqualToString:@"42"]) {
        ovImg = [UIImage imageNamed:@"btn-ideation-overview.png"];
        csImg = [UIImage imageNamed:@"btn-ideation-casestudy.png"];
        sImg = [UIImage imageNamed:@"btn-ideation-samples.png"];
        vImg = [UIImage imageNamed:@"btn-ideation-video.png"];
    }
    else if ([content.catagoryId isEqualToString:@"43"]) {
        ovImg = [UIImage imageNamed:@"btn-content-overview.png"];
        csImg = [UIImage imageNamed:@"btn-content-casestudy.png"];
        sImg = [UIImage imageNamed:@"btn-content-samples.png"];
        vImg = [UIImage imageNamed:@"btn-content-video.png"];
    }
    else if ([content.catagoryId isEqualToString:@"44"]) {
        ovImg = [UIImage imageNamed:@"btn-cms-overview.png"];
        csImg = [UIImage imageNamed:@"btn-cms-casestudy.png"];
        sImg = [UIImage imageNamed:@"btn-cms-samples.png"];
        vImg = [UIImage imageNamed:@"btn-cms-video.png"];
    }
    else {
        
    }
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
