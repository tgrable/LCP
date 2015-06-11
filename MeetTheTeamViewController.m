//
//  MeetTheTeamViewController.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 2/20/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "MeetTheTeamViewController.h"
#import "CatagoryViewController.h"
#import "PDFViewController.h"
#import "Reachability.h"
#import "LCPTeamMembers.h"
#import "SMPageControl.h"
#import "NSString+HTML.h"
#import <Parse/Parse.h>

@interface MeetTheTeamViewController ()

@property (strong, nonatomic) UIView *background, *jobDescription, *pagination, *navBar, *filterSelection;
@property (strong, nonatomic) UIScrollView *teamScroll;
@property (strong, nonatomic) NSMutableArray *teamMemberArray, *buttons, *filterArray;
@property (strong, nonatomic) SMPageControl *paginationDots;

@end

@implementation MeetTheTeamViewController
@synthesize content;                                                            //LCPContent
@synthesize background, jobDescription, pagination, navBar, filterSelection;    //UIView
@synthesize teamScroll;                                                         //UIScrollView
@synthesize teamMemberArray, buttons, filterArray;                              //NSMutableArray
@synthesize paginationDots;                                                     //UIPageControl

- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //First Page Summary View
    background = [[UIView alloc] initWithFrame:CGRectMake(36, 36, self.view.bounds.size.width - (36 * 2), self.view.bounds.size.height - (36 * 2))];
    [background setBackgroundColor:[UIColor whiteColor]];
    [background setUserInteractionEnabled:YES];
    //[pageScroll addSubview:background];
    [self.view addSubview:background];
    
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
    
    UIImageView *headerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, background.bounds.size.width, 110)];
    headerImgView.image = [UIImage imageNamed:@"hdr-team"];
    [background addSubview:headerImgView];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerImgView.bounds.size.width, 110)];
    [headerLabel setFont:[UIFont fontWithName:@"Oswald-Bold" size:80.0f]];
    headerLabel.textColor = [UIColor whiteColor];
    [headerLabel setNumberOfLines:2];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    headerLabel.text = @"MEET THE TEAM";
    [background addSubview:headerLabel];
    
    teamScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 115, background.bounds.size.width, 234)];
    [teamScroll setBackgroundColor:[UIColor clearColor]];
    teamScroll.delegate = self;
    [background addSubview:teamScroll];
    
    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0, 343, background.bounds.size.width, 2)];
    [divider setBackgroundColor:[UIColor colorWithRed:191.0f/255.0f green:191.0f/255.0f blue:191.0f/255.0f alpha:1.0]];
    [background addSubview:divider];
    
    pagination = [[UIScrollView alloc] initWithFrame:CGRectMake((background.bounds.size.width / 2) - 150, 354, 300, 50)];
    [pagination setBackgroundColor:[UIColor clearColor]];
    [pagination setUserInteractionEnabled:YES];
    [background addSubview:pagination];
    
    navBar = [[UIView alloc] initWithFrame:CGRectMake(0, (background.bounds.size.height - 96), background.bounds.size.width, 96)];
    [navBar setBackgroundColor:[UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0]];
    [background addSubview:navBar];
    
    UIButton *allButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [allButton setFrame:CGRectMake((navBar.bounds.size.width / 2) - 332.5, 15, 65, 65)];
    [allButton addTarget:self action:@selector(filterButtonPressed:)forControlEvents:UIControlEventTouchUpInside];
    allButton.showsTouchWhenHighlighted = YES;
    [allButton setBackgroundImage:[UIImage imageNamed:@"ico-all-filter"] forState:UIControlStateNormal];
    [allButton setTag:99];
    [allButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [navBar addSubview:allButton];
    
    [self fetchTermsFromLocalDataStore];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //NSUserDefaults to check if data has been downloaded.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"team_member"] isEqualToString:@"hasData"]) {
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
    
    PFQuery *executiveQuery = [PFQuery queryWithClassName:@"team_member"];
    [executiveQuery whereKey:@"field_term_reference" equalTo:@"N/A"];
    
    PFQuery *catagoryQuery = [PFQuery queryWithClassName:@"team_member"];
    [catagoryQuery whereKey:@"field_term_reference" equalTo:content.catagoryId];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[executiveQuery, catagoryQuery]];
    [query fromLocalDatastore];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self buildImgArray:objects];
        }
    }];
}

//Query the local datastore to build the views
- (void)fetchDataFromLocalDataStore:(NSArray *)termArray {
    //Query the Local Datastore
    PFQuery *query = [PFQuery queryWithClassName:@"team_member"];
    if (termArray.count > 0) {
        //[query whereKey:@"field_term_reference" equalTo:key];
        [query whereKey:@"field_term_reference" containedIn:termArray];
    }
    [query fromLocalDatastore];
    [query orderByAscending:@"createdAt"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSMutableArray *selectedObjects = [[NSMutableArray alloc] init];
            NSMutableDictionary *lcpLibrary = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lcpContent"] mutableCopy];
            
            //Add selected objects the the array
            for (PFObject *object in objects) {
                //Add selected objects the the array
                if ([[lcpLibrary objectForKey:[object objectForKey:@"nid"]] isEqualToString:@"show"]) {
                    [selectedObjects addObject:object];
                }
            }
            [self buildImgArray:objects];
        }];
    });
}

- (void)fetchTermsFromLocalDataStore {
    // Query the Local Datastore for term data
    PFQuery *query = [PFQuery queryWithClassName:@"term"];
    [query whereKey:@"parent" equalTo:@"0"];
    [query fromLocalDatastore];
    [query orderByAscending:@"weight"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                [self buildView:objects];
            }
        }];
    });
}

- (void)fetchDataFromParse {
    
    //Using Reachability check if there is an internet connection
    //If there is download term data from Parse.com if not alert the user there needs to be an internet connection
    if ([self connected]) {
        PFQuery *query = [PFQuery queryWithClassName:@"team_member"];
        [query whereKey:@"field_term_reference" equalTo:content.catagoryId];
        [query orderByAscending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                [PFObject pinAllInBackground:objects block:^(BOOL succeded, NSError *error) {
                    if (!error) {
                        NSUserDefaults *csDefaults = [NSUserDefaults standardUserDefaults];
                        [csDefaults setObject:@"hasData" forKey:@"team_member"];
                        [csDefaults synchronize];
                        [self buildImgArray:objects];
                    }
                }];
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

- (void)buildImgArray:(NSArray *)objects {
    teamMemberArray = [[NSMutableArray alloc] init];
    buttons = [[NSMutableArray alloc] init];
    int __block count = 1;
    for (PFObject *object in objects) {
        NSArray *sortArray = [object objectForKey:@"field_sort_order"];
        NSDictionary *sortDict = sortArray[0];
        
        //Sample Image
        PFFile *sampleFile = object[@"field_team_member_image_img"];
        [sampleFile getDataInBackgroundWithBlock:^(NSData *sampleData, NSError *error) {
            UIImage *sampleImg = [[UIImage alloc] initWithData:sampleData];
            LCPTeamMembers *tm = [[LCPTeamMembers alloc] init];
            
            NSArray *bioArray = [object objectForKey:@"body"];
            NSDictionary *bioDict = bioArray[1];
            tm.teamMemberBio = [bioDict objectForKey:@"value"];
            
            NSArray *titleArray = [object objectForKey:@"field_job_title"];
            NSDictionary *titleDict = titleArray[0];
            tm.teamMemberTitle = [titleDict objectForKey:@"value"];
            
            tm.teamMemberName = [object objectForKey:@"title"];
            tm.teamMemberPhoto = sampleImg;
            tm.isTeamMember = YES;
            tm.btnTag = [object objectForKey:@"nid"];
            tm.teamMemberCatagoryId = [object objectForKey:@"field_term_reference"];
            tm.sortOrder = [sortDict objectForKey:@"value"];
            [teamMemberArray addObject:tm];
            
            count++;
            if (count > objects.count) {
                NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"teamMemberCatagoryId" ascending:NO];
                NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"sortOrder" ascending:YES];
                NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil];
                NSArray *sortedArray = [teamMemberArray sortedArrayUsingDescriptors:sortDescriptors];
                [self buldGrid:sortedArray];
            }
        }];
    }
}

//Layout the team members in the scroll view
- (void)buldGrid:(NSArray *)teamMemberObjects {
    NSLog(@"buldGrid");
    
    jobDescription = [[UIView alloc] initWithFrame:CGRectMake(36, 410, (background.bounds.size.width - (36 * 2)), 190)];
    [jobDescription setBackgroundColor:[UIColor clearColor]];
    [jobDescription setUserInteractionEnabled:YES];
    [background addSubview:jobDescription];
    
    int x = 24;
    for (LCPTeamMembers *tm in teamMemberObjects) {
        UIButton *teamMemberButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [teamMemberButton setFrame:CGRectMake(x, 48, 155, 155)];
        [teamMemberButton addTarget:self action:@selector(teamMemberClicked:)forControlEvents:UIControlEventTouchUpInside];
        teamMemberButton.showsTouchWhenHighlighted = YES;
        teamMemberButton.tag = [tm.btnTag intValue];
        [teamMemberButton setBackgroundImage:tm.teamMemberPhoto forState:UIControlStateNormal];
        teamMemberButton.layer.cornerRadius = (152/2);
        teamMemberButton.layer.masksToBounds = YES;
        [teamScroll addSubview:teamMemberButton];
        [buttons addObject:teamMemberButton];
        
        x += 186;
    }
    
    int multiplier = 0;
    if (teamMemberObjects.count > 5) {
        for (int i = 0; i < teamMemberObjects.count; i++) {
            if(i % 5 == 0)
            {
                multiplier++;
            }
        }

        paginationDots = [[SMPageControl alloc] initWithFrame:CGRectMake(0, 0, 300, 36)];
        paginationDots.numberOfPages = multiplier;
        paginationDots.backgroundColor = [UIColor clearColor];
        paginationDots.pageIndicatorImage = [UIImage imageNamed:@"ico-dot-inactive-black"];
        paginationDots.currentPageIndicatorImage = [UIImage imageNamed:@"ico-dot-active-black"];
        [pagination addSubview:paginationDots];
    }
    [teamScroll setContentSize:CGSizeMake(background.bounds.size.width * multiplier, 200)];
}

//Show the team member Name, title, and bio.
//Also change the alpha on the other team members
- (void)teamMemberClicked:(UIButton *)sender {
    
    for(UIButton *teamMembers in buttons){
        if(teamMembers.tag != sender.tag){
            teamMembers.alpha = 0.5;
        }else{
            teamMembers.alpha = 1.0;
        }
    }
    
    for(UIView *v in [jobDescription subviews]){
        [v removeFromSuperview];
    }
    for (LCPTeamMembers *tms in teamMemberArray) {
        if ([tms.btnTag isEqualToString:[NSString stringWithFormat:@"%ld", (long)sender.tag]]) {
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (jobDescription.bounds.size.width / 2) - 128, 40)];
            [nameLabel setFont:[UIFont fontWithName:@"AktivGrotesk-Bold" size:20.0f]];
            nameLabel.textColor = [UIColor blackColor];
            [nameLabel setNumberOfLines:1];
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.textAlignment = NSTextAlignmentLeft;
            nameLabel.text = tms.teamMemberName;
            [jobDescription addSubview:nameLabel];
            
            UILabel *positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 36, 375, 30)];
            positionLabel.textColor = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0];
            [positionLabel setNumberOfLines:0];
            NSMutableParagraphStyle *posStyle  = [[NSMutableParagraphStyle alloc] init];
            posStyle.minimumLineHeight = 20.0f;
            posStyle.maximumLineHeight = 20.0f;
            NSDictionary *posAttributtes = @{NSParagraphStyleAttributeName : posStyle,};
            positionLabel.attributedText = [[NSAttributedString alloc] initWithString:tms.teamMemberTitle.stringByConvertingHTMLToPlainText attributes:posAttributtes];
            [positionLabel setFont:[UIFont fontWithName:@"AktivGrotesk-Regular" size:16.0]];
            positionLabel.backgroundColor = [UIColor clearColor];
            positionLabel.textAlignment = NSTextAlignmentLeft;
            positionLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [positionLabel sizeToFit];
            [jobDescription addSubview:positionLabel];
            
            UIScrollView *summaryScroll = [[UIScrollView alloc] initWithFrame:CGRectMake((jobDescription.bounds.size.width / 2) - 100, 0, (jobDescription.bounds.size.width / 2) + 100, 190)];
            summaryScroll.layer.borderWidth = 1.0f;
            summaryScroll.layer.borderColor = [UIColor whiteColor].CGColor;
            summaryScroll.backgroundColor = [UIColor clearColor];
            [jobDescription addSubview:summaryScroll];
            
            NSString *temp = [NSString stringWithFormat:@"%@", tms.teamMemberBio];
            UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (jobDescription.bounds.size.width / 2) + 100, 320)];
            myLabel.numberOfLines = 0;
            NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
            style.minimumLineHeight = 20.0f;
            style.maximumLineHeight = 20.0f;
            NSDictionary *attributtes = @{NSParagraphStyleAttributeName : style,};
            myLabel.attributedText = [[NSAttributedString alloc] initWithString:temp.stringByConvertingHTMLToPlainText attributes:attributtes];
            myLabel.font = [UIFont fontWithName:@"AktivGrotesk-Regular" size:16.0];
            myLabel.backgroundColor = [UIColor clearColor];
            myLabel.textColor = [UIColor blackColor];
            [myLabel sizeToFit];
            [summaryScroll addSubview:myLabel];
            
            [summaryScroll setContentSize:CGSizeMake(summaryScroll.bounds.size.width, myLabel.frame.size.height)];
        }
    }
}

- (void)buildView:(NSArray *)objects {
    int x = (navBar.bounds.size.width / 2) - 232.5;
    
    for (PFObject *object in objects) {
        //Button Image
        PFFile *imageFile = object[@"field_button_image_img"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [imageFile getDataInBackgroundWithBlock:^(NSData *imgData, NSError *error) {
                if (!error) {
                    UIImage *btnImg = [[UIImage alloc] initWithData:imgData];
                    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [UIScreen mainScreen].scale > 1) {
                        UIButton *tempButton = [self navigationButtons:btnImg andtitle:[object objectForKey:@"name"] andXPos:x andYPos:15 andTag:[object objectForKey:@"tid"]];
                        [navBar addSubview:tempButton];
                    }
                    else {
                        UIButton *tempButton = [self navigationButtons:[self scaleImages:btnImg withSize:CGSizeMake(65, 65)] andtitle:[object objectForKey:@"name"] andXPos:x andYPos:15 andTag:[object objectForKey:@"tid"]];
                        [navBar addSubview:tempButton];
                    }
                }
            }];
        });
        
        x += 100;
    }
    
    filterSelection = [[UIView alloc] init];
    [filterSelection setBackgroundColor:[UIColor colorWithRed:115.0f/255.0f green:115.0f/255.0f blue:115.0f/255.0f alpha:1.0]];
    [self setFilterSelectionView:[content.catagoryId intValue]];
    [navBar addSubview:filterSelection];
}

- (UIButton *)navigationButtons:(UIImage *)imgData andtitle:(NSString *)buttonTitle andXPos:(int)xpos andYPos:(int)ypos andTag:(NSString *)buttonTag {
    //the grid of buttons
    UIButton *tempButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tempButton setFrame:CGRectMake(xpos, ypos, 65, 65)];
    [tempButton addTarget:self action:@selector(filterButtonPressed:)forControlEvents:UIControlEventTouchUpInside];
    tempButton.showsTouchWhenHighlighted = YES;
    [tempButton setBackgroundImage:imgData forState:UIControlStateNormal];
    [tempButton setTitle:buttonTitle forState:normal];
    [tempButton setTag:[buttonTag integerValue]];
    [tempButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    
    return tempButton;
}

- (void)filterButtonPressed:(UIButton *)sender {
    if (sender.tag == 99) {
        filterArray = [NSMutableArray array];
        NSArray *termArray = [NSArray array];
        [self fetchDataFromLocalDataStore:termArray];
    }
    else {
        PFQuery *query = [PFQuery queryWithClassName:@"term"];
        [query whereKey:@"parent" equalTo:[NSString stringWithFormat:@"%ld", (long)sender.tag]];
        [query fromLocalDatastore];
        [query orderByAscending:@"weight"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    filterArray = [NSMutableArray array];
                    [filterArray addObject:[NSString stringWithFormat:@"%ld", (long)sender.tag]];
                    for (PFObject *obj in objects) {
                        [filterArray addObject:[obj objectForKey:@"tid"]];
                    }
                    [self fetchDataFromLocalDataStore:filterArray];
                }
            }];
        });
    }
    [self setFilterSelectionView:sender.tag];
    [self removeEverything];
}

- (void)setFilterSelectionView:(int)sectionCatagoryId {
    if (sectionCatagoryId == 44) {
        [filterSelection setFrame:CGRectMake((navBar.bounds.size.width / 2) - 242, 0, 80, 5)];
    }
    else if (sectionCatagoryId == 38) {
        [filterSelection setFrame:CGRectMake((navBar.bounds.size.width / 2) - 142, 0, 80, 5)];
    }
    else if (sectionCatagoryId == 43) {
        [filterSelection setFrame:CGRectMake((navBar.bounds.size.width / 2) - 42, 0, 80, 5)];
    }
    else if (sectionCatagoryId == 40) {
        [filterSelection setFrame:CGRectMake((navBar.bounds.size.width / 2) + 58, 0, 80, 5)];
    }
    else if (sectionCatagoryId == 41) {
        [filterSelection setFrame:CGRectMake((navBar.bounds.size.width / 2) + 158, 0, 80, 5)];
    }
    else if (sectionCatagoryId == 42) {
        [filterSelection setFrame:CGRectMake((navBar.bounds.size.width / 2) + 258, 0, 80, 5)];
    }
    else {
        [filterSelection setFrame:CGRectMake((navBar.bounds.size.width / 2) - 342, 0, 80, 5)];
    }
}

- (UIImage *)scaleImages:(UIImage *)originalImg withSize:(CGSize)size {
    CGSize destinationSize = size;
    UIGraphicsBeginImageContext(destinationSize);
    [originalImg drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//this function updates the dots for the current image the the user is on
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = teamScroll.bounds.size.width;
    //display the appropriate dot when scrolled
    NSInteger pageNumber = floor((teamScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    paginationDots.currentPage = pageNumber;
}

#pragma mark
#pragma mark - Navigation
- (void)backNav:(UIButton *)sender {
    
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

- (void)backToDashboard:(id)sender {
    // Send the presenter back to the dashboard
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self removeEverything];
}

- (void)hiddenSection:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PDFViewController *pvc = (PDFViewController *)[storyboard instantiateViewControllerWithIdentifier:@"pdfViewController"];
    [self.navigationController pushViewController:pvc animated:YES];
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
    for (UIView *v in [teamScroll subviews]) {
        [v removeFromSuperview];
    }
    [jobDescription removeFromSuperview];
    [paginationDots removeFromSuperview];
}
@end
