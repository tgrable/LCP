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
#import "NSString+HTML.h"
#import <Parse/Parse.h>

@interface MeetTheTeamViewController ()

@property (strong, nonatomic) UIView *background, *description;
@property (strong, nonatomic) UIScrollView *teamScroll;
@property (strong, nonatomic) NSMutableArray *teamMemberArray;
@property (strong, nonatomic) NSMutableArray *buttons;

@end

@implementation MeetTheTeamViewController
@synthesize content;                    //LCPContent
@synthesize background, description;    //UIView
@synthesize teamScroll;                 //UIScrollView
@synthesize teamMemberArray, buttons;   //NSMutableArray

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
    
    UIImageView *headerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, background.bounds.size.width, 105)];
    headerImgView.image = content.imgHeader;
    [background addSubview:headerImgView];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerImgView.bounds.size.width, 105)];
    [headerLabel setFont:[UIFont fontWithName:@"NimbusSanD-Bold" size:40.0]];
    headerLabel.textColor = [UIColor whiteColor];
    [headerLabel setNumberOfLines:2];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    headerLabel.text = @"MEET THE TEAM";
    [background addSubview:headerLabel];
    
    //Logo, settings, and home buttons
    UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoButton setFrame:CGRectMake(72, 5, 81, 25)];
    //[logoButton addTarget:self action:@selector(hiddenSection:)forControlEvents:UIControlEventTouchUpInside];
    logoButton.showsTouchWhenHighlighted = YES;
    [logoButton setBackgroundImage:[UIImage imageNamed:@"logo.png"] forState:UIControlStateNormal];
    [self.view addSubview:logoButton];
    
    UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [homeButton setFrame:CGRectMake((self.view.bounds.size.width - ((36 * 4) + 50)), 5, 50, 50)];
    [homeButton addTarget:self action:@selector(backNav:)forControlEvents:UIControlEventTouchUpInside];
    homeButton.showsTouchWhenHighlighted = YES;
    homeButton.tag = 0;
    [homeButton setBackgroundImage:[UIImage imageNamed:@"btn-home.png"] forState:UIControlStateNormal];
    [self.view addSubview:homeButton];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake((self.view.bounds.size.width - ((36 * 2) + 50)), 5, 50, 50)];
    [backButton addTarget:self action:@selector(backNav:)forControlEvents:UIControlEventTouchUpInside];
    backButton.showsTouchWhenHighlighted = YES;
    backButton.tag = 1;
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn-back.png"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    
    //the following two views add a button for navigation back to the dashboard
    UIView *dashboardBackground = [[UIView alloc] initWithFrame:CGRectMake(189, 5, 25, 25)];
    dashboardBackground.backgroundColor = [UIColor blackColor];
    [self.view addSubview:dashboardBackground];
    
    UIButton *dashboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dashboardButton setFrame:CGRectMake(3, 3, 20, 20)];
    [dashboardButton addTarget:self action:@selector(backToDashboard:)forControlEvents:UIControlEventTouchUpInside];
    dashboardButton.showsTouchWhenHighlighted = YES;
    [dashboardButton setBackgroundImage:[UIImage imageNamed:@"cog-wheel"] forState:UIControlStateNormal];
    [dashboardBackground addSubview:dashboardButton];
    
    teamScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 115, background.bounds.size.width, 250)];
    [teamScroll setBackgroundColor:[UIColor clearColor]];
    [background addSubview:teamScroll];
}

- (void)viewWillAppear:(BOOL)animated {
    
    description = [[UIView alloc] initWithFrame:CGRectMake(130, 90, 280, 420)];
    [description setBackgroundColor:[UIColor clearColor]];
    [description setUserInteractionEnabled:YES];
    [background addSubview:description];

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
            NSLog(@"%@", teamMemberArray);
        }];
    }
}

- (void)buldGrid:(NSMutableArray *)teamMemberObjects {
    
    // TODO: Fix grid setup to display team memeber photos in proper position every time.
    
    int x = 438, y = 99, count = 0, btnCount = 0;
    for (LCPTeamMembers *tm in teamMemberObjects) {
        if (btnCount < 9) {
            if (tm.isTeamMember) {
                UIButton *teamMemberButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [teamMemberButton setFrame:CGRectMake(x, y, 152, 152)];
                [teamMemberButton addTarget:self action:@selector(teamMemberClicked:)forControlEvents:UIControlEventTouchUpInside];
                teamMemberButton.showsTouchWhenHighlighted = YES;
                teamMemberButton.tag = [tm.btnTag intValue];
                [teamMemberButton setBackgroundImage:tm.teamMemberPhoto forState:UIControlStateNormal];
                [background addSubview:teamMemberButton];
                [buttons addObject:teamMemberButton];
            }
            else {
                UIButton *teamMemberButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [teamMemberButton setFrame:CGRectMake(x, y, 152, 152)];
                [teamMemberButton addTarget:self action:@selector(teamMemberClicked:)forControlEvents:UIControlEventTouchUpInside];
                teamMemberButton.showsTouchWhenHighlighted = YES;
                teamMemberButton.tag = [tm.btnTag intValue];
                [teamMemberButton setBackgroundImage:tm.teamMemberPhoto forState:UIControlStateNormal];
                teamMemberButton.enabled = NO;
                [background addSubview:teamMemberButton];
            }
        }
        count++;
        btnCount++;
        if (count < 3) {
            x += 171;
        }
        else {
            x = 438;
            count = 0;
            y += 181;
        }
    }
}

-(void)teamMemberClicked:(UIButton *)sender
{
    for(UIButton *teamMembers in buttons){
        if(teamMembers.tag != sender.tag){
            teamMembers.alpha = 0.5;
        }else{
            teamMembers.alpha = 1.0;
        }
    }
    
    for(UIView *v in [description subviews]){
        [v removeFromSuperview];
    }
    
    for (LCPTeamMembers *tms in teamMemberArray) {
        if ([tms.btnTag isEqualToString:[NSString stringWithFormat:@"%ld", (long)sender.tag]]) {
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 40)];
            [nameLabel setFont:[UIFont fontWithName:@"NimbusSanD-Bold" size:20.0]];
            nameLabel.textColor = [UIColor blackColor];
            [nameLabel setNumberOfLines:1];
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.textAlignment = NSTextAlignmentLeft;
            nameLabel.text = tms.teamMemberName;
            [description addSubview:nameLabel];
            
            UILabel *positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 36, 280, 20)];
            [positionLabel setFont:[UIFont fontWithName:@"NimbusSanD-Regu" size:16.0]];
            positionLabel.textColor = [UIColor blackColor];
            [positionLabel setNumberOfLines:1];
            positionLabel.backgroundColor = [UIColor clearColor];
            positionLabel.textAlignment = NSTextAlignmentLeft;
            positionLabel.text = tms.teamMemberTitle;
            [description addSubview:positionLabel];
            
            NSString *temp = [NSString stringWithFormat:@"%@", tms.teamMemberBio];
            UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 280, 320)];
            [descLabel setFont:[UIFont fontWithName:@"NimbusSanD-Regu" size:16.0]];
            descLabel.textColor = [UIColor blackColor];
            [descLabel setNumberOfLines:30];
            descLabel.backgroundColor = [UIColor clearColor];
            descLabel.textAlignment = NSTextAlignmentLeft;
            descLabel.text = temp.stringByConvertingHTMLToPlainText;
            [description addSubview:descLabel];
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
