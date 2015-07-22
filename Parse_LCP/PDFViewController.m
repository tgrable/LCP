//
//  PDFViewController.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 6/10/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "PDFViewController.h"
#import "Reachability.h"
#import "ParseDownload.h"
#import <Parse/Parse.h>

@interface PDFViewController ()
@property (strong, nonatomic) UIView *background;
@property (strong, nonatomic) UIWebView *webView;
@end

@implementation PDFViewController
@synthesize background;
@synthesize webView;

- (BOOL)prefersStatusBarHidden {
    //Hide status bar
    return YES;
}

#pragma mark
#pragma mark - ViewController Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
  
    //UIView 36 pixels smaller than the device bounds used to hold the rest of the view objects
    background = [[UIView alloc] initWithFrame:CGRectMake(36, 36, (self.view.bounds.size.width - (36 * 2)), (self.view.bounds.size.height - (36 * 2)))];
    [background setBackgroundColor:[UIColor lightGrayColor]];
    [background setUserInteractionEnabled:YES];
    [self.view addSubview:background];
    
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
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, background.bounds.size.width, background.bounds.size.height)];
    webView.delegate = self;
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;
    webView.scalesPageToFit = YES;
    webView.userInteractionEnabled = YES;
    webView.backgroundColor = [UIColor whiteColor];
    [background addSubview:webView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Check if data has been downloaded and pinned to local datastore.
    //If data has been downloaded pull from local datastore
    [self checkLocalDataStoreforData];
}

#pragma mark
#pragma mark - Parse
- (void)checkLocalDataStoreforData {
    PFQuery *query = [PFQuery queryWithClassName:@"pdf_slide_deck"];
    [query fromLocalDatastore];
    dispatch_async(dispatch_get_main_queue(), ^{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                if (objects.count > 0) {
                    [self fetchDataFromLocalDataStore];
                }
                else {
                    [self fetchDataFromParse];
                }
            }
        }];
    });
}

//Query the local datastore for case_study to build the views
- (void)fetchDataFromLocalDataStore {
    
    PFQuery *query = [PFQuery queryWithClassName:@"pdf_slide_deck"];
    [query fromLocalDatastore];
    dispatch_async(dispatch_get_main_queue(), ^{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            //Check which one is set to "show" and use those to build the view
            NSMutableArray *selectedObjects = [[NSMutableArray alloc] init];
            NSMutableDictionary *lcpPdfSlides = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lcpContent"] mutableCopy];
            
            for (PFObject *object in objects) {
                //Add selected objects the the array
                if ([[lcpPdfSlides objectForKey:[object objectForKey:@"nid"]] isEqualToString:@"show"]) {
                    [selectedObjects addObject:object];
                }
            }
            
            if (selectedObjects.count > 0) {
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSString *pathForFile = [self getDBPathPDf:[NSString stringWithFormat:@"%@.pdf", [selectedObjects[0] objectForKey:@"nid"]]];
                 
                if ([fileManager fileExistsAtPath:pathForFile]){
                    [self loadDocument:pathForFile inView:webView];
                }
                else {
                    [self buildPdfView:selectedObjects[0]];
                }
            }
        }];
    });
}

//Query the Parse.com for case_study to build the views
- (void)fetchDataFromParse {
    
    //Using Reachability check if there is an internet connection
    //If there is download term data from Parse.com if not alert the user there needs to be an internet connection
    if ([self connected]) {
        PFQuery *query = [PFQuery queryWithClassName:@"pdf_slide_deck"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    [PFObject pinAllInBackground:objects block:^(BOOL succeded, NSError *error) {
                        if (!error) {
                            NSUserDefaults *csDefaults = [NSUserDefaults standardUserDefaults];
                            [csDefaults setObject:@"hasData" forKey:@"case_study"];
                            [csDefaults synchronize];
                            
                            //Some case studies may have be disabled in the app dashboard
                            //Check which one are set to "show" and use those to build the view
                            NSMutableArray *selectedObjects = [[NSMutableArray alloc] init];
                            NSMutableDictionary *lcpCaseStudy = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lcpContent"] mutableCopy];
                            
                            //Add selected objects the the array
                            for (PFObject *object in objects) {
                                //Add selected objects the the array
                                if ([[lcpCaseStudy objectForKey:[object objectForKey:@"nid"]] isEqualToString:@"show"]) {
                                    [selectedObjects addObject:object];
                                }
                            }
                            if (selectedObjects.count > 0) {
                                
                                NSFileManager *fileManager = [NSFileManager defaultManager];
                                NSString *pathForFile = [self getDBPathPDf:[NSString stringWithFormat:@"%@.pdf", [selectedObjects[0] objectForKey:@"nid"]]];
                            
                                if ([fileManager fileExistsAtPath:pathForFile]){
                                    [self loadDocument:pathForFile inView:webView];
                                }
                                else {
                                    [self buildPdfView:selectedObjects[0]];
                                }
                            }
                        }
                    }];
                }
            }];
        });
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
#pragma mark - Build View
- (void)buildPdfView:(PFObject *)object {
    
    PFFile *pdfFile = object[@"field_file"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [pdfFile getDataInBackgroundWithBlock:^(NSData *pdfData, NSError *error) {
            if (!error) {
                
                NSString *path = [self getDBPathPDf:[NSString stringWithFormat:@"%@.pdf", [object objectForKey:@"nid"]]];
                
                [pdfData writeToFile:path atomically:YES];
                [self loadDocument:path inView:webView];
            }
        }];
    });
}

- (NSString *)getDBPathPDf:(NSString *)PdfName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:PdfName];
}

#pragma mark
#pragma mark - Load PDF
-(void)loadDocument:(NSString *)documentName inView:(UIWebView *)view {

    NSURL *url = [NSURL fileURLWithPath:documentName];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [view loadRequest:request];
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
#pragma mark - Navigation
- (void)backNav:(id)sender {
    
    // Send the presenter back to the BrandMeetsWorldViewController
    [self.navigationController popViewControllerAnimated:YES];
    [self removeEverything];
}

-(void)backToDashboard:(id)sender {
    
    // Send the presenter back to the dashboard
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self removeEverything];
}

#pragma mark
#pragma mark - Memory Management
- (void)removeEverything {
    //Loop through and remove all the views in background
    for (UIView *v in [self.view subviews]) {
        [v removeFromSuperview];
    }
}

@end
