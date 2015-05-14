//
//  TestimonialsViewController.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 2/23/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "TestimonialsViewController.h"
#import "CatagoryViewController.h"
#import "Reachability.h"
#import "NSString+HTML.h"
#import "SMPageControl.h"
#import <Parse/Parse.h>

@interface TestimonialsViewController ()
@property (strong, nonatomic) UIView *background;
@property (strong, nonatomic) UIScrollView *pageScroll;
@property (strong, nonatomic) SMPageControl *paginationDots;
@end

@implementation TestimonialsViewController
@synthesize content;        //LCPContent
@synthesize background;     //UIView
@synthesize pageScroll;     //UIScrollView
@synthesize paginationDots;  //UIPageControl

- (BOOL)prefersStatusBarHidden
{
    return YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"Testimonials");
    
    //First Page Summary View
    background = [[UIView alloc] initWithFrame:CGRectMake(36, 36, self.view.bounds.size.width - (36 * 2), self.view.bounds.size.height - (36 * 2))];
    [background setBackgroundColor:[UIColor clearColor]];
    [background setUserInteractionEnabled:YES];
    [self.view addSubview:background];
    
    UIImageView *summaryBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, background.bounds.size.width, background.bounds.size.height)];
    summaryBackground.image = [UIImage imageNamed:@"bkgrd-overview"];
    [background addSubview:summaryBackground];
    
    /******** Logo and setting navigation buttons ********/
    //UIImageView used to hold LCP logo
    UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(60, 6.5f, 70, 23)];
    logo.image = [UIImage imageNamed:@"logo"];
    [self.view addSubview:logo];
    
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //NSUserDefaults to check if data has been downloaded.
    //If data has been downloaded pull from local datastore
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"testimonials"] isEqualToString:@"hasData"]) {
        [self fetchDataFromLocalDataStore];
    }
    else {
        [self fetchDataFromParse];
    }
}

#pragma mark
#pragma mark - Parse
//Query the local datastore to build the views
- (void)fetchDataFromLocalDataStore {
    
    PFQuery *query = [PFQuery queryWithClassName:@"testimonials"];
    [query fromLocalDatastore];
    [query whereKey:@"field_term_reference" equalTo:content.catagoryId];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        //Some testimonials may have be disabled in the app dashboard
        //Check which one are set to "show" and use those to build the view
        NSMutableArray *selectedObjects = [[NSMutableArray alloc] init];
        NSMutableDictionary *lcpTestimonials = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lcpContent"] mutableCopy];
        
        //Add selected objects the the array
        for (PFObject *object in objects) {
            //Add selected objects the the array
            if ([[lcpTestimonials objectForKey:[object objectForKey:@"nid"]] isEqualToString:@"show"]) {
                [selectedObjects addObject:object];
            }
        }
        [self buildTestimonials:selectedObjects];
    }];
}

- (void)fetchDataFromParse {
    
    //Using Reachability check if there is an internet connection
    //If there is download term data from Parse.com if not alert the user there needs to be an internet connection
    if ([self connected]) {
        PFQuery *query = [PFQuery queryWithClassName:@"testimonials"];
        [query whereKey:@"field_testimonial_tag_reference" equalTo:content.catagoryId];
        [query orderByAscending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                [PFObject pinAllInBackground:objects block:^(BOOL succeded, NSError *error) {
                    if (!error) {
                        NSUserDefaults *csDefaults = [NSUserDefaults standardUserDefaults];
                        [csDefaults setObject:@"hasData" forKey:@"testimonials"];
                        [csDefaults synchronize];

                        //Some testimonials may have be disabled in the app dashboard
                        //Check which one are set to "show" and use those to build the view
                        NSMutableArray *selectedObjects = [[NSMutableArray alloc] init];
                        NSMutableDictionary *lcpTestimonials = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lcpContent"] mutableCopy];
                        
                        //Add selected objects the the array
                        for (PFObject *object in objects) {
                            //Add selected objects the the array
                            if ([[lcpTestimonials objectForKey:[object objectForKey:@"nid"]] isEqualToString:@"show"]) {
                                [selectedObjects addObject:object];
                            }
                        }
                        [self buildTestimonials:selectedObjects];
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
        //Alert the user there is no internet connection
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Error"
                                                        message:@"You need an internet connection to download data."
                                                       delegate:self cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark - Build View
- (void)buildTestimonials:(NSArray *)objects {
    
    pageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(24, 0, (background.bounds.size.width - 48), background.bounds.size.height - 36)];
    pageScroll.showsHorizontalScrollIndicator = NO;
    pageScroll.showsVerticalScrollIndicator = YES;
    pageScroll.pagingEnabled = YES;
    pageScroll.scrollEnabled = YES;
    pageScroll.delegate = self;
    pageScroll.backgroundColor = [UIColor clearColor];
    [background addSubview:pageScroll];
    
    int x = 24;
    for (PFObject *object in objects) {
        
        content.lblTitle = object[@"title"];
        UILabel *summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 65, pageScroll.bounds.size.width - 48, 80)];
        [summaryLabel setFont:[UIFont fontWithName:@"Oswald-Bold" size:80.0f]];
        summaryLabel.textColor = [UIColor whiteColor];
        summaryLabel.backgroundColor = [UIColor clearColor];
        summaryLabel.textAlignment = NSTextAlignmentCenter;
        summaryLabel.text = [content.lblTitle uppercaseString];
        [pageScroll addSubview:summaryLabel];
        
        //Sample Image
        PFFile *testimonialFile = object[@"field_testimonial_customer_image_img"];
        [testimonialFile getDataInBackgroundWithBlock:^(NSData *sampleData, NSError *error) {
            UIImage *testimonialFileImg = [[UIImage alloc] initWithData:sampleData];
            UIImageView *testimonial = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, 176, 42)];
            [testimonial setImage:testimonialFileImg];
            [testimonial setUserInteractionEnabled:YES];
            testimonial.alpha = 1.0;
            testimonial.tag = 90;
            [pageScroll addSubview:testimonial];
        }];
        
        NSArray *bodyArray = [object objectForKey:@"body"];
        NSMutableDictionary *bodyDict = bodyArray[1];
        
        UIView *testimonialView = [[UIView alloc] initWithFrame:CGRectMake(x, 210, pageScroll.bounds.size.width - 48, 315)];
        testimonialView.layer.borderWidth = 1.0f;
        testimonialView.layer.borderColor = [UIColor whiteColor].CGColor;
        [pageScroll addSubview:testimonialView];
        
        UIScrollView *testimonialScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, testimonialView.bounds.size.width, testimonialView.bounds.size.height - 24)];
        [testimonialScroll setBackgroundColor:[UIColor clearColor]];
        [testimonialView addSubview:testimonialScroll];
        
        NSString *temp = [NSString stringWithFormat:@"%@", [bodyDict objectForKey:@"value"]];
        UILabel *testBody = [[UILabel alloc] initWithFrame:CGRectMake(24, 24, testimonialScroll.bounds.size.width - 48, 267)];
        testBody.numberOfLines = 0;
        NSMutableParagraphStyle *testBodyStyle  = [[NSMutableParagraphStyle alloc] init];
        testBodyStyle.minimumLineHeight = 30.0f;
        testBodyStyle.maximumLineHeight = 30.0f;
        NSDictionary *attributtes = @{NSParagraphStyleAttributeName : testBodyStyle,};
        testBody.attributedText = [[NSAttributedString alloc] initWithString:temp.stringByConvertingHTMLToPlainText attributes:attributtes];
        testBody.font = [UIFont fontWithName:@"AktivGrotesk-Regular" size:26.0f];
        testBody.backgroundColor = [UIColor clearColor];
        testBody.textColor = [UIColor whiteColor];
        [testBody sizeToFit];
        [testimonialScroll addSubview:testBody];
        
        [testimonialScroll setContentSize:CGSizeMake(testimonialScroll.bounds.size.width, testBody.frame.size.height)];

        NSArray *customerArray = [object objectForKey:@"field_testimonial_customer"];
        NSMutableDictionary *customerDict = customerArray[0];
        NSString *tempCustomer = [NSString stringWithFormat:@"%@", [customerDict objectForKey:@"value"]];
        
        UILabel *customer = [[UILabel alloc] initWithFrame:CGRectMake(x, 550, background.bounds.size.width - 48, 35)];
        [customer setFont:[UIFont fontWithName:@"AktivGrotesk-Regular" size:26.0]];
        customer.textColor = [UIColor whiteColor];
        [customer setBackgroundColor:[UIColor clearColor]];
        customer.numberOfLines = 1;
        customer.textAlignment = NSTextAlignmentLeft;
        customer.text = tempCustomer.stringByConvertingHTMLToPlainText;
        [pageScroll addSubview:customer];
        
        NSArray *subtitleArray = [object objectForKey:@"field_testimonial_subtitle"];
        NSMutableDictionary *subtitleDict = subtitleArray[0];
        NSString *tempSubtitle = [NSString stringWithFormat:@"%@", [subtitleDict objectForKey:@"value"]];
        
        UILabel *subtitle = [[UILabel alloc] initWithFrame:CGRectMake(x, 595, 790, 45)];
        NSMutableParagraphStyle *testSubTitleStyle  = [[NSMutableParagraphStyle alloc] init];
        testSubTitleStyle.minimumLineHeight = 22.0f;
        testSubTitleStyle.maximumLineHeight = 22.0f;
        NSDictionary *attributtesSubtitle = @{NSParagraphStyleAttributeName : testSubTitleStyle,};
        subtitle.attributedText = [[NSAttributedString alloc] initWithString:tempSubtitle.stringByConvertingHTMLToPlainText attributes:attributtesSubtitle];
        [subtitle setFont:[UIFont fontWithName:@"AktivGrotesk-Regular" size:18.0]];
        subtitle.textColor = [UIColor whiteColor];
        [subtitle setBackgroundColor:[UIColor clearColor]];
        subtitle.numberOfLines = 0;
        subtitle.lineBreakMode = NSLineBreakByWordWrapping;
        subtitle.textAlignment = NSTextAlignmentLeft;
        [pageScroll addSubview:subtitle];
        
        x += pageScroll.bounds.size.width;
    }
    
    if (objects.count > 1) {
        paginationDots = [[SMPageControl alloc] initWithFrame:CGRectMake(0, background.bounds.size.height - 50, background.bounds.size.width, 48)];
        paginationDots.numberOfPages = objects.count;
        paginationDots.backgroundColor = [UIColor clearColor];
        paginationDots.pageIndicatorImage = [UIImage imageNamed:@"ico-dot-inactive-white"];
        paginationDots.currentPageIndicatorImage = [UIImage imageNamed:@"ico-dot-active-white"];
        [background addSubview:paginationDots];
    }
    
    [pageScroll setContentSize:CGSizeMake(((background.bounds.size.width - 48) * objects.count), 400)];
}

//this function updates the dots for the current image the the user is on
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = pageScroll.bounds.size.width;
    //display the appropriate dot when scrolled
    NSInteger pageNumber = floor((pageScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    paginationDots.currentPage = pageNumber;
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

#pragma mark
#pragma mark - Reachability
- (BOOL)connected {
    
    //Check if there is an internet connection
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

#pragma mark
#pragma mark - Memory Management
- (void)removeEverything {
    for (UIView *v in [background subviews]) {
        [v removeFromSuperview];
    }
}
@end
