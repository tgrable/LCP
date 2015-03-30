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
@property (strong, nonatomic) UIView *background, *favoriteListView, *formSlidView;
@property (strong, nonatomic) UIScrollView *csContent, *sContent, *vContent, *tContent;
@property (strong, nonatomic) UIScrollView *presentationContent, *emailContent;
@property (nonatomic) UISegmentedControl *contentSegController;
@property (strong, nonatomic) ParseDownload *parsedownload;
@property (strong, nonatomic) UITextField *email, *subject;
@property (strong, nonatomic) UITextView *message;
@end

@implementation ContentSettingsViewController
@synthesize background, favoriteListView, formSlidView;             //UIView
@synthesize csContent, sContent, vContent, tContent;                //UIScrollView
@synthesize presentationContent, emailContent;                      //UIScrollView
@synthesize contentSegController;                                   //UISegmentedControl
@synthesize parsedownload;
@synthesize email, subject;                                         //Email textfields
@synthesize message;                                                //Email textview
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
    
    /*** Start of email views ***/
    
    formSlidView = [[UIView alloc] initWithFrame:CGRectMake(160, 0, 685, 600)];
    formSlidView.backgroundColor = [UIColor clearColor];
    formSlidView.userInteractionEnabled = YES;
    [emailContent addSubview:formSlidView];
    
    UILabel *instructionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 685, 24)];
    instructionLabel.font = [UIFont fontWithName:@"NimbusSanD-Regu" size:19.0];
    instructionLabel.textColor = [UIColor whiteColor];
    instructionLabel.userInteractionEnabled = YES;
    instructionLabel.numberOfLines = 1;
    instructionLabel.backgroundColor = [UIColor clearColor];
    instructionLabel.textAlignment = NSTextAlignmentLeft;
    instructionLabel.text = @"Optionally send an email with notes and favorited content from your presentation.";
    [formSlidView addSubview:instructionLabel];
    
    UILabel *emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 685, 24)];
    emailLabel.font = [UIFont fontWithName:@"NimbusSanD-Regu" size:19.0];
    emailLabel.textColor = [UIColor whiteColor];
    emailLabel.userInteractionEnabled = YES;
    emailLabel.numberOfLines = 1;
    emailLabel.backgroundColor = [UIColor clearColor];
    emailLabel.textAlignment = NSTextAlignmentLeft;
    emailLabel.text = @"Email";
    [formSlidView addSubview:emailLabel];
    
    email = [[UITextField alloc] initWithFrame:CGRectMake(0, 64, 685, 32)];
    email.font = [UIFont fontWithName:@"NimbusSanD-Regu" size:19.0];
    [email setBackgroundColor:[UIColor whiteColor]];
    email.enablesReturnKeyAutomatically = YES;
    email.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [email setAutocorrectionType:UITextAutocorrectionTypeNo];
    [email setReturnKeyType:UIReturnKeyNext];
    email.delegate = self;
    email.textColor = [UIColor blackColor];
    [formSlidView addSubview:email];
    
    UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 110, 685, 24)];
    subjectLabel.font = [UIFont fontWithName:@"NimbusSanD-Regu" size:19.0];
    subjectLabel.textColor = [UIColor whiteColor];
    subjectLabel.userInteractionEnabled = YES;
    subjectLabel.numberOfLines = 1;
    subjectLabel.backgroundColor = [UIColor clearColor];
    subjectLabel.textAlignment = NSTextAlignmentLeft;
    subjectLabel.text = @"Email Subject";
    [formSlidView addSubview:subjectLabel];
    
    subject = [[UITextField alloc] initWithFrame:CGRectMake(0, 134, 685, 32)];
    subject.font = [UIFont fontWithName:@"NimbusSanD-Regu" size:19.0];
    [subject setBackgroundColor:[UIColor whiteColor]];
    subject.enablesReturnKeyAutomatically = YES;
    [subject setReturnKeyType:UIReturnKeyNext];;
    subject.delegate = self;
    subject.textColor = [UIColor blackColor];
    [formSlidView addSubview:subject];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 180, 685, 24)];
    messageLabel.font = [UIFont fontWithName:@"NimbusSanD-Regu" size:19.0];
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.userInteractionEnabled = YES;
    messageLabel.numberOfLines = 1;
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.textAlignment = NSTextAlignmentLeft;
    messageLabel.text = @"Email Message";
    [formSlidView addSubview:messageLabel];
    
    message = [[UITextView alloc] initWithFrame:CGRectMake(0, 206, 685, 144)];
    message.font = [UIFont fontWithName:@"NimbusSanD-Regu" size:18.0];
    [message setBackgroundColor:[UIColor whiteColor]];
    message.enablesReturnKeyAutomatically = YES;
    message.text = @"";
    message.delegate = self;
    message.autocapitalizationType = UITextAutocapitalizationTypeNone;
    message.spellCheckingType = UITextSpellCheckingTypeNo;
    message.autocorrectionType = UITextAutocorrectionTypeNo;
    message.textColor = [UIColor blackColor];
    [formSlidView addSubview:message];
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
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
    favoritedContent.font = [UIFont fontWithName:@"NimbusSanD-Regu" size:19.0];
    favoritedContent.textColor = [UIColor whiteColor];
    favoritedContent.numberOfLines = 1;
    favoritedContent.backgroundColor = [UIColor clearColor];
    favoritedContent.textAlignment = NSTextAlignmentLeft;
    favoritedContent.text = @"FAVORITED CONTENT";
    [emailContent addSubview:favoritedContent];
    
    favoriteListView = [[UIView alloc] initWithFrame:CGRectMake(160, 470, 685, 0)];
    [emailContent addSubview:favoriteListView];
    
    /*** /End of email views ***/
    
    UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoButton setFrame:CGRectMake(56, 56, 108, 33)];
    logoButton.showsTouchWhenHighlighted = YES;
    [logoButton setBackgroundImage:[UIImage imageNamed:@"logo.png"] forState:UIControlStateNormal];
    [self.view addSubview:logoButton];
    
    
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [startButton setFrame:CGRectMake(56, 108, 108, 33)];
    [startButton addTarget:self action:@selector(startPresentation:)forControlEvents:UIControlEventTouchUpInside];
    startButton.showsTouchWhenHighlighted = YES;
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
    startButton.backgroundColor = [UIColor whiteColor];
    [startButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
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
    //[self fetchDataFromParse:@"videos"];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //build email view is executed here so that the list is always refreshed
    [self refreshEmailList];
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
#pragma mark - Email Functionality
//utility function to slide the form back into position if it was left slid up
-(void)moveFormFieldBackIntoPosition
{
    if(formSlidView.frame.origin.y < 0){
        [UIView animateWithDuration:0.9f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            formSlidView.frame = CGRectMake(160, 0, 685, 600);
        }completion:^(BOOL finished) {}];
    }
}

//textview delegate function to slide the form view up when the keyboard is blocking it
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if(formSlidView.frame.origin.y == 0){
        [UIView animateWithDuration:0.9f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            formSlidView.frame = CGRectMake(160, -160, 685, 600);
        }completion:^(BOOL finished) {}];
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
    
    NSLog(@"View %@", [touch view]);
    
    [super touchesBegan:touches withEvent:event];
}

//delegate function passes focus to textfields
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Tell the keyboard where to go on next button
    if(textField == email){
        [subject becomeFirstResponder];
    }else if (textField == subject){
        [message becomeFirstResponder];
    }
 
    return YES;
}
//email submission functionality
-(void)submitEmail:(id)sender
{
    
    //check to make sure values are present and the email is valid
    if([email.text length] > 0){
        if([subject.text length] > 0){
            if([parsedownload checkForValidEmail:email.text]){
                if([message.text length] > 0){
                    
                    //@TODO Send email with the data to drupal
                    
                    [self displayMessage:@"success!!!!"];
                    //move the form field back into place if needed
                    [self moveFormFieldBackIntoPosition];
                    
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
-(void)refreshEmailList
{
    /* remove all views attached to favoriteList */
    for(UIView *v in [favoriteListView subviews]){
        [v removeFromSuperview];
    }
    
    int yVal = 0;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *favoriteList = [defaults objectForKey:@"contentFavorites"];
    // make sure content is available
    if([favoriteList count] > 0){
        for(id key in favoriteList){
            
            UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, yVal, 300, 24)];
            messageLabel.font = [UIFont fontWithName:@"NimbusSanD-Regu" size:19.0];
            messageLabel.textColor = [UIColor whiteColor];
            messageLabel.numberOfLines = 1;
            messageLabel.backgroundColor = [UIColor clearColor];
            messageLabel.textAlignment = NSTextAlignmentLeft;
            messageLabel.text = [favoriteList objectForKey:key];
            [favoriteListView addSubview:messageLabel];
            
            yVal += 40;
        }
    }else{
        UILabel *noMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 685, 24)];
        noMessageLabel.font = [UIFont fontWithName:@"NimbusSanD-Regu" size:19.0];
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

#pragma 
#pragma mark - Display Message

-(void)displayMessage:(NSString *)displayMessage
{
    UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"ALERT" message: displayMessage
                                                   delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
    [error show];
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
        [self.view bringSubviewToFront:presentationContent];
    }
    else if (sender.selectedSegmentIndex == 1) {
        presentationContent.hidden = YES;
        csContent.hidden = NO;
        sContent.hidden = YES;
        vContent.hidden = YES;
        tContent.hidden = YES;
        emailContent.hidden = YES;
        [self.view bringSubviewToFront:csContent];
    }
    else if (sender.selectedSegmentIndex == 2) {
        presentationContent.hidden = YES;
        csContent.hidden = YES;
        sContent.hidden = NO;
        vContent.hidden = YES;
        tContent.hidden = YES;
        emailContent.hidden = YES;
        [self.view bringSubviewToFront:sContent];
    }
    else if (sender.selectedSegmentIndex == 3){
        presentationContent.hidden = YES;
        csContent.hidden = YES;
        sContent.hidden = YES;
        vContent.hidden = NO;
        tContent.hidden = YES;
        emailContent.hidden = YES;
        [self.view bringSubviewToFront:vContent];
    }
    else if (sender.selectedSegmentIndex == 4){
        presentationContent.hidden = YES;
        csContent.hidden = YES;
        sContent.hidden = YES;
        vContent.hidden = YES;
        tContent.hidden = NO;
        emailContent.hidden = YES;
        [self.view bringSubviewToFront:tContent];
    }
    else if (sender.selectedSegmentIndex == 5){
        presentationContent.hidden = YES;
        csContent.hidden = YES;
        sContent.hidden = YES;
        vContent.hidden = YES;
        tContent.hidden = YES;
        emailContent.hidden = NO;
        [self.view bringSubviewToFront:emailContent];
    }
    
    //move the form field back into place if needed
    [self moveFormFieldBackIntoPosition];


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
