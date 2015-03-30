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
#import <Parse/Parse.h>

@interface TestimonialsViewController ()
@property (strong, nonatomic) UIView *background;
@property (strong, nonatomic) UIScrollView *pageScroll;
@property (strong, nonatomic) UIPageControl *caseStudyDots;
@end

@implementation TestimonialsViewController
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
    [background setBackgroundColor:[UIColor lightGrayColor]];
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
    
    UIImageView *header = [[UIImageView alloc] initWithFrame:CGRectMake(438, 20, 514, 60)];
    [header setImage:content.imgTest];
    [header setUserInteractionEnabled:YES];
    header.alpha = 1.0;
    header.tag = 90;
    [background addSubview:header];
}

- (void)viewWillAppear:(BOOL)animated {
    //NSUserDefaults to check if data has been downloaded.
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
- (void)fetchDataFromParse {
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

                        
                        NSMutableArray *selectedObjects = [[NSMutableArray alloc] init];
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        for (PFObject *object in objects) {
                            if ([[defaults objectForKey:[object objectForKey:@"nid"]] isEqualToString:@"show"]) {
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
        [self fetchDataFromLocalDataStore];
    }
}

//Query the local datastore to build the views
- (void)fetchDataFromLocalDataStore {
    //Query the Local Datastore
    PFQuery *query = [PFQuery queryWithClassName:@"testimonials"];
    [query fromLocalDatastore];
    [query whereKey:@"field_testimonial_tag_reference" equalTo:content.catagoryId];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *selectedObjects = [[NSMutableArray alloc] init];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        for (PFObject *object in objects) {
            if ([[defaults objectForKey:[object objectForKey:@"nid"]] isEqualToString:@"show"]) {
                [selectedObjects addObject:object];
            }
        }
        [self buildTestimonials:selectedObjects];
    }];
}

//this function updates the dots for the current image the the user is on
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = pageScroll.bounds.size.width;
    //display the appropriate dot when scrolled
    NSInteger pageNumber = floor((pageScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    caseStudyDots.currentPage = pageNumber;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark
#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
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
#pragma mark - Reachability
- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

#pragma mark
#pragma mark - Build View
- (void)buildTestimonials:(NSArray *)objects {
    pageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(56, 150, (background.bounds.size.width - (56 * 2)), 400)];
    pageScroll.showsHorizontalScrollIndicator = NO;
    pageScroll.showsVerticalScrollIndicator = YES;
    pageScroll.pagingEnabled = YES;
    pageScroll.scrollEnabled = YES;
    pageScroll.delegate = self;
    pageScroll.backgroundColor = [UIColor clearColor];
    [background addSubview:pageScroll];
    
    int x = 24;
    for (PFObject *object in objects) {
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
        NSMutableDictionary *bodyDict = [[NSMutableDictionary alloc] init];
        bodyDict = bodyArray[1];
        NSString *tempBody = [NSString stringWithFormat:@"%@", [bodyDict objectForKey:@"value"]];
        
        UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(x, 45, 790, 275)];
        text.editable = NO;
        text.clipsToBounds = YES;
        text.font = [UIFont fontWithName:@"NimbusSanD-Regu" size:18.0];
        text.backgroundColor = [UIColor clearColor];
        text.scrollEnabled = YES;
        text.textColor = [UIColor blackColor];
        text.text = tempBody.stringByConvertingHTMLToPlainText;
        [pageScroll addSubview:text];
        
        NSArray *customerArray = [object objectForKey:@"field_testimonial_customer"];
        NSMutableDictionary *customerDict = [[NSMutableDictionary alloc] init];
        customerDict = customerArray[0];
        NSString *tempCustomer = [NSString stringWithFormat:@"%@", [customerDict objectForKey:@"value"]];
        
        UILabel *customer = [[UILabel alloc] initWithFrame:CGRectMake(x, 325, 790, 20)];
        [customer setFont:[UIFont fontWithName:@"NimbusSanD-Bold" size:18.0]];
        customer.textColor = [UIColor blackColor];
        customer.numberOfLines = 1;
        customer.textAlignment = NSTextAlignmentLeft;
        customer.text = tempCustomer.stringByConvertingHTMLToPlainText;
        [pageScroll addSubview:customer];
        
        NSArray *subtitleArray = [object objectForKey:@"field_testimonial_subtitle"];
        NSMutableDictionary *subtitleDict = [[NSMutableDictionary alloc] init];
        subtitleDict = subtitleArray[0];
        NSString *tempSubtitle = [NSString stringWithFormat:@"%@", [subtitleDict objectForKey:@"value"]];
        
        UILabel *subtitle = [[UILabel alloc] initWithFrame:CGRectMake(x, 345, 790, 50)];
        [subtitle setFont:[UIFont fontWithName:@"NimbusSanD-Regu" size:18.0]];
        subtitle.textColor = [UIColor blackColor];
        [subtitle setNumberOfLines:2];
        subtitle.textAlignment = NSTextAlignmentLeft;
        subtitle.text = tempSubtitle.stringByConvertingHTMLToPlainText;
        [pageScroll addSubview:subtitle];
        
        caseStudyDots = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 676, 952, 20)];
        caseStudyDots.currentPage = 0;
        caseStudyDots.backgroundColor = [UIColor clearColor];
        caseStudyDots.pageIndicatorTintColor = [UIColor blackColor];
        caseStudyDots.currentPageIndicatorTintColor = [UIColor whiteColor];
        caseStudyDots.numberOfPages = objects.count;
        [background addSubview:caseStudyDots];
        
        [pageScroll setContentSize:CGSizeMake(((background.bounds.size.width - (56 * 2)) * objects.count), 400)];
        x += (background.bounds.size.width - (56 * 2));
    }
}
#pragma mark
#pragma mark - Memory Management
- (void)removeEverything {
    for (UIView *v in [background subviews]) {
        [v removeFromSuperview];
    }
}
@end
