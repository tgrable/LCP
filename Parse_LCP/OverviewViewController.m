//
//  DetailsViewController.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 2/13/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "OverviewViewController.h"
#import "BrandMeetsWorldViewController.h"
#import "CatagoryViewController.h"
#import "CaseStudyViewController.h"
#import "SamplesViewController.h"
#import "VideoViewController.h"
#import "PDFViewController.h"
#import "Reachability.h"
#import "NSString+HTML.h"
#import <Parse/Parse.h>

@interface OverviewViewController ()

@property (strong, nonatomic) UIImage *ovImg, *csImg, *sImg, *vImg;
@property (strong, nonatomic) UIView *background, *summaryView, *navBar;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation OverviewViewController

@synthesize content;                    //LCPContent
@synthesize ovImg, csImg, sImg, vImg;   //UIImage
@synthesize summaryView, navBar;        //UIView
@synthesize activityIndicator;          //ActivityIndicator

- (BOOL)prefersStatusBarHidden {
    //Hide status bar
    return YES;
}

#pragma mark
#pragma mark - ViewController Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //First Page Summary View
    summaryView = [[UIView alloc] initWithFrame:CGRectMake(36, 36, self.view.bounds.size.width - (36 * 2), self.view.bounds.size.height - (36 * 2))];
    [summaryView setBackgroundColor:[UIColor clearColor]];
    [summaryView setUserInteractionEnabled:YES];
    [self.view addSubview:summaryView];
    
    UIImageView *summaryBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, summaryView.bounds.size.width, summaryView.bounds.size.height - 96)];
    summaryBackground.image = [UIImage imageNamed:@"bkgrd-overview"];
    [summaryView addSubview:summaryBackground];

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
    
    //UIView used to hold the four content sections
    navBar = [[UIView alloc] initWithFrame:CGRectMake(0, (summaryView.bounds.size.height - 96), summaryView.bounds.size.width, 96)];
    [navBar setBackgroundColor:[UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0]];
    [summaryView addSubview:navBar];
    
    /******** Content section navigation buttons and labels ********/
    UIButton *overviewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [overviewButton setFrame:CGRectMake((navBar.bounds.size.width / 2) - (97.5f + 45), 10, 47, 47)];
    [overviewButton addTarget:self action:@selector(navigateViewButton:)forControlEvents:UIControlEventTouchUpInside];
    overviewButton.showsTouchWhenHighlighted = YES;
    [overviewButton setBackgroundImage:[UIImage imageNamed:@"ico-overview"] forState:UIControlStateNormal];
    [overviewButton setBackgroundColor:[UIColor clearColor]];
    [overviewButton setContentMode:UIViewContentModeCenter];
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
    
    NSLog(@"content.termId: %@", content.termId);
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


#pragma mark
#pragma mark - Parse
- (void)checkLocalDataStoreforData {
    PFQuery *query = [PFQuery queryWithClassName:@"overview"];
    [query fromLocalDatastore];
    [query whereKey:@"field_term_reference" equalTo:content.termId];
    dispatch_async(dispatch_get_main_queue(), ^{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                if (objects.count > 0) {
                    [self buildSummaryView:objects];
                    NSLog(@"Overview: 1");
                }
                else {
                    [self fetchDataFromParse];
                    NSLog(@"Overview: 2");
                }
            } else {
                // Log details of the failure
                NSLog(@"%s [Line %d] -- Error: %@ %@",__PRETTY_FUNCTION__, __LINE__,  error, [error userInfo]);
                
            }
        }];
    });
}

//Query the parse.com to build the views
- (void)fetchDataFromParse {
    
    //Using Reachability check if there is an internet connection
    //If there is download term data from Parse.com if not alert the user there needs to be an internet connection
    if ([self connected]) {
        PFQuery *query = [PFQuery queryWithClassName:@"overview"];
        [query whereKey:@"field_term_reference" equalTo:content.termId];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [PFObject pinAllInBackground:objects block:^(BOOL succeded, NSError *error) {
                        if (!error) {
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            [defaults setObject:@"hasData" forKey:@"overview"];
                            [defaults synchronize];
                            [self buildSummaryView:objects];
                        } else {
                            // Log details of the failure
                            NSLog(@"%s [Line %d] -- Error: %@ %@",__PRETTY_FUNCTION__, __LINE__,  error, [error userInfo]);
                            
                        }
                    }];
                });
            }
        }];
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


#pragma mark
#pragma mark - Build Views
- (void)buildSummaryView:(NSArray *)objects {
    
    NSLog(@"Overview: %lu", (unsigned long)objects.count);
    
    for(PFObject *object in objects) {
      
        //UIlabel used to hold the Overview title
        content.lblTitle = object[@"title"];
        UILabel *summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 65, summaryView.bounds.size.width - 48, 80)];
        [summaryLabel setFont:[UIFont fontWithName:@"Oswald-Bold" size:80.0f]];
        summaryLabel.textColor = [UIColor whiteColor];
        summaryLabel.backgroundColor = [UIColor clearColor];
        summaryLabel.textAlignment = NSTextAlignmentCenter;
        summaryLabel.text = [content.lblTitle uppercaseString];
        [summaryView addSubview:summaryLabel];
        
        //UIScrollView used to hold the overview body text
        UIScrollView *summaryScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(24, 210, (summaryView.bounds.size.width - 48), summaryView.bounds.size.height - 354)];
        summaryScroll.layer.borderWidth = 1.0f;
        summaryScroll.layer.borderColor = [UIColor whiteColor].CGColor;
        [summaryView addSubview:summaryScroll];
        
        //Body content comimg in from Parse.com looks like an array of dictionary values
        /*[{"summary":"<p>As the number of marketing channels continues to grow, a content management system (CMS) has quickly become a must-have for marketers. A CMS provides a central repository for content deployed across print, web, social media, mobile and more. With a user-friendly interface and automated workflow, the CMS provides a collaborative environment for creation, editing, approval, publishing and storage of all your company’s digital assets.</p>\r\n"},{"value":"<p>As the number of marketing channels continues to grow, a content management system (CMS) has quickly become a must-have for marketers. A CMS provides a central repository for content deployed across print, web, social media, mobile and more. With a user-friendly interface and automated workflow, the CMS provides a collaborative environment for creation, editing, approval, publishing and storage of all your company’s digital assets.</p>\r\n"},{"format":"filtered_html"}]*/
        
        NSArray *bodyArray = [object objectForKey:@"body"];
        //NSMutableDictionary *bodyDict = bodyArray[1];
        NSString *bodyString = @"Not Available";
        for (NSDictionary *obj in bodyArray) {
            if([obj objectForKey:@"value"] != nil) {
                bodyString = [obj objectForKey:@"value"];
                break;
            }
        }

        //UILabel used to hold the body copy content
        UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 24, summaryScroll.bounds.size.width - (24 * 2), summaryScroll.bounds.size.height - 48)];
        myLabel.numberOfLines = 0;
        NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
        style.minimumLineHeight = 30.0f;
        style.maximumLineHeight = 30.0f;
        NSDictionary *attributtes = @{NSParagraphStyleAttributeName : style,};
        myLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",bodyString].stringByConvertingHTMLToPlainText attributes:attributtes];
        myLabel.font = [UIFont fontWithName:@"AktivGrotesk-Regular" size:26.0];
        myLabel.textColor = [UIColor whiteColor];
        [myLabel sizeToFit];
        [summaryScroll addSubview:myLabel];
        
        //Set the hieght of summaryScroll to the height of the UILabel
        [summaryScroll setContentSize:CGSizeMake(summaryScroll.bounds.size.width, myLabel.frame.size.height)];
    }
    
    [activityIndicator stopAnimating];
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

- (void)hiddenSection:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PDFViewController *pvc = (PDFViewController *)[storyboard instantiateViewControllerWithIdentifier:@"pdfViewController"];
    [self.navigationController pushViewController:pvc animated:YES];
}

- (void)navigateViewButton:(UIButton *)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    if(sender.tag == 1){
        
        // Send the presenter to CaseStudyViewController
        CaseStudyViewController *cvc = (CaseStudyViewController *)[storyboard instantiateViewControllerWithIdentifier:@"caseStudyViewController"];
        cvc.content = content;
        [self.navigationController pushViewController:cvc animated:YES];
        [self removeEverything];
        
    } else if(sender.tag == 2){
        
        // Send the presenter to SamplesViewController
        SamplesViewController *svc = (SamplesViewController *)[storyboard instantiateViewControllerWithIdentifier:@"samplesViewController"];
        svc.content = content;
        [self.navigationController pushViewController:svc animated:YES];
        [self removeEverything];
        
    } else if(sender.tag == 3){
        
        // Send the presenter to VideoViewController
        VideoViewController *vvc = (VideoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"videoViewController"];
        vvc.content = content;
        [self.navigationController pushViewController:vvc animated:YES];
        //[self removeEverything];
    }
}



#pragma mark
#pragma mark - Memory Management
- (void)removeEverything {
    
    //Loop through and remove all the views in background
    for (UIView *v in [summaryView subviews]) {
        [v removeFromSuperview];
    }
}
@end
