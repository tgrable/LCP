//
//  ContentSettingsViewController.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 2/25/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "ContentSettingsViewController.h"
#import "LogoLoaderViewController.h"
#import "Reachability.h"
#import "LCPContent.h"
#import "ParseDownload.h"
#import <Parse/Parse.h>

@interface ContentSettingsViewController () {
    bool isCompanyLogoSelected;
    bool isContentSelected, isContentFavorited, lastObj;
    int senderTag;
}

@property (strong, nonatomic) UIView *background, *favoriteListView, *formSlidView, *loadingView;
@property (strong, nonatomic) UIImageView *contentSelectedFlag, *contentFavoritedFlag;
@property (strong, nonatomic) UIActivityIndicatorView *contentActivityIndicator, *activityIndicator;
@property (strong, nonatomic) UIScrollView *pContent ,*csContent, *sContent, *vContent, *tContent, *pdfContent;
@property (strong, nonatomic) UIScrollView *presentationContent, *emailContent;
@property (nonatomic) UISegmentedControl *contentSegController;
@property (strong, nonatomic) UITextField *email, *subject, *companyNameTextField;
@property (strong, nonatomic) UITextView *message;
@property (strong, nonatomic) UIButton *submitButton;
@property (strong, nonatomic) UIImage *companyLogo;
@property (strong, nonatomic) UILabel *currentlySelectedItemsLabel, *currentlyFavoritedItemsLabel;
@property NSMutableArray *favoritedNIDs;
@property NSMutableArray *termsArray, *companyLogoArray, *pdfNIDs;
@property NSMutableDictionary *posterDictionary, *navIconDictionary, *navTermDictionary, *navTidsDictionary;
@property NSMutableDictionary *lcpContent;
@property NSString *alertButtonPressed;

@property (strong, nonatomic) LCPContent *content;
@property (strong, nonatomic) SendEmail *emailObject;
@property (strong, nonatomic) ParseDownload *parsedownload;

@end

@implementation ContentSettingsViewController
@synthesize background, favoriteListView, formSlidView, loadingView;                    //UIView
@synthesize contentSelectedFlag, contentFavoritedFlag;
@synthesize contentActivityIndicator, activityIndicator;                                //UIActivityIndicatorView
@synthesize pContent, csContent, sContent, vContent, tContent, pdfContent;              //UIScrollView
@synthesize presentationContent, emailContent;                                          //UIScrollView
@synthesize contentSegController;                                                       //UISegmentedControl
@synthesize currentlySelectedItemsLabel, currentlyFavoritedItemsLabel;
@synthesize submitButton;                                                               //UIButons
@synthesize companyLogo;
@synthesize parsedownload, emailObject;                                                 //Custom Classes
@synthesize email, subject, companyNameTextField;                                       //Email textfields
@synthesize message;                                                                    //Email textview
@synthesize favoritedNIDs, termsArray, companyLogoArray, pdfNIDs;                       //NSMutableArray
@synthesize posterDictionary, navIconDictionary, navTermDictionary, navTidsDictionary;  //NSMutableDictionary
@synthesize lcpContent;                                                                 //NSMutableDictionary
@synthesize alertButtonPressed;                                                         //NSString
@synthesize content;                                                                    //LCPContent

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark -
#pragma mark - View Life Cycle
- (void)viewDidLoad {
    
    // TODO: Fix the bundle id currently com.trekk.dev-prod... Should be com.trekk.prod 
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    //NSNotificationCenter reciever to redraw the view once the data have been downloaded from Parse & Rackspace
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redrawView:) name:@"RefreshParseData" object:nil];

    termsArray = [[NSMutableArray alloc] init];
    favoritedNIDs = [NSMutableArray array];
    emailObject = [[SendEmail alloc] init];
    emailObject.delegate = self;
    content = [[LCPContent alloc] init];
    parsedownload = [[ParseDownload alloc] init];
    posterDictionary = [[NSMutableDictionary alloc] init];
    navIconDictionary = [[NSMutableDictionary alloc] init];
    navTermDictionary = [[NSMutableDictionary alloc] init];
    navTidsDictionary = [[NSMutableDictionary alloc] init];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"lcpContent"] != nil) {
        lcpContent = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lcpContent"] mutableCopy];
        
    }
    else {
        lcpContent = [[NSMutableDictionary alloc] init];
    }

    background = [[UIView alloc] initWithFrame:CGRectMake(36, 36, (self.view.bounds.size.width - (36 * 2)), (self.view.bounds.size.height - (36 * 2)))];
    [background setBackgroundColor:[UIColor colorWithRed:115.0f/255.0f green:115.0f/255.0f blue:115.0f/255.0f alpha:1.0]];
    [background setUserInteractionEnabled:YES];
    [self.view addSubview:background];
    
    UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoButton setFrame:CGRectMake(60, 6.5f, 70, 23)];
    logoButton.showsTouchWhenHighlighted = YES;
    [logoButton setBackgroundImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
    [self.view addSubview:logoButton];
    
    contentSegController = [[UISegmentedControl alloc]initWithItems:@[@"Presentation", @"Case Studies", @"Samples", @"Videos", @"Testimonials", @"PDF Slides", @"Email"]];
    contentSegController.frame = CGRectMake(60, 56, self.view.bounds.size.width - 120, 33);
    [contentSegController addTarget:self action:@selector(segmentedControlValueDidChange:) forControlEvents:UIControlEventValueChanged];
    [contentSegController setSelectedSegmentIndex:0];
    [contentSegController setTintColor:[UIColor whiteColor]];
    [self.view addSubview:contentSegController];
    
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [startButton setFrame:CGRectMake((self.view.bounds.size.width - 170), 0, 45, 45)];
    [startButton addTarget:self action:@selector(startPresentation:)forControlEvents:UIControlEventTouchUpInside];
    startButton.showsTouchWhenHighlighted = YES;
    [startButton setBackgroundImage:[UIImage imageNamed:@"ico-play"] forState:UIControlStateNormal];
    startButton.layer.cornerRadius = (45/2);
    startButton.layer.masksToBounds = YES;
    startButton.backgroundColor = [UIColor clearColor];
    [startButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:startButton];
    
    UIButton *clearLocalDataButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [clearLocalDataButton setFrame:CGRectMake((self.view.bounds.size.width - 105), 0, 45, 45)];
    [clearLocalDataButton addTarget:self action:@selector(reloadEverything:)forControlEvents:UIControlEventTouchUpInside];
    clearLocalDataButton.showsTouchWhenHighlighted = YES;
    [clearLocalDataButton setBackgroundImage:[UIImage imageNamed:@"ico-refresh"] forState:UIControlStateNormal];
    clearLocalDataButton.backgroundColor = [UIColor clearColor];
    [clearLocalDataButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:clearLocalDataButton];
    
    presentationContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 115, background.bounds.size.width, (background.bounds.size.height - 115))];
    [presentationContent setBackgroundColor:[UIColor clearColor]];
    [presentationContent setUserInteractionEnabled:YES];
    presentationContent.showsVerticalScrollIndicator = YES;
    [background addSubview:presentationContent];
    
    emailContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 115, background.bounds.size.width, (background.bounds.size.height - 115))];
    [emailContent setBackgroundColor:[UIColor clearColor]];
    [emailContent setUserInteractionEnabled:YES];
    emailContent.showsVerticalScrollIndicator = YES;
    emailContent.hidden = YES;
    emailContent.tag = 212;
    [background addSubview:emailContent];

    [self buildPresentationView];
    [self buildEmailView];
    [self drawViews];
    
    contentActivityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    contentActivityIndicator.frame = CGRectMake(145, 7, 26, 26);
    contentActivityIndicator.transform = CGAffineTransformMakeScale(0.65, 0.65);
    [contentActivityIndicator setColor:[UIColor blackColor]];
    contentActivityIndicator.hidesWhenStopped = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //build email view is executed here so that the list is always refreshed
    [self refreshEmailList];
    [self checkIfContentIsFavorited];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark - Parse
//Query parse.com for class and sort on field_term_reference
//Then pin all objects and call buildOptions:forView:withTerm: to build view
- (void)fetchDataFromParse:(NSString *)forParseClassType andSortedBy:(NSString *)tagReference {
    if ([self connected]) {
        PFQuery *query = [PFQuery queryWithClassName:forParseClassType];
        [query orderByAscending:tagReference];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [PFObject pinAllInBackground:objects block:^(BOOL succeded, NSError *error) {
                        if (succeded) {
                            
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            [defaults setObject:@"hasData" forKey:forParseClassType];
                            [defaults synchronize];
                            if ([forParseClassType isEqualToString:@"pdf_slide_deck"]) {
                                [self createpdfNIDArray:objects];
                            }
                            [self buildOptions:objects forView:forParseClassType withTerm:tagReference];
                        }
                    }];
                });
            }
            else {
                NSString *errorMsg = [NSString stringWithFormat:@"%@", error];
                NSLog(@"%s [Line %d] -- Error: %@ %@",__PRETTY_FUNCTION__, __LINE__,  error, [error userInfo]);
                [self displayMessage:errorMsg];
            }
        }];
    }
    else {
        [self fetchDataFromLocalDataStore:forParseClassType andSortedBy:tagReference];
    }
}

//Query local data store for class and sort on field_term_reference
//Then pin all objects and call buildOptions:forView:withTerm: to build view
- (void)fetchDataFromLocalDataStore:(NSString *)forParseClassType andSortedBy:(NSString *)tagReference {
    PFQuery *query = [PFQuery queryWithClassName:forParseClassType];
    [query fromLocalDatastore];
    //[query orderByAscending:tagReference];
    dispatch_async(dispatch_get_main_queue(), ^{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                if ([forParseClassType isEqualToString:@"pdf_slide_deck"]) {
                    [self createpdfNIDArray:objects];
                }
                [self buildOptions:objects forView:forParseClassType withTerm:tagReference];
            }
            else {
                NSString *errorMsg = [NSString stringWithFormat:@"%@", error];
                NSLog(@"%s [Line %d] -- Error: %@ %@",__PRETTY_FUNCTION__, __LINE__,  error, [error userInfo]);
                [self displayMessage:errorMsg];
            }
        }];
    });
}

//This method is called first to get all the parse.com class "terms" before we grab the rest of the classes
- (void)fetchTerms {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"term"] isEqualToString:@"hasData"]) {
        PFQuery *query = [PFQuery queryWithClassName:@"term"];
        [query fromLocalDatastore];
        [query orderByAscending:@"tid"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                for (PFObject *object in objects) {
                    [termsArray addObject:object];
                }
                NSLog(@"TrekkAdmin: %lu", (unsigned long)termsArray.count);
                [self fetchRemainingObjectsFromParse];
            }
            else {
                NSString *errorMsg = [NSString stringWithFormat:@"%@", error];
                NSLog(@"%s [Line %d] -- Error: %@ %@",__PRETTY_FUNCTION__, __LINE__,  error, [error userInfo]);
                [self displayMessage:errorMsg];
            }
        }];
    }
    else {
        PFQuery *query = [PFQuery queryWithClassName:@"term"];
        [query orderByAscending:@"tid"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                [PFObject pinAllInBackground:objects block:^(BOOL succeded, NSError *error) {
                    if (succeded) {
                        for (PFObject *object in objects) {
                            [termsArray addObject:object];
                        }
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setObject:@"hasData" forKey:@"term"];
                        [defaults synchronize];

                        [self fetchRemainingObjectsFromParse];
                    }
                    else {
                        NSString *errorMsg = [NSString stringWithFormat:@"%@", error];
                        [self displayMessage:errorMsg];
                    }
                }];
            }
            else {
                NSString *errorMsg = [NSString stringWithFormat:@"%@", error];
                NSLog(@"%s [Line %d] -- Error: %@ %@",__PRETTY_FUNCTION__, __LINE__,  error, [error userInfo]);
                [self displayMessage:errorMsg];
            }
        }];
        
    }
}

- (void)fetchRemainingObjectsFromParse {
    //NSUserDefaults to check if data has been downloaded.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *parseClasses = @[@"case_study", @"samples", @"video", @"testimonials", @"pdf_slide_deck"];

    for (NSString *parseClass in parseClasses) {
        /*if ([[defaults objectForKey:parseClass] isEqualToString:@"hasData"]) {
            [self fetchDataFromLocalDataStore:parseClass andSortedBy:@"field_term_reference"];
        }
        else {
            [self fetchDataFromParse:parseClass andSortedBy:@"field_term_reference"];
        }*/
        
        PFQuery *query = [PFQuery queryWithClassName:parseClass];
        [query fromLocalDatastore];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                NSLog(@"%s [Line %d] -- %@ objects.count == %lu",__PRETTY_FUNCTION__, __LINE__, parseClass, (unsigned long)objects.count);
                if (objects.count == 0) {
                    [self fetchDataFromParse:parseClass andSortedBy:@"field_term_reference"];
                }
                else {
                    [self fetchDataFromLocalDataStore:parseClass andSortedBy:@"field_term_reference"];
                }
            }
        }];

        
    }
    
    if (![[defaults objectForKey:@"video"] isEqualToString:@"hasData"]) {
        [parsedownload downloadVideoFile:self.view forTerm:@""];
    }
    
    /*
    if (![[defaults objectForKey:@"overview"] isEqualToString:@"hasData"]) {
        [parsedownload downloadAndPinIndividualParseClass:@"overview"];
    }
    if (![[defaults objectForKey:@"splash_screen"] isEqualToString:@"hasData"]) {
        [parsedownload downloadAndPinIndividualParseClass:@"case_study_media"];
    }
    if (![[defaults objectForKey:@"team_member"] isEqualToString:@"hasData"]) {
        [parsedownload downloadAndPinIndividualParseClass:@"team_member"];
    }
    if (![[defaults objectForKey:@"splash_screen"] isEqualToString:@"hasData"]) {
        [parsedownload downloadAndPinIndividualParseClass:@"splash_screen"];
    }
    if (![[defaults objectForKey:@"company_logo"] isEqualToString:@"hasData"]) {
        [parsedownload downloadAndPinIndividualParseClass:@"company_logo"];
    }*/
    
    [self checkIfParseClassContentHasBeenPinned:@"case_study_media"];
    [self checkIfParseClassContentHasBeenPinned:@"overview"];
    [self checkIfParseClassContentHasBeenPinned:@"team_member"];
    [self checkIfParseClassContentHasBeenPinned:@"splash_screen"];
    [self checkIfParseClassContentHasBeenPinned:@"company_logo"];
}

- (void)checkIfParseClassContentHasBeenPinned:(NSString *)parseClass {
    PFQuery *query = [PFQuery queryWithClassName:parseClass];
    [query fromLocalDatastore];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"%s [Line %d] -- %@ objects.count == %lu",__PRETTY_FUNCTION__, __LINE__, parseClass, (unsigned long)objects.count);
            if (objects.count == 0) {
                [parsedownload downloadAndPinIndividualParseClass:parseClass];
            }
        }
    }];
}

- (void)fetchPosterImage {
    PFQuery *query = [PFQuery queryWithClassName:@"splash_screen"];
    query.limit = 1;
    [query fromLocalDatastore];
    [query orderByAscending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count > 0) {
                for (PFObject *object in objects) {
                    PFFile *imageFile = [object objectForKey:@"field_background_image_img"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                            UIImage *posterImg = [[UIImage alloc] initWithData:imageData];
                            [posterDictionary setObject:posterImg forKey:[object objectForKey:@"nid"]];
                        }];
                    });
                }
            }
            else {
                PFQuery *query = [PFQuery queryWithClassName:@"splash_screen"];
                query.limit = 1;
                [query orderByAscending:@"updatedAt"];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        if (objects.count > 0) {
                            for (PFObject *object in objects) {
                                PFFile *imageFile = [object objectForKey:@"field_background_image_img"];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                                        UIImage *posterImg = [[UIImage alloc] initWithData:imageData];
                                        [posterDictionary setObject:posterImg forKey:[object objectForKey:@"nid"]];
                                    }];
                                });
                            }
                        }
                    }
                }];
            }
        }
        else {
           NSLog(@"%s [Line %d] -- Error: %@ %@",__PRETTY_FUNCTION__, __LINE__,  error, [error userInfo]);
        }
    }];
}

- (void)fetchNavIcons {
    PFQuery *query = [PFQuery queryWithClassName:@"term"];
    [query whereKey:@"parent" equalTo:@"0"];
    [query fromLocalDatastore];
    [query orderByAscending:@"weight"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                if (objects.count > 0) {
                    for (PFObject *object in objects) {
                        PFFile *imageFile = [object objectForKey:@"field_button_image_img"];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                                UIImage *iconImg = [[UIImage alloc] initWithData:imageData];
                                [navIconDictionary setObject:iconImg forKey:[object objectForKey:@"weight"]];
                                [navTermDictionary setObject:[object objectForKey:@"name"] forKey:[object objectForKey:@"weight"]];
                                [navTidsDictionary setObject:[object objectForKey:@"tid"] forKey:[object objectForKey:@"weight"]];
                            }];
                        });
                    }
                }
                else {
                    PFQuery *query = [PFQuery queryWithClassName:@"term"];
                    [query whereKey:@"parent" equalTo:@"0"];
                    [query orderByAscending:@"weight"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            if (!error) {
                                if (objects.count > 0) {
                                    for (PFObject *object in objects) {
                                        PFFile *imageFile = [object objectForKey:@"field_button_image_img"];
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                                                UIImage *iconImg = [[UIImage alloc] initWithData:imageData];
                                                [navIconDictionary setObject:iconImg forKey:[object objectForKey:@"weight"]];
                                                [navTermDictionary setObject:[object objectForKey:@"name"] forKey:[object objectForKey:@"weight"]];
                                                [navTidsDictionary setObject:[object objectForKey:@"tid"] forKey:[object objectForKey:@"weight"]];
                                            }];
                                        });
                                    }
                                }
                            }
                        }];
                    });
                }
                
            } else {
                NSLog(@"%s [Line %d] -- Error: %@ %@",__PRETTY_FUNCTION__, __LINE__,  error, [error userInfo]);
            }
        }];
    });
}

- (void)fetchCompanyLogos {
    PFQuery *query = [PFQuery queryWithClassName:@"company_logo"];
    [query fromLocalDatastore];
    [query orderByAscending:@"title"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                if (objects.count > 0) {
                    [self buildCompanyLogo:objects];
                }
                else {
                    PFQuery *query = [PFQuery queryWithClassName:@"company_logo"];
                    [query orderByAscending:@"title"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            if (!error) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [PFObject pinAllInBackground:objects block:^(BOOL succeded, NSError *error) {
                                        if (!error) {
                                            if (objects.count > 0) {
                                                [self buildCompanyLogo:objects];
                                            }
                                        }
                                    }];
                                });
                            }
                        }];
                    });
                }
            }
            else {
                NSLog(@"%s [Line %d] -- Error: %@ %@",__PRETTY_FUNCTION__, __LINE__,  error, [error userInfo]);
            }
        }];
    });
}

#pragma mark -
#pragma mark - Build View
- (void)drawViews {
    //First Page Summary View
    pContent = [[UIScrollView alloc] initWithFrame:CGRectMake(24, 150, 400, (presentationContent.bounds.size.height - 160))];
    [pContent setBackgroundColor:[UIColor clearColor]];
    [pContent setUserInteractionEnabled:YES];
    pContent.showsVerticalScrollIndicator = YES;
    pContent.hidden = NO;
    [presentationContent addSubview:pContent];
    
    csContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 105, background.bounds.size.width, (background.bounds.size.height - 115))];
    [csContent setBackgroundColor:[UIColor clearColor]];
    [csContent setUserInteractionEnabled:YES];
    csContent.showsVerticalScrollIndicator = YES;
    csContent.hidden = YES;
    [background addSubview:csContent];
    
    sContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 105, background.bounds.size.width, (background.bounds.size.height - 115))];
    [sContent setBackgroundColor:[UIColor clearColor]];
    [sContent setUserInteractionEnabled:YES];
    sContent.hidden = YES;
    sContent.showsVerticalScrollIndicator = YES;
    [background addSubview:sContent];
    
    vContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 105, background.bounds.size.width, (background.bounds.size.height - 115))];
    [vContent setBackgroundColor:[UIColor clearColor]];
    [vContent setUserInteractionEnabled:YES];
    vContent.hidden = YES;
    vContent.showsVerticalScrollIndicator = YES;
    [background addSubview:vContent];
    
    tContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 105, background.bounds.size.width, (background.bounds.size.height - 115))];
    [tContent setBackgroundColor:[UIColor clearColor]];
    [tContent setUserInteractionEnabled:YES];
    tContent.hidden = YES;
    tContent.showsVerticalScrollIndicator = YES;
    [background addSubview:tContent];
    
    pdfContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 105, background.bounds.size.width, (background.bounds.size.height - 115))];
    [pdfContent setBackgroundColor:[UIColor clearColor]];
    [pdfContent setUserInteractionEnabled:YES];
    pdfContent.hidden = YES;
    pdfContent.showsVerticalScrollIndicator = YES;
    [background addSubview:pdfContent];
    
    [self fetchPosterImage];
    [self fetchNavIcons];
    [self fetchCompanyLogos];
    [self fetchTerms];
}

- (void)buildEmailView {
    /*** Start of email views ***/
    
    UITapGestureRecognizer *tapAwayFromFormRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEmailView:)];
    [tapAwayFromFormRecognizer setNumberOfTapsRequired:1];
    [tapAwayFromFormRecognizer setNumberOfTouchesRequired:1];
    [emailContent addGestureRecognizer:tapAwayFromFormRecognizer];
    
    formSlidView = [[UIView alloc] initWithFrame:CGRectMake(160, 0, 685, 600)];
    formSlidView.backgroundColor = [UIColor clearColor];
    formSlidView.userInteractionEnabled = YES;
    formSlidView.tag = 213;
    [emailContent addSubview:formSlidView];
    
    UILabel *instructionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 685, 24)];
    instructionLabel.font = [UIFont fontWithName:@"Oswald" size:19.0];
    instructionLabel.textColor = [UIColor whiteColor];
    instructionLabel.userInteractionEnabled = YES;
    instructionLabel.numberOfLines = 1;
    instructionLabel.backgroundColor = [UIColor clearColor];
    instructionLabel.textAlignment = NSTextAlignmentLeft;
    instructionLabel.text = @"Optionally send an email with notes and favorited content from your presentation.";
    [formSlidView addSubview:instructionLabel];
    
    UILabel *emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 685, 24)];
    emailLabel.font = [UIFont fontWithName:@"Oswald" size:19.0];
    emailLabel.textColor = [UIColor whiteColor];
    emailLabel.userInteractionEnabled = YES;
    emailLabel.numberOfLines = 1;
    emailLabel.backgroundColor = [UIColor clearColor];
    emailLabel.textAlignment = NSTextAlignmentLeft;
    emailLabel.text = @"Email";
    [formSlidView addSubview:emailLabel];
    
    email = [[UITextField alloc] initWithFrame:CGRectMake(0, 64, 685, 32)];
    email.font = [UIFont fontWithName:@"Oswald" size:19.0];
    [email setBackgroundColor:[UIColor whiteColor]];
    email.enablesReturnKeyAutomatically = YES;
    email.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [email setAutocorrectionType:UITextAutocorrectionTypeNo];
    [email setReturnKeyType:UIReturnKeyNext];
    email.delegate = self;
    email.textColor = [UIColor blackColor];
    [formSlidView addSubview:email];
    
    UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 110, 685, 24)];
    subjectLabel.font = [UIFont fontWithName:@"Oswald" size:19.0];
    subjectLabel.textColor = [UIColor whiteColor];
    subjectLabel.userInteractionEnabled = YES;
    subjectLabel.numberOfLines = 1;
    subjectLabel.backgroundColor = [UIColor clearColor];
    subjectLabel.textAlignment = NSTextAlignmentLeft;
    subjectLabel.text = @"Email Subject";
    [formSlidView addSubview:subjectLabel];
    
    subject = [[UITextField alloc] initWithFrame:CGRectMake(0, 134, 685, 32)];
    subject.font = [UIFont fontWithName:@"Oswald" size:19.0];
    [subject setBackgroundColor:[UIColor whiteColor]];
    subject.enablesReturnKeyAutomatically = YES;
    [subject setReturnKeyType:UIReturnKeyNext];;
    subject.delegate = self;
    subject.textColor = [UIColor blackColor];
    [formSlidView addSubview:subject];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 180, 685, 24)];
    messageLabel.font = [UIFont fontWithName:@"Oswald" size:19.0];
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.userInteractionEnabled = YES;
    messageLabel.numberOfLines = 1;
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.textAlignment = NSTextAlignmentLeft;
    messageLabel.text = @"Email Message";
    [formSlidView addSubview:messageLabel];
    
    message = [[UITextView alloc] initWithFrame:CGRectMake(0, 206, 685, 144)];
    message.font = [UIFont fontWithName:@"Oswald" size:18.0];
    [message setBackgroundColor:[UIColor whiteColor]];
    message.enablesReturnKeyAutomatically = YES;
    message.text = @"";
    message.delegate = self;
    message.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [message setReturnKeyType:UIReturnKeySend];
    message.textColor = [UIColor blackColor];
    [formSlidView addSubview:message];
    
    submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    submitButton.titleLabel.font = [UIFont fontWithName:@"Oswald" size:19];
    [submitButton setFrame:CGRectMake(0, 370, 108, 33)];
    [submitButton addTarget:self action:@selector(submitEmail:)forControlEvents:UIControlEventTouchUpInside];
    submitButton.showsTouchWhenHighlighted = YES;
    [submitButton setTitle:@"Submit" forState:UIControlStateNormal];
    submitButton.backgroundColor = [UIColor whiteColor];
    [submitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [formSlidView addSubview:submitButton];
    
    UIView *horizontalDivider = [[UIView alloc] initWithFrame:CGRectMake(160, 421, 685, 1)];
    horizontalDivider.backgroundColor = [UIColor whiteColor];
    [emailContent addSubview:horizontalDivider];
    
    UILabel *favoritedContent = [[UILabel alloc] initWithFrame:CGRectMake(160, 440, 685, 24)];
    favoritedContent.font = [UIFont fontWithName:@"Oswald" size:19.0];
    favoritedContent.textColor = [UIColor whiteColor];
    favoritedContent.numberOfLines = 1;
    favoritedContent.backgroundColor = [UIColor clearColor];
    favoritedContent.textAlignment = NSTextAlignmentLeft;
    favoritedContent.text = @"FAVORITED CONTENT ATTACHED TO THE EMAIL";
    [emailContent addSubview:favoritedContent];
    
    favoriteListView = [[UIView alloc] initWithFrame:CGRectMake(160, 470, 685, 0)];
    [emailContent addSubview:favoriteListView];
    
    /*** /End of email views ***/
    
    /* Loading View */
    loadingView = [[UIView alloc] initWithFrame:CGRectMake(462, 250, 100, 100)];
    loadingView.alpha = 0.0;
    loadingView.layer.cornerRadius = 5;
    loadingView.layer.masksToBounds = YES;
    loadingView.backgroundColor = [UIColor blackColor];
    [background addSubview:loadingView];
    
    activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.frame = CGRectMake(32.0, 32.0, 35.0, 35.0);
    [activityIndicator setColor:[UIColor whiteColor]];
    activityIndicator.alpha = 1.0;
    [activityIndicator startAnimating];
    [loadingView addSubview:activityIndicator];
}

//Once all data has been downloaded NSNotification is posted and this method is called to redraw the view.
- (void)redrawView:(NSNotification *)notification {
    [self removeEverything];
    [self drawViews];
    [self fetchPosterImage];
    [self fetchNavIcons];
    [contentActivityIndicator stopAnimating];
}

-(void)buildPresentationView {
    UILabel *companyNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 0, 200, 40)];
    companyNameLabel.textColor = [UIColor whiteColor];
    companyNameLabel.font = [UIFont fontWithName:@"Oswald" size:20];
    companyNameLabel.numberOfLines = 1;
    companyNameLabel.backgroundColor = [UIColor clearColor];
    companyNameLabel.textAlignment = NSTextAlignmentLeft;
    companyNameLabel.text = @"Enter Company Name:";
    [presentationContent addSubview:companyNameLabel];
    
    companyNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(24, 50, 400, 40)];
    companyNameTextField.textColor = [UIColor blackColor];
    companyNameTextField.font = [UIFont fontWithName:@"Oswald" size:15];
    companyNameTextField.backgroundColor = [UIColor whiteColor];
    [companyNameTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [companyNameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [presentationContent addSubview:companyNameTextField];
    
    UILabel *companyLogoLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 100, 200, 40)];
    companyLogoLabel.textColor = [UIColor whiteColor];
    companyLogoLabel.font = [UIFont fontWithName:@"Oswald" size:20];
    companyLogoLabel.numberOfLines = 1;
    companyLogoLabel.backgroundColor = [UIColor clearColor];
    companyLogoLabel.textAlignment = NSTextAlignmentLeft;
    companyLogoLabel.text = @"Select Company Logo:";
    [presentationContent addSubview:companyLogoLabel];

   
    UILabel *resetLCPContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((background.bounds.size.width / 2) + 24, 0, background.bounds.size.width, 40)];
    resetLCPContentLabel.textColor = [UIColor whiteColor];
    resetLCPContentLabel.font = [UIFont fontWithName:@"Oswald" size:20];
    resetLCPContentLabel.numberOfLines = 1;
    resetLCPContentLabel.backgroundColor = [UIColor clearColor];
    resetLCPContentLabel.textAlignment = NSTextAlignmentLeft;
    resetLCPContentLabel.text = @"Refresh LCP Content:";
    [presentationContent addSubview:resetLCPContentLabel];
    
    UIButton *resetLCPContent = [[UIButton alloc] initWithFrame:CGRectMake((background.bounds.size.width / 2) + 24, 50, 400, 50)];
    resetLCPContent.backgroundColor = [UIColor clearColor];
    [resetLCPContent setTitle:@"Refresh" forState:UIControlStateNormal];
    [resetLCPContent.layer setBorderWidth:1.0f];
    [resetLCPContent.layer setBorderColor:[UIColor whiteColor].CGColor];
    [resetLCPContent addTarget:self action:@selector(reloadLocalDataStore:)forControlEvents:UIControlEventTouchUpInside];
    resetLCPContent.showsTouchWhenHighlighted = YES;
    [resetLCPContent setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    resetLCPContent.titleLabel.font = [UIFont fontWithName:@"Oswald" size:20];
    [presentationContent addSubview:resetLCPContent];
    
    UILabel *resetLCPVideoLabel = [[UILabel alloc] initWithFrame:CGRectMake((background.bounds.size.width / 2) + 24, 100, background.bounds.size.width, 40)];
    resetLCPVideoLabel.textColor = [UIColor whiteColor];
    resetLCPVideoLabel.font = [UIFont fontWithName:@"Oswald" size:20];
    resetLCPVideoLabel.numberOfLines = 1;
    resetLCPVideoLabel.backgroundColor = [UIColor clearColor];
    resetLCPVideoLabel.textAlignment = NSTextAlignmentLeft;
    resetLCPVideoLabel.text = @"Reload LCP Videos:";
    [presentationContent addSubview:resetLCPVideoLabel];
    
    UIButton *resetLCPVideo = [[UIButton alloc] initWithFrame:CGRectMake((background.bounds.size.width / 2) + 24, 150, 400, 50)];
    resetLCPVideo.backgroundColor = [UIColor clearColor];
    [resetLCPVideo setTitle:@"Refresh" forState:UIControlStateNormal];
    [resetLCPVideo.layer setBorderWidth:1.0f];
    [resetLCPVideo.layer setBorderColor:[UIColor whiteColor].CGColor];
    [resetLCPVideo addTarget:self action:@selector(reloadVideoContent:)forControlEvents:UIControlEventTouchUpInside];
    resetLCPVideo.showsTouchWhenHighlighted = YES;
    [resetLCPVideo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    resetLCPVideo.titleLabel.font = [UIFont fontWithName:@"Oswald" size:20];
    [presentationContent addSubview:resetLCPVideo];
    
    UILabel *resetFavoritesLabel = [[UILabel alloc] initWithFrame:CGRectMake((background.bounds.size.width / 2) + 24, 210, background.bounds.size.width, 40)];
    resetFavoritesLabel.textColor = [UIColor whiteColor];
    resetFavoritesLabel.font = [UIFont fontWithName:@"Oswald" size:20];
    resetFavoritesLabel.numberOfLines = 1;
    resetFavoritesLabel.backgroundColor = [UIColor clearColor];
    resetFavoritesLabel.textAlignment = NSTextAlignmentLeft;
    resetFavoritesLabel.text = @"Reset Previously Favorited Content:";
    [presentationContent addSubview:resetFavoritesLabel];
    
    UIButton *resetFavButton = [[UIButton alloc] initWithFrame:CGRectMake((background.bounds.size.width / 2) + 24, 260, 400, 50)];
    resetFavButton.backgroundColor = [UIColor clearColor];
    [resetFavButton setTitle:@"Reset" forState:UIControlStateNormal];
    [resetFavButton.layer setBorderWidth:1.0f];
    [resetFavButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [resetFavButton addTarget:self action:@selector(resetAllFavoritedContent:)forControlEvents:UIControlEventTouchUpInside];
    resetFavButton.showsTouchWhenHighlighted = YES;
    [resetFavButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    resetFavButton.titleLabel.font = [UIFont fontWithName:@"Oswald" size:20];
    [presentationContent addSubview:resetFavButton];
    
    UILabel *resetSelectedLabel = [[UILabel alloc] initWithFrame:CGRectMake((background.bounds.size.width / 2) + 24, 320, background.bounds.size.width, 40)];
    resetSelectedLabel.textColor = [UIColor whiteColor];
    resetSelectedLabel.font = [UIFont fontWithName:@"Oswald" size:20];
    resetSelectedLabel.numberOfLines = 1;
    resetSelectedLabel.backgroundColor = [UIColor clearColor];
    resetSelectedLabel.textAlignment = NSTextAlignmentLeft;
    resetSelectedLabel.text = @"Reset Previously Selected Content:";
    [presentationContent addSubview:resetSelectedLabel];
    
    UIButton *resetSelectedButton = [[UIButton alloc] initWithFrame:CGRectMake((background.bounds.size.width / 2) + 24, 370, 400, 50)];
    resetSelectedButton.backgroundColor = [UIColor clearColor];
    [resetSelectedButton setTitle:@"Reset" forState:UIControlStateNormal];
    [resetSelectedButton.layer setBorderWidth:1.0f];
    [resetSelectedButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [resetSelectedButton addTarget:self action:@selector(resetAllSelectedContent:)forControlEvents:UIControlEventTouchUpInside];
    resetSelectedButton.showsTouchWhenHighlighted = YES;
    [resetSelectedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    resetSelectedButton.titleLabel.font = [UIFont fontWithName:@"Oswald" size:20];
    [presentationContent addSubview:resetSelectedButton];
    
    UIView *selectedContentDivider = [[UIView alloc] initWithFrame:CGRectMake((background.bounds.size.width / 2) + 24, 450, 400, 2)];
    [selectedContentDivider setBackgroundColor:[UIColor whiteColor]];
    [presentationContent addSubview:selectedContentDivider];
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
    
    UILabel *versionNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake((background.bounds.size.width / 2) + 180, 475, 400, 40)];
    versionNumberLabel.textColor = [UIColor whiteColor];
    versionNumberLabel.font = [UIFont fontWithName:@"Oswald" size:20];
    versionNumberLabel.numberOfLines = 1;
    versionNumberLabel.backgroundColor = [UIColor clearColor];
    versionNumberLabel.textAlignment = NSTextAlignmentLeft;
    versionNumberLabel.text = [NSString stringWithFormat:@"Version: %@", version];
    [presentationContent addSubview:versionNumberLabel];
    
    currentlyFavoritedItemsLabel = [[UILabel alloc] initWithFrame:CGRectMake((background.bounds.size.width / 2) + 60, 460, 400, 40)];
    currentlyFavoritedItemsLabel.textColor = [UIColor whiteColor];
    currentlyFavoritedItemsLabel.font = [UIFont fontWithName:@"Oswald" size:20];
    currentlyFavoritedItemsLabel.numberOfLines = 1;
    currentlyFavoritedItemsLabel.backgroundColor = [UIColor clearColor];
    currentlyFavoritedItemsLabel.textAlignment = NSTextAlignmentLeft;
    currentlyFavoritedItemsLabel.text = @"You currently have favorited items";
    
    contentFavoritedFlag = [[UIImageView alloc] initWithFrame:CGRectMake((background.bounds.size.width / 2) + 24, 470, 25, 25)];
    contentFavoritedFlag.image = [UIImage imageNamed:@"flag"];
    
    currentlySelectedItemsLabel = [[UILabel alloc] init];
    currentlySelectedItemsLabel.textColor = [UIColor whiteColor];
    currentlySelectedItemsLabel.font = [UIFont fontWithName:@"Oswald" size:20];
    currentlySelectedItemsLabel.numberOfLines = 1;
    currentlySelectedItemsLabel.backgroundColor = [UIColor clearColor];
    currentlySelectedItemsLabel.textAlignment = NSTextAlignmentLeft;
    currentlySelectedItemsLabel.text = @"You currently have selected items";
    
    contentSelectedFlag = [[UIImageView alloc] init];
    contentSelectedFlag.image = [UIImage imageNamed:@"flag"];
}

- (void)buildOptions:(NSArray *)objects forView:(NSString *)contentView withTerm:(NSString *)tagReference {
    int y = 0;
    
    //local variables used check when term has changed
    NSNumber *refId = 0, *tempId = 0;
    
    for (PFObject *object in objects) {
        refId = [object objectForKey:tagReference];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tid = %@", refId];
        NSArray *filteredArray = [termsArray filteredArrayUsingPredicate:predicate];
        NSString *termName;
        if (filteredArray.count > 0) {
            termName = [filteredArray[0] objectForKey:@"name"];
        }
        
        UILabel *catagoryLabel;
        UIView *lineView, *spaceView;
        if ([refId doubleValue] != [tempId doubleValue]) {
            spaceView = [[UIView alloc] initWithFrame:CGRectMake(160, y, 550, 10)];
            spaceView.backgroundColor = [UIColor clearColor];
            
            y += 10;
            
            catagoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, y, 550, 40)];
            [catagoryLabel setFont:[UIFont fontWithName:@"Oswald" size:25.0]];
            catagoryLabel.textColor = [UIColor whiteColor];
            catagoryLabel.numberOfLines = 1;
            catagoryLabel.backgroundColor = [UIColor clearColor];
            catagoryLabel.textAlignment = NSTextAlignmentLeft;
            
            if ([refId isEqual:@"N/A"]) {
                catagoryLabel.text = @"Brand Meets World";
            }
            else {
                catagoryLabel.text = [NSString stringWithFormat:@"%@", [termName uppercaseString]];
            }
            
            y += 45;
            
            lineView = [[UIView alloc] initWithFrame:CGRectMake(160, y, 550, 2)];
            lineView.backgroundColor = [UIColor lightGrayColor];
        }
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, y, 550, 50)];
        [titleLabel setFont:[UIFont fontWithName:@"AktivGrotesk-Regular" size:20.0]];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.numberOfLines = 1;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.text = [NSString stringWithFormat:@"%@", object[@"title"]];
        
        BOOL switchVal = YES;
        if (![lcpContent objectForKey:[object objectForKey:@"nid"]]) {
            if ([contentView isEqualToString:@"pdf_slide_deck"]) {
                [lcpContent setObject:@"hide" forKey:[object objectForKey:@"nid"]];
                switchVal = NO;
            }
            else {
                [lcpContent setObject:@"show" forKey:[object objectForKey:@"nid"]];
            }
        }
        else {
            if ([[lcpContent objectForKey:[object objectForKey:@"nid"]] isEqualToString:@"show"]) {
                switchVal = YES;
            }
            else {
                switchVal = NO;
            }
        }
        
        UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(800, y, 0, 0)];
        mySwitch.onTintColor = [UIColor colorWithRed:75.0f/255.0f green:129.0f/255.0f blue:0.0f/255.0f alpha:1.0];
        mySwitch.tag = [[object objectForKey:@"nid"] integerValue];
        [mySwitch setOn:switchVal animated:NO];
        [mySwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
        
        if ([contentView isEqualToString:@"case_study"]) {
            [csContent addSubview:spaceView];
            [csContent addSubview:titleLabel];
            [csContent addSubview:mySwitch];
            [csContent addSubview:catagoryLabel];
            [csContent addSubview:lineView];
            [csContent setContentSize:CGSizeMake(background.bounds.size.width, (95 * objects.count))];
        }
        else if ([contentView isEqualToString:@"samples"]) {
            [sContent addSubview:spaceView];
            [sContent addSubview:titleLabel];
            [sContent addSubview:mySwitch];
            [sContent addSubview:catagoryLabel];
            [sContent addSubview:lineView];
            [sContent setContentSize:CGSizeMake(background.bounds.size.width, (95 * objects.count))];
        }
        else if ([contentView isEqualToString:@"video"]) {
            [vContent addSubview:spaceView];
            [vContent addSubview:titleLabel];
            [vContent addSubview:mySwitch];
            [vContent addSubview:catagoryLabel];
            [vContent addSubview:lineView];
            [vContent setContentSize:CGSizeMake(background.bounds.size.width, (105 * objects.count))];
        }
        else if ([contentView isEqualToString:@"testimonials"]) {
            [tContent addSubview:spaceView];
            [tContent addSubview:titleLabel];
            [tContent addSubview:mySwitch];
            [tContent addSubview:catagoryLabel];
            [tContent addSubview:lineView];
            [tContent setContentSize:CGSizeMake(background.bounds.size.width, (95 * objects.count))];
        }
        else if ([contentView isEqualToString:@"pdf_slide_deck"]) {
            [pdfContent addSubview:spaceView];
            [pdfContent addSubview:titleLabel];
            [pdfContent addSubview:mySwitch];
            [pdfContent addSubview:catagoryLabel];
            [pdfContent addSubview:lineView];
            [pdfContent setContentSize:CGSizeMake(background.bounds.size.width, (95 * objects.count))];
        }
        
        y += 50;
        tempId = refId;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:lcpContent forKey:@"lcpContent"];
    [defaults synchronize];
}

- (void)buildCompanyLogo:(NSArray *)objects {
    int y = -50, count = 0;
    companyLogoArray = [NSMutableArray arrayWithCapacity:objects.count];
    for (int i = 0; i < objects.count; i++) {
        [companyLogoArray addObject:[NSNull null]];
    }
    
    for (PFObject *object in objects) {
        NSArray *imgArray = [object objectForKey:@"field_image"];
        //NSDictionary *imgDict = imgArray[2];
        NSDictionary *imgDict = [NSDictionary dictionary];
        for (NSDictionary *object in imgArray) {
            if ([object objectForKey:@"height"] != nil) {
                imgDict = [object copy];
                break;
            }
        }
        
        [self buildCompanyLogoItems:(y += 50) withPFObject:object andTag:count];
        y +=  ([[imgDict objectForKey:@"height"] intValue] + 10);
        count++;
        
        if (count == objects.count) {
            [pContent setContentSize:CGSizeMake(400, y + 50)];
        }
    }
}

- (void)buildCompanyLogoItems:(int)atLocation withPFObject:(PFObject *)object andTag:(int)count {
    int __block y = atLocation;
    int __block arrayIndex = count;
    dispatch_async(dispatch_get_main_queue(), ^{
        PFFile *imageFile = [object objectForKey:@"field_image_img"];
        [imageFile getDataInBackgroundWithBlock:^(NSData *imgData, NSError *error) {
            if (!error) {
                UIButton *selectLogoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, y, 40, 40)];
                selectLogoButton.backgroundColor = [UIColor clearColor];
                selectLogoButton.tag = count;
                [selectLogoButton.layer setBorderWidth:2.0f];
                [selectLogoButton.layer setBorderColor:[UIColor whiteColor].CGColor];
                [selectLogoButton addTarget:self action:@selector(setCompanyLogo:)forControlEvents:UIControlEventTouchUpInside];
                selectLogoButton.showsTouchWhenHighlighted = YES;
                [selectLogoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                selectLogoButton.titleLabel.font = [UIFont fontWithName:@"Oswald" size:20];
                [pContent addSubview:selectLogoButton];
                
                UILabel *companyLogoLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, y, 400, 50)];
                companyLogoLabel.textColor = [UIColor whiteColor];
                companyLogoLabel.font = [UIFont fontWithName:@"Oswald" size:20];
                companyLogoLabel.numberOfLines = 1;
                companyLogoLabel.backgroundColor = [UIColor clearColor];
                companyLogoLabel.textAlignment = NSTextAlignmentLeft;
                companyLogoLabel.text = [object objectForKey:@"title"];
                [pContent addSubview:companyLogoLabel];
                
                UIImage *logoImage = [[UIImage alloc] initWithData:imgData];
                [companyLogoArray insertObject:logoImage atIndex:arrayIndex];
                
                UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logoImage];
                logoImageView.frame = CGRectMake(0, y += 50, logoImage.size.width, logoImage.size.height);
                [pContent addSubview:logoImageView];
            } else {
                NSLog(@"%s [Line %d] -- Error: %@ %@",__PRETTY_FUNCTION__, __LINE__,  error, [error userInfo]);
            }
        }];
    });
}

-(void)createpdfNIDArray:(NSArray *)objects {
    pdfNIDs = [NSMutableArray array];
    for (PFObject *object in objects) {
        [pdfNIDs addObject:[object objectForKey:@"nid"]];
    }
    
    [self checkIfContentIsSelected];
}

- (void)checkIfContentIsFavorited {
    NSMutableDictionary *templcpFav = [[[NSUserDefaults standardUserDefaults] objectForKey:@"contentFavorites"] mutableCopy];
    
    if (templcpFav.count > 0) {
        isContentFavorited = YES;
        [presentationContent addSubview:currentlyFavoritedItemsLabel];
        [presentationContent addSubview:contentFavoritedFlag];
    }
    else {
        isContentFavorited = NO;
        [currentlyFavoritedItemsLabel removeFromSuperview];
        [contentFavoritedFlag removeFromSuperview];
    }
}

- (void)checkIfContentIsSelected {
    NSMutableDictionary *templcpContent = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lcpContent"] mutableCopy];
    
    for (NSString *key in pdfNIDs) {
        if ([templcpContent objectForKey:key]) {
            [templcpContent removeObjectForKey:key];
        }
    }
    
    
    for (id key in templcpContent) {
        if ([[templcpContent objectForKey:key] isEqualToString:@"hide"]) {
            isContentSelected = YES;
            break;
        }
        else {
            isContentSelected = NO;
        }
    }
    
    if (isContentSelected) {
        if (isContentFavorited) {
            [currentlySelectedItemsLabel setFrame:CGRectMake((background.bounds.size.width / 2) + 60, 510, 400, 40)];
            [contentSelectedFlag setFrame:CGRectMake((background.bounds.size.width / 2) + 24, 520, 25, 25)];
        }
        else {
            [currentlySelectedItemsLabel setFrame:CGRectMake((background.bounds.size.width / 2) + 60, 460, 400, 40)];
            [contentSelectedFlag setFrame:CGRectMake((background.bounds.size.width / 2) + 24, 470, 25, 25)];
        }
        
        [presentationContent addSubview:currentlySelectedItemsLabel];
        [presentationContent addSubview:contentSelectedFlag];
    }
    else {
        [currentlySelectedItemsLabel removeFromSuperview];
        [contentSelectedFlag removeFromSuperview];
    }
}

- (void)setCompanyLogo:(UIButton *)sender {
    for (UIView *b in [pContent subviews]) {
        if ([b isKindOfClass:[UIButton class]]) {
            [b setBackgroundColor:[UIColor clearColor]];
        }
    }
    
    for (int i = 0; i < companyLogoArray.count; i++) {
        if ([companyLogoArray[i] isKindOfClass:[NSNull class]]) {
            [companyLogoArray removeObjectAtIndex:i];
        }
    }
    
    if (isCompanyLogoSelected) {
        if (senderTag == sender.tag) {
            isCompanyLogoSelected = NO;
            companyLogo = nil;
        }
        else {
            isCompanyLogoSelected = YES;
            senderTag = (int)sender.tag;
            companyLogo = [companyLogoArray objectAtIndex:sender.tag];
            [sender setBackgroundColor:[UIColor whiteColor]];
        }
    }
    else {
        isCompanyLogoSelected = YES;
        senderTag = (int)sender.tag;
        companyLogo = [companyLogoArray objectAtIndex:sender.tag];
        [sender setBackgroundColor:[UIColor whiteColor]];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"logosize"]) {
        [defaults removeObjectForKey:@"logosize"];
    }
    if ([defaults objectForKey:@"touchLocation"]) {
        [defaults removeObjectForKey:@"touchLocation"];
    }
    [defaults synchronize];
}

#pragma mark
#pragma mark - Reachability
- (BOOL)connected {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

- (BOOL)wifiConnection {
    Reachability *reachability = [Reachability reachabilityForLocalWiFi];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

#pragma mark
#pragma mark - Email Functionality

//this function is in place because often times a scrollview will not let a touch event penetrate down to the subviews
//this function is specifically being used to close the keyboard on a non-focus touch to the form
-(void)tapEmailView:(UITapGestureRecognizer *)recognizer {
    if(recognizer.view.tag == 212 || recognizer.view.tag == 213){
        //remove the first responder from the message view
        if(message.isFirstResponder){
            [message resignFirstResponder];
        }else if(email.isFirstResponder){
            [email resignFirstResponder];
        }else if(subject.isFirstResponder){
            [subject resignFirstResponder];
        }
        [self moveFormFieldBackIntoPosition];
    }
}

//utility function to slide the form back into position if it was left slid up
-(void)moveFormFieldBackIntoPosition {
    if(formSlidView.frame.origin.y < 0){
        [UIView animateWithDuration:0.9f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            formSlidView.frame = CGRectMake(160, 0, 685, 600);
        }completion:^(BOOL finished) {}];
    }
}

//deletgate function for UITextViews
//textview delegate function to slide the form view up when the keyboard is blocking it
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if(formSlidView.frame.origin.y == 0){
        [UIView animateWithDuration:0.9f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            formSlidView.frame = CGRectMake(160, -160, 685, 600);
        }completion:^(BOOL finished) {}];
    }
    return YES;
}

//deletgate function for UITextViews
//this function is being used to detect the send button on the keyboard
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text; {
    if ([text isEqualToString:@"\n"] ) {
        [self submitEmail:submitButton];
    }
    return YES;
}

//This function captures the touch away event of the user and hides the keyboard
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    
    //resign subject
    if ([subject isFirstResponder] && [touch view] != subject) {
        [subject resignFirstResponder];
    }
    
    //resign email
    if ([email isFirstResponder] && [touch view] != email) {
        [email resignFirstResponder];
    }
    
    //resign email
    if ([message isFirstResponder] && [touch view] != message) {
        [message resignFirstResponder];
        [self moveFormFieldBackIntoPosition];
    }
    
    [super touchesBegan:touches withEvent:event];
}

//delegate function for UITextFields
//delegate function passes focus to textfields
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // Tell the keyboard where to go on next button
    if(textField == email){
        [subject becomeFirstResponder];
    }else if (textField == subject){
        [message becomeFirstResponder];
    }
    
    return YES;
}
//email submission functionality
-(void)submitEmail:(id)sender {
    //check to make sure values are present and the email is valid
    if([email.text length] > 0){
        if([subject.text length] > 0){
            if([parsedownload checkForValidEmail:email.text]){
                if([message.text length] > 0){
                    //make sure the sender is connected to the internet
                    if([self connected]){
                        loadingView.alpha = 0.8;
                        [self moveFormFieldBackIntoPosition];
                        [self.view endEditing:NO];
                        
                        [emailObject.requestData removeAllObjects];
                        [emailObject.requestData setObject:email.text forKey:@"email"];
                        [emailObject.requestData setObject:subject.text forKey:@"subject"];
                        [emailObject.requestData setObject:message.text forKey:@"message"];
                        [emailObject.requestData setObject:favoritedNIDs forKey:@"favorites"];
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                            [emailObject getRequestToken];
                        });
                    }else{
                        [self displayMessage:@"Please connect to the internet to send an email"];
                    }
                    
                }else{
                    [self displayMessage:@"Please provide a message for your email"];
                    [message becomeFirstResponder];
                }
            }else{
                [self displayMessage:@"Please provide a valid email"];
                //move the form field back into place if needed
                [email becomeFirstResponder];
                [self moveFormFieldBackIntoPosition];
            }
        }else{
            [self displayMessage:@"Please provide a subject to your email"];
            //move the form field back into place if needed
            [subject becomeFirstResponder];
            [self moveFormFieldBackIntoPosition];
            
        }
    }else{
        [self displayMessage:@"Please provide an email"];
        //move the form field back into place if needed
        [email becomeFirstResponder];
        [self moveFormFieldBackIntoPosition];
    }
}

//refresh the email favorite list
-(void)refreshEmailList {

    /* remove all views attached to favoriteList */
    for(UIView *v in [favoriteListView subviews]){
        [v removeFromSuperview];
    }

    //rebuild the favorited nid array
    //this is saved for when an email is sent
    [favoritedNIDs removeAllObjects];
    
    int yVal = 25;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *favoriteList = [defaults objectForKey:@"contentFavorites"];
    // make sure content is available
    if([favoriteList count] > 0){
        for(id key in favoriteList){
            UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, yVal, 685, 24)];
            messageLabel.font = [UIFont fontWithName:@"AktivGrotesk-Regular" size:19.0];
            messageLabel.textColor = [UIColor whiteColor];
            messageLabel.numberOfLines = 1;
            messageLabel.backgroundColor = [UIColor clearColor];
            messageLabel.textAlignment = NSTextAlignmentLeft;
            messageLabel.text = [NSString stringWithFormat:@"- %@", [favoriteList objectForKey:key]];
            [favoriteListView addSubview:messageLabel];
            
            //add the nid to be sent in the email
            [favoritedNIDs addObject:key];
            
            yVal += 40;
        }
    }else{
        UILabel *noMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 685, 24)];
        noMessageLabel.font = [UIFont fontWithName:@"Oswald" size:19.0];
        noMessageLabel.textColor = [UIColor whiteColor];
        noMessageLabel.numberOfLines = 1;
        noMessageLabel.backgroundColor = [UIColor clearColor];
        noMessageLabel.textAlignment = NSTextAlignmentLeft;
        noMessageLabel.text = @"- NO FAVORITED CONTENT -";
        [favoriteListView addSubview:noMessageLabel];
    }
    favoriteListView.frame = CGRectMake(160, 454, 300, (yVal + 4));
    [emailContent setContentSize:CGSizeMake(background.bounds.size.width, (favoriteListView.frame.size.height + 490))];
}

- (void)emailResponse:(NSMutableDictionary *)emailData withFlag:(BOOL)flag {
    loadingView.alpha = 0.0;
    if(flag){
        [self displayMessage:@"Your email was sent successfully"];
        email.text = @"";
        message.text = @"";
        subject.text = @"";
        
    }else{
        [self displayMessage:[emailData objectForKey:@"error"]];
    }
}

#pragma mark
#pragma mark - UISwitch
- (void)changeSwitch:(UISwitch *)sender {
    
    if ([pdfNIDs containsObject:[NSString stringWithFormat:@"%ld", (long)sender.tag]]) {
        for (UIView *v in [pdfContent subviews]) {
            if ([v isKindOfClass:[UISwitch class]]) {
                UISwitch *temp = (UISwitch *)v;
                if (temp.tag != sender.tag) {
                    [temp setOn:NO animated:YES];
                    [lcpContent setObject:@"hide" forKey:[NSString stringWithFormat:@"%ld", (long)temp.tag]];
                }
            }
        }
    }
    
    if ([sender isOn]) {
        [lcpContent setObject:@"show" forKey:[NSString stringWithFormat:@"%ld", (long)sender.tag]];
    }
    else {
        [lcpContent setObject:@"hide" forKey:[NSString stringWithFormat:@"%ld", (long)sender.tag]];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:lcpContent forKey:@"lcpContent"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark
#pragma mark - UISegmentControl
- (void)segmentedControlValueDidChange:(UISegmentedControl *)sender {
    
    if (sender.selectedSegmentIndex == 0) {
        [self checkIfContentIsSelected];
        [self checkIfContentIsFavorited];
        presentationContent.hidden = NO;
        csContent.hidden = YES;
        sContent.hidden = YES;
        vContent.hidden = YES;
        tContent.hidden = YES;
        pdfContent.hidden = YES;
        emailContent.hidden = YES;
        [self.view bringSubviewToFront:presentationContent];
    }
    else if (sender.selectedSegmentIndex == 1) {
        presentationContent.hidden = YES;
        csContent.hidden = NO;
        sContent.hidden = YES;
        vContent.hidden = YES;
        tContent.hidden = YES;
        pdfContent.hidden = YES;
        emailContent.hidden = YES;
        [self.view bringSubviewToFront:csContent];
    }
    else if (sender.selectedSegmentIndex == 2) {
        presentationContent.hidden = YES;
        csContent.hidden = YES;
        sContent.hidden = NO;
        vContent.hidden = YES;
        tContent.hidden = YES;
        pdfContent.hidden = YES;
        emailContent.hidden = YES;
        [self.view bringSubviewToFront:sContent];
    }
    else if (sender.selectedSegmentIndex == 3){
        presentationContent.hidden = YES;
        csContent.hidden = YES;
        sContent.hidden = YES;
        vContent.hidden = NO;
        tContent.hidden = YES;
        pdfContent.hidden = YES;
        emailContent.hidden = YES;
        [self.view bringSubviewToFront:vContent];
    }
    else if (sender.selectedSegmentIndex == 4){
        presentationContent.hidden = YES;
        csContent.hidden = YES;
        sContent.hidden = YES;
        vContent.hidden = YES;
        tContent.hidden = NO;
        pdfContent.hidden = YES;
        emailContent.hidden = YES;
        [self.view bringSubviewToFront:tContent];
    }
    else if (sender.selectedSegmentIndex == 5){
        presentationContent.hidden = YES;
        csContent.hidden = YES;
        sContent.hidden = YES;
        vContent.hidden = YES;
        tContent.hidden = YES;
        pdfContent.hidden = NO;
        emailContent.hidden = YES;
        [self.view bringSubviewToFront:emailContent];
    }
    else if (sender.selectedSegmentIndex == 6){
        presentationContent.hidden = YES;
        csContent.hidden = YES;
        sContent.hidden = YES;
        vContent.hidden = YES;
        tContent.hidden = YES;
        pdfContent.hidden = YES;
        emailContent.hidden = NO;
        [self.view bringSubviewToFront:emailContent];
    }
    
    //move the form field back into place if needed
    [self moveFormFieldBackIntoPosition];
}

#pragma mark
#pragma mark - Navigation
-(void)startPresentation:(id)sender {

    content.navigationIcons = [NSDictionary dictionaryWithDictionary:navIconDictionary];
    content.navigationTerms = [NSDictionary dictionaryWithDictionary:navTermDictionary];
    content.navigationTids = [NSDictionary dictionaryWithDictionary:navTidsDictionary];
    content.imgPoster = [posterDictionary objectForKey:@"202"];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    //Splash screen backgroung image
    LogoLoaderViewController *lvc = (LogoLoaderViewController *)[storyboard instantiateViewControllerWithIdentifier:@"logoLoaderViewController"];
    lvc.companyName = [companyNameTextField.text uppercaseString];
    lvc.companyLogo = companyLogo;
    lvc.content = content;
    
    [self.navigationController pushViewController:lvc animated:YES];
}

#pragma mark
#pragma mark - Reload Content
//Download all the data from parse and pin it to the local datastore
- (void)reloadLocalDataStore:(id)sender {
    alertButtonPressed = @"reloadLocalDataStore";
    [self displayDownLoadMessage:@"If you have deleted any content from the website please use the 'Remove and Reload Content' button. Otherwise use the 'Reload Content' button to overwrite the exisiting content."
                   andMessageOne:@"Remove and Reload Content"
                   andMessageTwo:@"Reload Content"];
}

- (void)reloadVideoContent:(id)sender {
    alertButtonPressed = @"reloadVideoContent";
    [self displayDownLoadMessage:@"Are you sure you want to reload all the videos? This can take a while depending on your internet connection."
                   andMessageOne:@"Yes, Reload Video Content"
                   andMessageTwo:@""];
}

- (void)resetAllFavoritedContent:(id)sender {
    
    //get the defaults and pick the content favorites out from this defaults list
    NSMutableDictionary *favoriteList = [[[NSUserDefaults standardUserDefaults] objectForKey:@"contentFavorites"] mutableCopy];
    [favoriteList removeAllObjects];
    [[NSUserDefaults standardUserDefaults] setObject:favoriteList forKey:@"contentFavorites"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self refreshEmailList];
    [self checkIfContentIsFavorited];
    
    [self displayMessage:@"All previously favorited content has now been reset."];
}

- (void)resetAllSelectedContent:(id)sender {
    
    //get the defaults and pick the content favorites out from this defaults list
    [lcpContent removeAllObjects];
    [[NSUserDefaults standardUserDefaults] setObject:lcpContent forKey:@"lcpContent"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self removeEverything];
    [self drawViews];
    
    isContentSelected = NO;
    [self checkIfContentIsSelected];
    
    [self displayMessage:@"All previously selected content has now been reset."];
}

- (void)reloadEverything:(id)sender {
    alertButtonPressed = @"reloadEverything";
    [self displayDownLoadMessage:@"Are you sure you want to reset and reload everything? This can take a while depending on your internet connection."
                   andMessageOne:@"Yes"
                   andMessageTwo:@""];
}

#pragma
#pragma mark - Display Message
- (void)displayMessage:(NSString *)displayMessage {
    UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"ALERT" message: displayMessage
                                                   delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
    [error show];
}

- (void)displayDownLoadMessage:(NSString *)downloadMessage andMessageOne:(NSString *)msg1 andMessageTwo:(NSString *)msg2 {
    UIAlertView *dlMessage = [[UIAlertView alloc] initWithTitle:@"ALERT" message: downloadMessage
                                                       delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles: nil];
    [dlMessage addButtonWithTitle:msg1];
    if (msg2.length > 0) {
        [dlMessage addButtonWithTitle:msg2];
    }
    [dlMessage show];
}
#pragma mark
#pragma mark - UIAlert method and delegate method
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    //If there is an internet connection
    if ([self connected]) {
        
        //Reload LCP Content
        if ([alertButtonPressed isEqualToString:@"reloadLocalDataStore"]) {
            
            if (buttonIndex == 1) {
                [parsedownload unpinAllPFObjects];
            }
            
            if (buttonIndex != 0) {
                [parsedownload downloadAndPinPFObjects];
                [self removeEverything];
                
                if (!parsedownload.videoFileBeingDownloaded) {
                    [self.view addSubview:contentActivityIndicator];
                    [contentActivityIndicator startAnimating];
                }
            }
        }
        else if ([alertButtonPressed isEqualToString:@"reloadVideoContent"]) {
            if(buttonIndex == 1) {
                [parsedownload downloadVideoFile:self.view forTerm:@""];
            }
        }
        else if ([alertButtonPressed isEqualToString:@"reloadEverything"]) {
            if(buttonIndex == 1) {
                [self reloadVideoContent:@""];
                [self resetAllFavoritedContent:@""];
                [self resetAllSelectedContent:@""];
                [self reloadLocalDataStore:@""];
            }
        }
    }
    else {
        [self displayMessage:@"You are not currently connected to the internt."];
    }
}

#pragma mark
#pragma mark - Memory Management
- (void)removeEverything {
    for (UIView *v in [pContent subviews]) {
        [v removeFromSuperview];
    }
    for (UIView *v in [csContent subviews]) {
        [v removeFromSuperview];
    }
    for (UIView *v in [sContent subviews]) {
        [v removeFromSuperview];
    }
    for (UIView *v in [vContent subviews]) {
        [v removeFromSuperview];
    }
    for (UIView *v in [tContent subviews]) {
        [v removeFromSuperview];
    }
}
@end
