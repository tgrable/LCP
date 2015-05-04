//
//  DetailsViewController.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 2/13/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "DetailsViewController.h"
#import "BrandMeetsWorldViewController.h"
#import "CatagoryViewController.h"
#import "CaseStudyViewController.h"
#import "SamplesViewController.h"
#import "VideoViewController.h"
#import "Reachability.h"
#import "NSString+HTML.h"
#import <Parse/Parse.h>

@interface DetailsViewController ()

@property (strong, nonatomic) UIImage *ovImg, *csImg, *sImg, *vImg;
@property (strong, nonatomic) UIView *background, *summaryView;
@property (strong, nonatomic) UIScrollView *pageScroll;

@end

@implementation DetailsViewController

@synthesize content;                    //LCPContent
@synthesize ovImg, csImg, sImg, vImg;   //UIImage
@synthesize summaryView;                //UIView
@synthesize pageScroll;                 //UIScrollView

- (BOOL)prefersStatusBarHidden
{
    return YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //First Page Summary View
    summaryView = [[UIView alloc] initWithFrame:CGRectMake(36, 36, self.view.bounds.size.width - (36 * 2), self.view.bounds.size.height - (36 * 2))];
    [summaryView setBackgroundColor:[UIColor clearColor]];
    [summaryView setUserInteractionEnabled:YES];
    [self.view addSubview:summaryView];
    
    UIImageView *summaryBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, summaryView.bounds.size.width, summaryView.bounds.size.height - 96)];
    summaryBackground.image = [UIImage imageNamed:@"bkgrd-overview.png"];
    [summaryView addSubview:summaryBackground];

    //Logo and setting navigation buttons
    UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoButton setFrame:CGRectMake(60, 6.5f, 70, 23)];
    [logoButton addTarget:self action:@selector(hiddenSection:)forControlEvents:UIControlEventTouchUpInside];
    logoButton.showsTouchWhenHighlighted = YES;
    [logoButton setBackgroundImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
    [self.view addSubview:logoButton];
    
    //the following two views add a button for navigation back to the dashboard
    UIView *dashboardBackground = [[UIView alloc] initWithFrame:CGRectMake(150, 0, 45, 45)];
    dashboardBackground.backgroundColor = [UIColor whiteColor];
    dashboardBackground.layer.cornerRadius = (45/2);
    dashboardBackground.layer.masksToBounds = YES;
    [self.view addSubview:dashboardBackground];
    
    UIButton *dashboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dashboardButton setFrame:CGRectMake(4.5f, 4.5f, 36, 36)];
    [dashboardButton addTarget:self action:@selector(backToDashboard:)forControlEvents:UIControlEventTouchUpInside];
    dashboardButton.showsTouchWhenHighlighted = YES;
    [dashboardButton setBackgroundImage:[UIImage imageNamed:@"ico-gear"] forState:UIControlStateNormal];
    [dashboardBackground addSubview:dashboardButton];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake((self.view.bounds.size.width - 105), 5, 45, 45)];
    [backButton addTarget:self action:@selector(backNav:)forControlEvents:UIControlEventTouchUpInside];
    backButton.showsTouchWhenHighlighted = YES;
    backButton.tag = 1;
    [backButton setBackgroundImage:[UIImage imageNamed:@"ico-back.png"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    
    UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [homeButton setFrame:CGRectMake((self.view.bounds.size.width - 170), 0, 45, 45)];
    [homeButton addTarget:self action:@selector(backNav:)forControlEvents:UIControlEventTouchUpInside];
    homeButton.showsTouchWhenHighlighted = YES;
    homeButton.tag = 0;
    [homeButton setBackgroundImage:[UIImage imageNamed:@"ico-home.png"] forState:UIControlStateNormal];
    [self.view addSubview:homeButton];
}

- (void)viewWillAppear:(BOOL)animated {
    //NSUserDefaults to check if data has been downloaded.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"overview"] isEqualToString:@"hasData"]) {
        [self fetchDataFromLocalDataStore];
    }
    else {
        [self fetchDataFromParse];
    }

    
    //[pageScroll setContentSize:CGSizeMake(1024, (self.view.bounds.size.height * 2))];
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    [PFObject pinAllInBackground:objects block:^(BOOL succeded, NSError *error) {
                        if (!error) {
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            [defaults setObject:@"hasData" forKey:@"overview"];
                            [defaults synchronize];
                            [self buildSummaryView:objects];
                        }
                    }];
                });
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSLog(@"call buildSummaryView");
            [self buildSummaryView:objects];

        }];
    });
}

#pragma mark
#pragma mark - Build Views
- (void)buildSummaryView:(NSArray *)objects {
    for(PFObject *object in objects) {
        
        content.lblTitle = object[@"title"];
        UILabel *summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 65, summaryView.bounds.size.width - 48, 80)];
        [summaryLabel setFont:[UIFont fontWithName:@"Oswald-Bold" size:80.0f]];
        summaryLabel.textColor = [UIColor whiteColor];
        summaryLabel.backgroundColor = [UIColor clearColor];
        summaryLabel.textAlignment = NSTextAlignmentCenter;
        summaryLabel.text = [content.lblTitle uppercaseString];
        [summaryView addSubview:summaryLabel];
        
        UIScrollView *summaryScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(24, 210, (summaryView.bounds.size.width - 48), summaryView.bounds.size.height - 354)];
        summaryScroll.layer.borderWidth = 1.0f;
        summaryScroll.layer.borderColor = [UIColor whiteColor].CGColor;
        [summaryView addSubview:summaryScroll];
        
        NSArray *bodyArray = [object objectForKey:@"body"];
        NSMutableDictionary *bodyDict = [[NSMutableDictionary alloc] init];
        bodyDict = bodyArray[1];
        
        NSString *introText = [NSString stringWithFormat:@"%@",[bodyDict objectForKey:@"value"]];
        UITextView *introTextView = [[UITextView alloc] initWithFrame:CGRectMake(24, 24, summaryScroll.bounds.size.width - (24 * 2), summaryScroll.bounds.size.height - 48)];
        [introTextView setFont:[UIFont fontWithName:@"AktivGrotesk-Regular" size:26.0f]];
        introTextView.textColor = [UIColor whiteColor];
        introTextView.textAlignment = NSTextAlignmentCenter;
        introTextView.backgroundColor = [UIColor clearColor];
        introTextView.text = introText.stringByConvertingHTMLToPlainText;
        introTextView.userInteractionEnabled = NO;
        [summaryScroll addSubview:introTextView];

        [summaryScroll setContentSize:CGSizeMake(summaryScroll.bounds.size.width, (introTextView.font.lineHeight * (introTextView.contentSize.height/introTextView.font.lineHeight)) + 36)];
        
        UIView *navBar = [[UIView alloc] initWithFrame:CGRectMake(0, (summaryView.bounds.size.height - 96), summaryView.bounds.size.width, 96)];
        [navBar setBackgroundColor:[UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0]];
        [summaryView addSubview:navBar];
         
        UIButton *overviewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [overviewButton setFrame:CGRectMake((navBar.bounds.size.width / 2) - (97.5f + 45), 10, 45, 45)];
        [overviewButton addTarget:self action:@selector(navigateViewButton:)forControlEvents:UIControlEventTouchUpInside];
        overviewButton.showsTouchWhenHighlighted = YES;
        [overviewButton setBackgroundImage:[UIImage imageNamed:@"ico-overview.png"] forState:UIControlStateNormal];
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
        [caseStudiesButton setBackgroundImage:[UIImage imageNamed:@"ico-casestudy2.png"] forState:UIControlStateNormal];
        caseStudiesButton.tag = 1;
        [navBar addSubview:caseStudiesButton];
        
        UILabel *casestudyLabel = [[UILabel alloc] initWithFrame:CGRectMake((navBar.bounds.size.width / 2) - 80, navBar.bounds.size.height - 32, 80, 32)];
        [casestudyLabel setFont:[UIFont fontWithName:@"Oswald" size:12.0]];
        casestudyLabel.textColor = [UIColor blackColor];
        casestudyLabel.numberOfLines = 1;
        casestudyLabel.backgroundColor = [UIColor clearColor];
        casestudyLabel.textAlignment = NSTextAlignmentCenter;
        casestudyLabel.text = @"CASE STUDY";
        [navBar addSubview:casestudyLabel];
        
        UIButton *samplesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [samplesButton setFrame:CGRectMake((navBar.bounds.size.width / 2) + 17.5f, 10, 45, 45)];
        [samplesButton addTarget:self action:@selector(navigateViewButton:)forControlEvents:UIControlEventTouchUpInside];
        samplesButton.showsTouchWhenHighlighted = YES;
        [samplesButton setBackgroundImage:[UIImage imageNamed:@"ico-samples.png"] forState:UIControlStateNormal];
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
        [videoButton setBackgroundImage:[UIImage imageNamed:@"ico-video2.png"] forState:UIControlStateNormal];
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
        
        UIView *locationIndicator = [[UIView alloc] initWithFrame:CGRectMake((navBar.bounds.size.width / 2) - 160, 0, 80, 5)];
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

-(void)backNav:(UIButton *)sender
{
    NSArray *array = [self.navigationController viewControllers];
    if (sender.tag == 0) {
        [self.navigationController popToViewController:[array objectAtIndex:2] animated:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self removeEverything];
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
        VideoViewController *vvc = (VideoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"videoViewController"];
        vvc.content = content;
        [self.navigationController pushViewController:vvc animated:YES];
        [self removeEverything];
    }
    
    [UIView animateWithDuration:1.2f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        [pageScroll setContentOffset:CGPointMake(0, y) animated:NO];
    }completion:^(BOOL finished) {}];
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
