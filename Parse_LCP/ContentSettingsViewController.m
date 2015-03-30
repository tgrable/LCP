//
//  ContentSettingsViewController.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 2/25/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "ContentSettingsViewController.h"
#import "LogoLoaderViewController.h"
#import "BrandMeetsWorldViewController.h"
#import "Reachability.h"
#import "ParseDownload.h"
#import <Parse/Parse.h>

@interface ContentSettingsViewController ()
@property (strong, nonatomic) UIView *background;
@property (strong, nonatomic) UIScrollView *csContent, *sContent, *vContent, *tContent;
@property (strong, nonatomic) UIScrollView *presentationContent, *emailContent;
@property (nonatomic) UISegmentedControl *contentSegController;
@property (strong, nonatomic) ParseDownload *parsedownload;
@end

@implementation ContentSettingsViewController
@synthesize background;                                 //UIView
@synthesize csContent, sContent, vContent, tContent;    //UIScrollView
@synthesize presentationContent, emailContent;          //UIScrollView
@synthesize contentSegController;                       //UISegmentedControl
@synthesize parsedownload;

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    parsedownload = [[ParseDownload alloc] init];
    [parsedownload downloadAndPinPFObjects];
    
    //First Page Summary View
    background = [[UIView alloc] initWithFrame:CGRectMake(36, 36, 952, 696)];
    [background setBackgroundColor:[UIColor grayColor]];
    [background setUserInteractionEnabled:YES];
    [self.view addSubview:background];
    
    presentationContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 115, background.bounds.size.width, (background.bounds.size.height - 115))];
    [presentationContent setBackgroundColor:[UIColor clearColor]];
    [presentationContent setUserInteractionEnabled:YES];
    presentationContent.showsVerticalScrollIndicator = YES;
    [background addSubview:presentationContent];
    
    csContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 115, background.bounds.size.width, (background.bounds.size.height - 115))];
    [csContent setBackgroundColor:[UIColor clearColor]];
    [csContent setUserInteractionEnabled:YES];
    csContent.showsVerticalScrollIndicator = YES;
    csContent.hidden = YES;
    [background addSubview:csContent];
    
    sContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 115, background.bounds.size.width, (background.bounds.size.height - 115))];
    [sContent setBackgroundColor:[UIColor clearColor]];
    [sContent setUserInteractionEnabled:YES];
    sContent.hidden = YES;
    sContent.showsVerticalScrollIndicator = YES;
    [background addSubview:sContent];
    
    vContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 115, background.bounds.size.width, (background.bounds.size.height - 115))];
    [vContent setBackgroundColor:[UIColor clearColor]];
    [vContent setUserInteractionEnabled:YES];
    vContent.hidden = YES;
    vContent.showsVerticalScrollIndicator = YES;
    [background addSubview:vContent];
    
    tContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 115, background.bounds.size.width, (background.bounds.size.height - 115))];
    [tContent setBackgroundColor:[UIColor clearColor]];
    [tContent setUserInteractionEnabled:YES];
    tContent.hidden = YES;
    tContent.showsVerticalScrollIndicator = YES;
    [background addSubview:tContent];
    
    emailContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 115, background.bounds.size.width, (background.bounds.size.height - 115))];
    [emailContent setBackgroundColor:[UIColor clearColor]];
    [emailContent setUserInteractionEnabled:YES];
    emailContent.showsVerticalScrollIndicator = YES;
    emailContent.hidden = YES;
    [background addSubview:emailContent];
    
    UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoButton setFrame:CGRectMake(56, 56, 108, 33)];
    //[logoButton addTarget:self action:@selector(hiddenSection:)forControlEvents:UIControlEventTouchUpInside];
    logoButton.showsTouchWhenHighlighted = YES;
    [logoButton setBackgroundImage:[UIImage imageNamed:@"logo.png"] forState:UIControlStateNormal];
    [self.view addSubview:logoButton];
    
    /*
    UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [homeButton setFrame:CGRectMake(56, 108, 50, 50)];
    [homeButton addTarget:self action:@selector(backHome:)forControlEvents:UIControlEventTouchUpInside];
    homeButton.showsTouchWhenHighlighted = YES;
    homeButton.tag = 80;
    [homeButton setBackgroundImage:[UIImage imageNamed:@"btn-back.png"] forState:UIControlStateNormal];
    [self.view addSubview:homeButton];
    */
    
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [startButton setFrame:CGRectMake(56, 108, 108, 33)];
    [startButton addTarget:self action:@selector(startPresentation:)forControlEvents:UIControlEventTouchUpInside];
    startButton.showsTouchWhenHighlighted = YES;
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
    startButton.backgroundColor = [UIColor whiteColor];
    [startButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    startButton.tag = 80;
    //[startButton setBackgroundImage:[UIImage imageNamed:@"btn-back.png"] forState:UIControlStateNormal];
    [self.view addSubview:startButton];
    
    contentSegController = [[UISegmentedControl alloc]initWithItems:@[@"Presentation", @"Case Studies", @"Samples", @"Videos", @"Testimonials", @"Email"]];
    contentSegController.frame = CGRectMake(190, 56, 700, 33);
    [contentSegController addTarget:self action:@selector(segmentedControlValueDidChange:) forControlEvents:UIControlEventValueChanged];
    [contentSegController setSelectedSegmentIndex:0];
    [contentSegController setTintColor:[UIColor whiteColor]];
    [self.view addSubview:contentSegController];
    
    //NSUserDefaults to check if data has been downloaded.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *parseClasses = @[@"case_study", @"samples", @"testimonials"];
    NSArray *parseClassReference = @[@"field_case_study_tag_reference", @"field_sample_tag_reference", @"field_testimonials_tag_reference"];
    
    [self buildPresentationView];
    for (int i = 0; i < parseClasses.count; i++) {
        if ([[defaults objectForKey:parseClasses[i]] isEqualToString:@"hasData"]) {
            [self fetchDataFromLocalDataStore:parseClasses[i] andSortedBy:parseClassReference[i]];
        }
        else {
            [self fetchDataFromParse:parseClasses[i] andSortedBy:parseClassReference[i]];
        }
    }
    [self buildEmailView];
    //[self fetchDataFromParse:@"videos"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark - Parse
- (void)fetchDataFromParse:(NSString *)forParseClassType andSortedBy:(NSString *)tagReference {
    if ([self connected]) {
        PFQuery *query = [PFQuery queryWithClassName:forParseClassType];
        [query orderByAscending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error) {
                [PFObject pinAllInBackground:objects block:^(BOOL succeded, NSError *error) {
                    if (!error) {
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setObject:@"hasData" forKey:forParseClassType];
                        [defaults synchronize];
                        [self buildOptions:objects forView:forParseClassType withTerm:tagReference];
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
        [self fetchDataFromLocalDataStore:forParseClassType andSortedBy:tagReference];
    }
}

- (void)fetchDataFromLocalDataStore:(NSString *)forParseClassType andSortedBy:(NSString *)tagReference {
    // Query the Local Datastore
    PFQuery *query = [PFQuery queryWithClassName:forParseClassType];
    [query fromLocalDatastore];
    [query orderByAscending:tagReference];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self buildOptions:objects forView:forParseClassType withTerm:tagReference];
        }
    }];
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
#pragma mark - Build Views

-(void)buildPresentationView
{
    //TODO add presentation layout
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 130, 200, 40)];
    descLabel.textColor = [UIColor whiteColor];
    descLabel.numberOfLines = 1;
    descLabel.backgroundColor = [UIColor clearColor];
    descLabel.textAlignment = NSTextAlignmentLeft;
    descLabel.text = @"PRESENTATION VIEW";
    [presentationContent addSubview:descLabel];
}

-(void)buildEmailView
{
    //TODO add email layout
    
    //sample label to show what scrollview was selected
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 130, 200, 40)];
    descLabel.textColor = [UIColor whiteColor];
    descLabel.numberOfLines = 1;
    descLabel.backgroundColor = [UIColor clearColor];
    descLabel.textAlignment = NSTextAlignmentLeft;
    descLabel.text = @"EMAIL VIEW";
    [emailContent addSubview:descLabel];
}

- (void)buildOptions:(NSArray *)objects forView:(NSString *)contentView withTerm:(NSString *)tagReference {
    int y = 0;
    
    NSNumber *refId = 0, *tempId = 0;
    
    for (PFObject *object in objects) {
        refId = [object objectForKey:tagReference];
        
        UILabel *catagoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, y, 550, 40)];
        if ([refId doubleValue] != [tempId doubleValue]) {
            [catagoryLabel setFont:[UIFont fontWithName:@"NimbusSanD-Regu" size:20.0]];
            catagoryLabel.textColor = [UIColor whiteColor];
            catagoryLabel.numberOfLines = 1;
            catagoryLabel.backgroundColor = [UIColor clearColor];
            catagoryLabel.textAlignment = NSTextAlignmentLeft;
            catagoryLabel.text = [NSString stringWithFormat:@"%@", object[tagReference]];
            
            y += 35;
        }
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(185, y, 550, 40)];
        [titleLabel setFont:[UIFont fontWithName:@"NimbusSanD-Regu" size:20.0]];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.numberOfLines = 1;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.text = [NSString stringWithFormat:@"%@", object[@"title"]];
        
        BOOL switchVal;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:[object objectForKey:@"nid"]] == nil) {
            [defaults setObject:@"show" forKey:[object objectForKey:@"nid"]];
            [defaults synchronize];
            switchVal = YES;
        }
        else {
            if ([[defaults objectForKey:[object objectForKey:@"nid"]] isEqualToString:@"show"]) {
                switchVal = YES;
            }
            else {
                switchVal = NO;
            }
        }
        
        UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(800, y, 0, 0)];
        mySwitch.tag = [[object objectForKey:@"nid"] integerValue];
        [mySwitch setOn:switchVal animated:NO];
        [mySwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
        
        if ([contentView isEqualToString:@"case_study"]) {
            [csContent addSubview:titleLabel];
            [csContent addSubview:mySwitch];
            [csContent addSubview:catagoryLabel];
        }
        else if ([contentView isEqualToString:@"samples"]) {
            [sContent addSubview:titleLabel];
            [sContent addSubview:mySwitch];
        }
        else if ([contentView isEqualToString:@"videos"]) {
            [vContent addSubview:titleLabel];
            [vContent addSubview:mySwitch];
            
        }
        else if ([contentView isEqualToString:@"testimonials"]) {
            [tContent addSubview:titleLabel];
            [tContent addSubview:mySwitch];
            
        }

        y += 35;
        
        tempId = refId;
    }
    [csContent setContentSize:CGSizeMake(background.bounds.size.width, (100 * objects.count))];
    [sContent setContentSize:CGSizeMake(background.bounds.size.width, (100 * objects.count))];
    [vContent setContentSize:CGSizeMake(background.bounds.size.width, (100 * objects.count))];
    [tContent setContentSize:CGSizeMake(background.bounds.size.width, (100 * objects.count))];
}



- (void)changeSwitch:(UISwitch *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([sender isOn]) {
        [defaults setObject:@"show" forKey:[NSString stringWithFormat:@"%ld", (long)sender.tag]];
        [defaults synchronize];
        NSLog(@"Switch %ld turned on.", (long)sender.tag);
    }
    else {
        [defaults setObject:@"hide" forKey:[NSString stringWithFormat:@"%ld", (long)sender.tag]];
        [defaults synchronize];
        NSLog(@"Switch %ld turned of.", (long)sender.tag);
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
/*
- (void)backHome:(UIButton *)sender {
    //[self performSegueWithIdentifier:@"brandMeetsWorld" sender:sender];
    [self.navigationController popViewControllerAnimated:YES];
}*/

-(void)startPresentation:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LogoLoaderViewController *lvc = (LogoLoaderViewController *)[storyboard instantiateViewControllerWithIdentifier:@"logoLoaderViewController"];
    [self.navigationController pushViewController:lvc animated:YES];
    //[self performSegueWithIdentifier:@"logoLoaderView" sender:sender];
}

- (void)segmentedControlValueDidChange:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        presentationContent.hidden = NO;
        csContent.hidden = YES;
        sContent.hidden = YES;
        vContent.hidden = YES;
        tContent.hidden = YES;
        emailContent.hidden = YES;
    }
    else if (sender.selectedSegmentIndex == 1) {
        presentationContent.hidden = YES;
        csContent.hidden = NO;
        sContent.hidden = YES;
        vContent.hidden = YES;
        tContent.hidden = YES;
        emailContent.hidden = YES;
    }
    else if (sender.selectedSegmentIndex == 2) {
        presentationContent.hidden = YES;
        csContent.hidden = YES;
        sContent.hidden = NO;
        vContent.hidden = YES;
        tContent.hidden = YES;
        emailContent.hidden = YES;
    }
    else if (sender.selectedSegmentIndex == 3){
        presentationContent.hidden = YES;
        csContent.hidden = YES;
        sContent.hidden = YES;
        vContent.hidden = NO;
        tContent.hidden = YES;
        emailContent.hidden = YES;
        
    }
    else if (sender.selectedSegmentIndex == 4){
        presentationContent.hidden = YES;
        csContent.hidden = YES;
        sContent.hidden = YES;
        vContent.hidden = YES;
        tContent.hidden = NO;
        emailContent.hidden = YES;
    }
    else if (sender.selectedSegmentIndex == 5){
        presentationContent.hidden = YES;
        csContent.hidden = YES;
        sContent.hidden = YES;
        vContent.hidden = YES;
        tContent.hidden = YES;
        emailContent.hidden = NO;
    }

}
#pragma mark
#pragma mark - Memory Management
- (void)removeEverything {
    for (UIView *v in [background subviews]) {
        [v removeFromSuperview];
    }
    [background removeFromSuperview];
}

@end
