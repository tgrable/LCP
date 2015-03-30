//
//  CatagoryViewController.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 2/11/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "CatagoryViewController.h"
#import "DetailsViewController.h"
#import "MeetTheTeamViewController.h"
#import "TestimonialsViewController.h"
#import "Reachability.h"
#import <Parse/Parse.h>

@interface CatagoryViewController () {
    long int index, y;
}


@property (strong, nonatomic) Reachability *reachable;
@property (strong, nonatomic) UIView *background;
@property (strong, nonatomic) UIImageView *logo, *overlay;
@property (strong, nonatomic) NSMutableArray *btnImageArray, *btnTitleArray, *btnTagArray;
@property (strong, nonatomic) NSTimer *time;

@end

@implementation CatagoryViewController
@synthesize reachable;                                  //Reachability
@synthesize content;                                    //LCPContent
@synthesize background;                                 //UIView
@synthesize logo, overlay;                              //UIImageView
@synthesize btnImageArray, btnTitleArray, btnTagArray;  //NSMutableArray
@synthesize time;                                       //NSTimer

- (BOOL)prefersStatusBarHidden
{
    return YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    //we do as much as we can in view did load to conserve memory
    background = [[UIView alloc] initWithFrame:CGRectMake(36, 36, 952, 696)];
    [background setBackgroundColor:[UIColor lightGrayColor]];
    [background setUserInteractionEnabled:YES];
    [self.view addSubview:background];
    
    UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoButton setFrame:CGRectMake(56, 56, 108, 33)];
    [logoButton addTarget:self action:@selector(hiddenSection:)forControlEvents:UIControlEventTouchUpInside];
    logoButton.showsTouchWhenHighlighted = YES;
    [logoButton setBackgroundImage:[UIImage imageNamed:@"logo.png"] forState:UIControlStateNormal];
    [self.view addSubview:logoButton];
    
    //the grid of buttons
    UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [homeButton setFrame:CGRectMake(56, 108, 50, 50)];
    [homeButton addTarget:self action:@selector(backHome:)forControlEvents:UIControlEventTouchUpInside];
    homeButton.showsTouchWhenHighlighted = YES;
    homeButton.tag = 80;
    [homeButton setBackgroundImage:[UIImage imageNamed:@"btn-home.png"] forState:UIControlStateNormal];
    [self.view addSubview:homeButton];
    
    //the following two views add a button for navigation back to the dashboard
    UIView *dashboardBackground = [[UIView alloc] initWithFrame:CGRectMake(184, 56, 33, 33)];
    dashboardBackground.backgroundColor = [UIColor blackColor];
    [self.view addSubview:dashboardBackground];
    
    UIButton *dashboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dashboardButton setFrame:CGRectMake(7, 7, 20, 20)];
    [dashboardButton addTarget:self action:@selector(backToDashboard:)forControlEvents:UIControlEventTouchUpInside];
    dashboardButton.showsTouchWhenHighlighted = YES;
    [dashboardButton setBackgroundImage:[UIImage imageNamed:@"cog-wheel"] forState:UIControlStateNormal];
    [dashboardBackground addSubview:dashboardButton];
}

- (void)viewWillAppear:(BOOL)animated {    
    //the overlay
    overlay = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 952, 696)];
    [overlay setBackgroundColor:[UIColor lightGrayColor]];
    [overlay setImage:content.imgPoster];
    [overlay setUserInteractionEnabled:YES];
    overlay.alpha = 1.0;
    //[overlay addGestureRecognizer:tapGesture];
    [background addSubview:overlay];
    
    UIImageView *header = [[UIImageView alloc] initWithFrame:CGRectMake(524, 20, 428, 80)];
    [header setImage:content.imgHeader];
    [header setUserInteractionEnabled:YES];
    header.alpha = 1.0;
    header.tag = 90;
    [background addSubview:header];
    
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
        [query whereKey:@"parent" equalTo:content.catagoryId];
        [query orderByAscending:@"weight"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                [PFObject pinAllInBackground:objects block:^(BOOL succeded, NSError *error) {
                    if (!error) {
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setObject:@"hasData" forKey:@"term"];
                        [defaults synchronize];
                        [self buildView:objects];
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
    [query fromLocalDatastore];
    [query whereKey:@"parent" equalTo:content.catagoryId];
    [query orderByDescending:@"weight"];
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
    [self createEmptyButtonArrays:objects.count];
    
    for (PFObject *object in objects) {
        PFFile *imageFile = object[@"field_button_image_img"];
        [imageFile getDataInBackgroundWithBlock:^(NSData *imgData, NSError *error) {
            int weight = [[object objectForKey:@"weight"] intValue];
            
            UIImage *btnImg = [[UIImage alloc] initWithData:imgData];
            [btnImageArray replaceObjectAtIndex:weight withObject:btnImg];
            [btnTitleArray replaceObjectAtIndex:weight withObject:[object objectForKey:@"name"]];
            [btnTagArray replaceObjectAtIndex:weight withObject:[object objectForKey:@"tid"]];
            
            if (count == (objects.count - 1)) {
                y = 75 + (objects.count * 60);
                [self timerCountdown];
            }
        }];
        count++;
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
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"showDetails"]) {
        DetailsViewController *vc = [segue destinationViewController];
        vc.content = content;
    }
    else if ([[segue identifier] isEqualToString:@"testimonials"]) {
        TestimonialsViewController *vc = [segue destinationViewController];
        vc.content = content;
    }

    else if ([[segue identifier] isEqualToString:@"meetTheTeam"]) {
        MeetTheTeamViewController *vc = [segue destinationViewController];
        vc.content = content;
    }
    else {
        
    }
}

#pragma mark
#pragma mark - Build UI
- (void)createEmptyButtonArrays:(long int)arrayCount {
    btnImageArray = [[NSMutableArray alloc] init];
    btnTitleArray = [[NSMutableArray alloc] init];
    btnTagArray = [[NSMutableArray alloc] init];
    index = (arrayCount - 1);
    
    for(int i = 0; i < arrayCount; i++) {
        [btnImageArray addObject: [NSNull null]];
        [btnTitleArray addObject: [NSNull null]];
        [btnTagArray addObject: [NSNull null]];
    }
}
- (void)timerCountdown
{
    time = [NSTimer scheduledTimerWithTimeInterval:0.08 target:self selector:@selector(buildNavigationButtons) userInfo:nil repeats:NO];
}

- (void)buildNavigationButtons
{
    if (![[btnImageArray objectAtIndex:index] isKindOfClass:[NSNull class]] || ![[btnTagArray objectAtIndex:index] isKindOfClass:[NSNull class]] || ![[btnTitleArray objectAtIndex:index] isKindOfClass:[NSNull class]]) {
        UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [customButton setFrame:CGRectMake(548, -40, 404, 50)];
        [customButton addTarget:self action:@selector(navigationButtonClick:)forControlEvents:UIControlEventTouchUpInside];
        customButton.showsTouchWhenHighlighted = YES;
        [customButton setBackgroundImage:[btnImageArray objectAtIndex:index] forState:UIControlStateNormal];
        customButton.tag = [[btnTagArray objectAtIndex:index] intValue];
        [customButton setTitle:[btnTitleArray objectAtIndex:index] forState:normal];
        [customButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [background addSubview:customButton];
        
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            customButton.frame = CGRectMake(548, y, 404, 50);
        }completion:^(BOOL finished) {}];
    }
    y -= 60;
    index--;
    
    if(index < [btnImageArray count]){
        [self timerCountdown];
    }else{
        [time invalidate];
    }
}
- (void)navigationButtonClick:(UIButton *)sender {
    
    content.termId = [NSString stringWithFormat: @"%ld", (long)sender.tag];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    if ([sender.titleLabel.text isEqualToString:@"Meet the Team"]) {
        [self performSegueWithIdentifier:@"meetTheTeam" sender:sender];
    }
    else if ([sender.titleLabel.text isEqualToString:@"Testimonials"]) {
        [self performSegueWithIdentifier:@"testimonials" sender:sender];
    }
    else {
        DetailsViewController *dvc = (DetailsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"detailsViewController"];
        dvc.content = content;
        [self.navigationController pushViewController:dvc animated:YES];
    }
    [self removeEverything];
}

- (void)backHome:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    [self removeEverything];
}
- (void)hiddenSection:(id)sender {
    
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
    [btnImageArray removeAllObjects];
    [btnTitleArray removeAllObjects];
    [btnTagArray removeAllObjects];
}
@end
