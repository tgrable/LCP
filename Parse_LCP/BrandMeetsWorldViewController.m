//
//  BrandMeetsWorldViewController.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 2/11/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "BrandMeetsWorldViewController.h"
#import "CatagoryViewController.h"
#import "Reachability.h"
#import <Parse/Parse.h>

@interface BrandMeetsWorldViewController ()

@property (strong, nonatomic) Reachability *reachable;
@property (strong, nonatomic) NSString *catagoryId, *catagoryType, *termId;
@property (strong, nonatomic) UIImage *posterImage, *headerImage;
@property (strong, nonatomic) UIView *background;
@property (strong, nonatomic) UIImageView *logo, *overlay;
@property (strong, nonatomic) NSMutableDictionary *posterDict, *headerDict, *teamDict;
@end

@implementation BrandMeetsWorldViewController
@synthesize reachable;                          //Reachability
@synthesize content;                            //LCPContent
@synthesize catagoryType, catagoryId, termId;   //NSString
@synthesize posterImage, headerImage;           //UIImage
@synthesize background;                         //UIView
@synthesize logo, overlay;                      //UIImageView
@synthesize posterDict, headerDict, teamDict;   //NSMutableDictionary

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark
#pragma mark - ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    posterDict = [[NSMutableDictionary alloc] init];
    headerDict = [[NSMutableDictionary alloc] init];
    teamDict = [[NSMutableDictionary alloc] init];
    
    background = [[UIView alloc] initWithFrame:CGRectMake(36, 36, 952, 696)];
    [background setBackgroundColor:[UIColor lightGrayColor]];
    [background setUserInteractionEnabled:YES];
    [self.view addSubview:background];
}

- (void) viewWillAppear:(BOOL)animated {
    
    overlay = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 952, 696)];
    [overlay setBackgroundColor:[UIColor lightGrayColor]];
    [overlay setImage:[UIImage imageNamed:@"bmwposter.png"]];
    [overlay setUserInteractionEnabled:YES];
    overlay.alpha = 1.0;
    //[overlay addGestureRecognizer:tapGesture];
    [background addSubview:overlay];
    
    UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoButton setFrame:CGRectMake(20, 20, 108, 33)];
    [logoButton addTarget:self action:@selector(hiddenSection:)forControlEvents:UIControlEventTouchUpInside];
    logoButton.showsTouchWhenHighlighted = YES;
    [logoButton setBackgroundImage:[UIImage imageNamed:@"logo.png"] forState:UIControlStateNormal];
    [background addSubview:logoButton];
    
    //the following two views add a button for navigation back to the dashboard
    UIView *dashboardBackground = [[UIView alloc] initWithFrame:CGRectMake(148, 20, 33, 33)];
    dashboardBackground.backgroundColor = [UIColor blackColor];
    [background addSubview:dashboardBackground];
    
    UIButton *dashboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dashboardButton setFrame:CGRectMake(7, 7, 20, 20)];
    [dashboardButton addTarget:self action:@selector(backToDashboard:)forControlEvents:UIControlEventTouchUpInside];
    dashboardButton.showsTouchWhenHighlighted = YES;
    [dashboardButton setBackgroundImage:[UIImage imageNamed:@"cog-wheel"] forState:UIControlStateNormal];
    [dashboardBackground addSubview:dashboardButton];
    
    //NSUserDefaults to check if data has been downloaded.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"term"] isEqualToString:@"hasData"]) {
        [self fetchDataFromLocalDataStore];
    }
    else {
        [self fetchDataFromParse];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark - Parse
- (void)fetchDataFromParse {
    
    if ([self connected]) {
        PFQuery *query = [PFQuery queryWithClassName:@"term"];
        [query whereKey:@"parent" equalTo:@"0"];
        [query orderByAscending:@"weight"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
            if (!error) {
                [PFObject pinAllInBackground:objects block:^(BOOL succeded, NSError *error) {
                    if (!error) {
                        [self buildView:objects];
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setObject:@"hasData" forKey:@"BrandMeetsWorldData"];
                        [defaults synchronize];
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

- (void)fetchDataFromLocalDataStore {
    // Query the Local Datastore
    PFQuery *query = [PFQuery queryWithClassName:@"term"];
    [query whereKey:@"parent" equalTo:@"0"];
    [query fromLocalDatastore];
    [query orderByAscending:@"weight"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self buildView:objects];
        }
    }];
}

#pragma mark
#pragma mark - Build View
- (void)buildView:(NSArray *)objects {
    int count = 0;
    int x = 0, y = -185;
    
    for (PFObject *object in objects) {
        if (count % 2 == 0) {
            x = 528;
            y = y + 205;
        }
        else {
            x = 735;
        }
        
        //Button Image
        PFFile *imageFile = object[@"field_button_image_img"];
        [imageFile getDataInBackgroundWithBlock:^(NSData *imgData, NSError *error) {
            if (!error) {
                UIImage *btnImg = [[UIImage alloc] initWithData:imgData];
                UIButton *tempButton = [self navigationButtons:btnImg andtitle:[object objectForKey:@"name"] andXPos:x andYPos:y andTag:[object objectForKey:@"tid"]];
                [background addSubview:tempButton];
            }
        }];
        count++;
        
        //Poster Image
        PFFile *posterFile = object[@"field_poster_image_img"];
        [posterFile getDataInBackgroundWithBlock:^(NSData *posterData, NSError *error) {
            UIImage *posterImg = [[UIImage alloc] initWithData:posterData];
            [posterDict setObject:posterImg forKey:object[@"tid"]];
        }];
        
        //Header Image
        PFFile *headerFile = object[@"field_header_image_img"];
        [headerFile getDataInBackgroundWithBlock:^(NSData *headerData, NSError *error) {
            UIImage *headerImg = [[UIImage alloc] initWithData:headerData];
            [headerDict setObject:headerImg forKey:object[@"tid"]];
        }];
    }
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
#pragma mark - Navigation
- (UIButton *)navigationButtons:(UIImage *)imgData andtitle:(NSString *)buttonTitle andXPos:(int)xpos andYPos:(int)ypos andTag:(NSString *)buttonTag {
    //the grid of buttons
    UIButton *tempButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tempButton setFrame:CGRectMake(xpos, ypos, 197, 197)];
    [tempButton addTarget:self action:@selector(firstLevelNavigationButtons:)forControlEvents:UIControlEventTouchUpInside];
    tempButton.showsTouchWhenHighlighted = YES;
    [tempButton setBackgroundImage:imgData forState:UIControlStateNormal];
    [tempButton setTitle:buttonTitle forState:normal];
    [tempButton setTag:[buttonTag integerValue]];
    [tempButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    return tempButton;
}

- (void)firstLevelNavigationButtons:(UIButton *)sender {
    content = [[LCPContent alloc] init];
    
    content.catagoryId = [NSString stringWithFormat: @"%ld", (long)sender.tag];
    content.imgPoster = [posterDict objectForKey:[NSString stringWithFormat: @"%ld", (long)sender.tag]];
    content.imgHeader = [headerDict objectForKey:[NSString stringWithFormat: @"%ld", (long)sender.tag]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CatagoryViewController *cvc = (CatagoryViewController *)[storyboard instantiateViewControllerWithIdentifier:@"catagoryViewController"];
    cvc.content = content;
    [self.navigationController pushViewController:cvc animated:YES];
    [self removeEverything];
}

- (void)hiddenSection:(UIButton *)sender {
    [self performSegueWithIdentifier:@"logoTest" sender:sender];
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
    for (UIView *v in [background subviews]) {
        [v removeFromSuperview];
    }
}
@end
