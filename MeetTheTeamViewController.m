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
}

- (void)viewWillAppear:(BOOL)animated {
    
    jobDescription = [[UIView alloc] initWithFrame:CGRectMake(36, 410, (background.bounds.size.width - (36 * 2)), 250)];
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

#pragma mark
#pragma mark - Parse
//Query the local datastore to build the views
- (void)fetchDataFromLocalDataStore {
    
    PFQuery *query = [PFQuery queryWithClassName:@"team_member"];
    [query fromLocalDatastore];
    [query whereKey:@"field_term_reference" equalTo:content.catagoryId];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self buildImgArray:objects];
        }
    }];
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

//Layout the team members in the scroll view
- (void)buldGrid:(NSArray *)teamMemberObjects {
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

        [teamScroll setContentSize:CGSizeMake(background.bounds.size.width * multiplier, 200)];
    }
}

//Show the team member Name, title, and bio.
//Also change the alpha on the other team members
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
            
            UIScrollView *summaryScroll = [[UIScrollView alloc] initWithFrame:CGRectMake((jobDescription.bounds.size.width / 2) - 100, 0, (jobDescription.bounds.size.width / 2) + 100, 320)];
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

//this function updates the dots for the current image the the user is on
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = teamScroll.bounds.size.width;
    //display the appropriate dot when scrolled
    NSInteger pageNumber = floor((teamScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    paginationDots.currentPage = pageNumber;
}

#pragma mark
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
