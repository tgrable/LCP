//
//  MeetTheTeamViewController.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 2/20/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "MeetTheTeamViewController.h"
#import "CatagoryViewController.h"
#import "Reachability.h"
#import "LCPTeamMembers.h"
#import "SMPageControl.h"
#import "NSString+HTML.h"
#import <Parse/Parse.h>

@interface MeetTheTeamViewController ()

@property (strong, nonatomic) UIView *background, *jobDescription, *pagination;
@property (strong, nonatomic) UIScrollView *teamScroll;
@property (strong, nonatomic) NSMutableArray *teamMemberArray;
@property (strong, nonatomic) NSMutableArray *buttons;
@property (strong, nonatomic) SMPageControl *paginationDots;

@end

@implementation MeetTheTeamViewController
@synthesize content;                                //LCPContent
@synthesize background, jobDescription, pagination;    //UIView
@synthesize teamScroll;                             //UIScrollView
@synthesize teamMemberArray, buttons;               //NSMutableArray
@synthesize paginationDots;                         //UIPageControl

- (BOOL)prefersStatusBarHidden
{
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
    [backButton setBackgroundImage:[UIImage imageNamed:@"ico-back"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    
    UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [homeButton setFrame:CGRectMake((self.view.bounds.size.width - 170), 0, 45, 45)];
    [homeButton addTarget:self action:@selector(backNav:)forControlEvents:UIControlEventTouchUpInside];
    homeButton.showsTouchWhenHighlighted = YES;
    homeButton.tag = 0;
    [homeButton setBackgroundImage:[UIImage imageNamed:@"ico-home"] forState:UIControlStateNormal];
    [self.view addSubview:homeButton];
    
    teamScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 115, background.bounds.size.width, 252)];
    [teamScroll setBackgroundColor:[UIColor clearColor]];
    teamScroll.delegate = self;
    [background addSubview:teamScroll];
    
    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0, 370, background.bounds.size.width, 2)];
    [divider setBackgroundColor:[UIColor colorWithRed:191.0f/255.0f green:191.0f/255.0f blue:191.0f/255.0f alpha:1.0]];
    [background addSubview:divider];
    
    pagination = [[UIScrollView alloc] initWithFrame:CGRectMake((background.bounds.size.width / 2) - 150, 375, 300, 36)];
    [pagination setBackgroundColor:[UIColor clearColor]];
    [pagination setUserInteractionEnabled:YES];
    [background addSubview:pagination];

}

- (void)viewWillAppear:(BOOL)animated {
    
    jobDescription = [[UIView alloc] initWithFrame:CGRectMake(36, 425, (background.bounds.size.width - (36 * 2)), 420)];
    [jobDescription setBackgroundColor:[UIColor clearColor]];
    [jobDescription setUserInteractionEnabled:YES];
    [background addSubview:jobDescription];

    //NSUserDefaults to check if data has been downloaded.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"team_member"] isEqualToString:@"hasData"]) {
        [self fetchDataFromLocalDataStore];
    }
    else {
        [self fetchDataFromParse];
    }
}

//this function updates the dots for the current image the the user is on
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = teamScroll.bounds.size.width;
    //display the appropriate dot when scrolled
    NSInteger pageNumber = floor((teamScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    paginationDots.currentPage = pageNumber;
}

#pragma mark
#pragma mark - Parse
- (void)fetchDataFromParse {
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
    PFQuery *query = [PFQuery queryWithClassName:@"team_member"];
    [query fromLocalDatastore];
    [query whereKey:@"field_term_reference" equalTo:content.catagoryId];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self buildImgArray:objects];
    }];
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
        NSArray *gridLocationArray = [object objectForKey:@"field_grid_location"];
        NSDictionary *gridLocationDict = [[NSMutableDictionary alloc] init];
        gridLocationDict = gridLocationArray[0];
        
        //Sample Image
        PFFile *sampleFile = object[@"field_team_member_image_img"];
        [sampleFile getDataInBackgroundWithBlock:^(NSData *sampleData, NSError *error) {
            UIImage *sampleImg = [[UIImage alloc] initWithData:sampleData];
            LCPTeamMembers *tm = [[LCPTeamMembers alloc] init];
            
            NSArray *bioArray = [object objectForKey:@"body"];
            NSDictionary *bioDict = [[NSMutableDictionary alloc] init];
            bioDict = bioArray[1];
            tm.teamMemberBio = [bioDict objectForKey:@"value"];
            
            NSArray *titleArray = [object objectForKey:@"field_job_title"];
            NSDictionary *titleDict = [[NSMutableDictionary alloc] init];
            titleDict = titleArray[0];
            tm.teamMemberTitle = [titleDict objectForKey:@"value"];
            
            tm.teamMemberName = [object objectForKey:@"title"];
            tm.teamMemberPhoto = sampleImg;
            tm.isTeamMember = YES;
            tm.btnTag = [object objectForKey:@"nid"];
            tm.sortOrder = [gridLocationDict objectForKey:@"value"];
            [teamMemberArray addObject:tm];
            
            count++;
            if (count > objects.count) {
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortOrder" ascending:YES];
                NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                NSArray *sortedArray = [teamMemberArray sortedArrayUsingDescriptors:sortDescriptors];
                [self buldGrid:sortedArray];
            }

        }];
    }
}

- (void)buldGrid:(NSArray *)teamMemberObjects {
    int x = 36;
    for (LCPTeamMembers *tm in teamMemberObjects) {
        UIButton *teamMemberButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [teamMemberButton setFrame:CGRectMake(x, 60, 152, 152)];
        [teamMemberButton addTarget:self action:@selector(teamMemberClicked:)forControlEvents:UIControlEventTouchUpInside];
        teamMemberButton.showsTouchWhenHighlighted = YES;
        teamMemberButton.tag = [tm.btnTag intValue];
        [teamMemberButton setBackgroundImage:tm.teamMemberPhoto forState:UIControlStateNormal];
        teamMemberButton.layer.cornerRadius = (152/2);
        teamMemberButton.layer.masksToBounds = YES;
        [teamScroll addSubview:teamMemberButton];
        [buttons addObject:teamMemberButton];
        
        x += 188;
    }
    
    if (teamMemberObjects.count > 5) {
        int multiplier = 0;
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

        [teamScroll setContentSize:CGSizeMake(background.bounds.size.width * multiplier, 252)];
    }
}

-(void)teamMemberClicked:(UIButton *)sender {
    
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
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 40)];
            [nameLabel setFont:[UIFont fontWithName:@"AktivGrotesk-Bold" size:24.0]];
            nameLabel.textColor = [UIColor blackColor];
            [nameLabel setNumberOfLines:1];
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.textAlignment = NSTextAlignmentLeft;
            nameLabel.text = tms.teamMemberName;
            [jobDescription addSubview:nameLabel];
            
            UILabel *positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 36, 400, 30)];
            [positionLabel setFont:[UIFont fontWithName:@"AktivGrotesk-Regular" size:22.0]];
            positionLabel.textColor = [UIColor darkGrayColor];
            [positionLabel setNumberOfLines:1];
            positionLabel.backgroundColor = [UIColor clearColor];
            positionLabel.textAlignment = NSTextAlignmentLeft;
            positionLabel.text = tms.teamMemberTitle;
            [jobDescription addSubview:positionLabel];
            
            NSString *temp = [NSString stringWithFormat:@"%@", tms.teamMemberBio];
            UITextView *descLabel = [[UITextView alloc] initWithFrame:CGRectMake(425, 0, jobDescription.bounds.size.width / 2, 320)];
            [descLabel setFont:[UIFont fontWithName:@"AktivGrotesk-Regular" size:20.0]];
            descLabel.textColor = [UIColor blackColor];
            descLabel.backgroundColor = [UIColor clearColor];
            descLabel.textAlignment = NSTextAlignmentLeft;
            descLabel.text = temp.stringByConvertingHTMLToPlainText;
            [jobDescription addSubview:descLabel];
        }
    }
}

#pragma mark
#pragma mark - Navigation
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
#pragma mark - Memory Management
- (void)removeEverything {
    for (UIView *v in [background subviews]) {
        [v removeFromSuperview];
    }
}

@end
