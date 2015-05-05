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
@property (strong, nonatomic) UIView *background, *favoriteListView, *formSlidView, *loadingView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIScrollView *csContent, *sContent, *vContent, *tContent;
@property (strong, nonatomic) UIScrollView *presentationContent, *emailContent;
@property (nonatomic) UISegmentedControl *contentSegController;
@property (strong, nonatomic) UITextField *email, *subject, *companyNameTextField;
@property (strong, nonatomic) UITextView *message;
@property (strong, nonatomic) UIButton *submitButton;
@property NSMutableArray *favoritedNIDs;
@property NSMutableArray *termsArray;

@property (strong, nonatomic) SendEmail *emailObject;
@property (strong, nonatomic) ParseDownload *parsedownload;

@end

@implementation ContentSettingsViewController
@synthesize background, favoriteListView, formSlidView, loadingView;         //UIView
@synthesize activityIndicator;
@synthesize csContent, sContent, vContent, tContent;                         //UIScrollView
@synthesize presentationContent, emailContent;                               //UIScrollView
@synthesize contentSegController;                                            //UISegmentedControl
@synthesize submitButton;                                                    //UIButons
@synthesize parsedownload, emailObject;                                      //Custom Classes
@synthesize email, subject, companyNameTextField;                            //Email textfields
@synthesize message;                                                         //Email textview
@synthesize favoritedNIDs, termsArray;

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redrawView:) name:@"RefreshParseData" object:nil];

    termsArray = [[NSMutableArray alloc] init];
    emailObject = [[SendEmail alloc] init];
    parsedownload = [[ParseDownload alloc] init];

    [self drawViews];
    
    activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.frame = CGRectMake((background.frame.size.width / 2), (background.frame.size.height / 2), 35.0, 35.0);
    [activityIndicator setColor:[UIColor whiteColor]];
    activityIndicator.hidesWhenStopped = YES;
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

- (void)drawViews {
    //First Page Summary View
    
    background = [[UIView alloc] initWithFrame:CGRectMake(36, 36, (self.view.bounds.size.width - (36 * 2)), (self.view.bounds.size.height - (36 * 2)))];
    [background setBackgroundColor:[UIColor colorWithRed:191.0f/255.0f green:191.0f/255.0f blue:191.0f/255.0f alpha:1.0]];
    [background setUserInteractionEnabled:YES];
    [self.view addSubview:background];
    
    presentationContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 115, background.bounds.size.width, (background.bounds.size.height - 115))];
    [presentationContent setBackgroundColor:[UIColor clearColor]];
    [presentationContent setUserInteractionEnabled:YES];
    presentationContent.showsVerticalScrollIndicator = YES;
    [background addSubview:presentationContent];
    
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
    
    emailContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 115, background.bounds.size.width, (background.bounds.size.height - 115))];
    [emailContent setBackgroundColor:[UIColor clearColor]];
    [emailContent setUserInteractionEnabled:YES];
    emailContent.showsVerticalScrollIndicator = YES;
    emailContent.hidden = YES;
    emailContent.tag = 212;
    [background addSubview:emailContent];
    
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
    [message setReturnKeyType:UIReturnKeySend];
    message.textColor = [UIColor blackColor];
    [formSlidView addSubview:message];
    
    submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
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
    favoritedContent.text = @"FAVORITED CONTENT ATTACHED TO THE EMAIL";
    [emailContent addSubview:favoritedContent];
    
    favoriteListView = [[UIView alloc] initWithFrame:CGRectMake(160, 470, 685, 0)];
    [emailContent addSubview:favoriteListView];
    
    /*** /End of email views ***/
    
    UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoButton setFrame:CGRectMake(60, 6.5f, 70, 23)];
    logoButton.showsTouchWhenHighlighted = YES;
    [logoButton setBackgroundImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
    [self.view addSubview:logoButton];
    
    contentSegController = [[UISegmentedControl alloc]initWithItems:@[@"Presentation", @"Case Studies", @"Samples", @"Videos", @"Testimonials", @"Email"]];
    contentSegController.frame = CGRectMake(190, 56, 700, 33);
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
    //[startButton setTitle:@"Start" forState:UIControlStateNormal];
    startButton.backgroundColor = [UIColor clearColor];
    [startButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:startButton];
    
    UIButton *clearLocalDataButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [clearLocalDataButton setFrame:CGRectMake((self.view.bounds.size.width - 105), 0, 45, 45)];
    [clearLocalDataButton addTarget:self action:@selector(reloadLocalDataStore:)forControlEvents:UIControlEventTouchUpInside];
    clearLocalDataButton.showsTouchWhenHighlighted = YES;
    //[clearLocalDataButton setTitle:@"Refresh Data" forState:UIControlStateNormal];
    [clearLocalDataButton setBackgroundImage:[UIImage imageNamed:@"ico-refresh"] forState:UIControlStateNormal];
    clearLocalDataButton.backgroundColor = [UIColor clearColor];
    [clearLocalDataButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:clearLocalDataButton];
    
    /* Loading View */
    loadingView = [[UIView alloc] initWithFrame:CGRectMake(718, 334, 100, 100)];
    loadingView.alpha = 0.0;
    loadingView.layer.cornerRadius = 5;
    loadingView.layer.masksToBounds = YES;
    loadingView.backgroundColor = [UIColor blackColor];
    [background addSubview:loadingView];
    
    [self buildPresentationView];
    [self fetchTerms];
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
                NSLog(@"fetchDataFromParse returned %lu objects.", (unsigned long)objects.count);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [PFObject pinAllInBackground:objects block:^(BOOL succeded, NSError *error) {
                        if (succeded) {
                            NSLog(@"Fetch: %@", forParseClassType);
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            [defaults setObject:@"hasData" forKey:forParseClassType];
                            [defaults synchronize];
                            
                            [self buildOptions:objects forView:forParseClassType withTerm:tagReference];
                        }
                    }];
                });
            }
            else {
                NSString *errorMsg = [NSString stringWithFormat:@"%@", error];
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
    [query orderByAscending:tagReference];
    dispatch_async(dispatch_get_main_queue(), ^{
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                [self buildOptions:objects forView:forParseClassType withTerm:tagReference];
            }
            else {
                NSString *errorMsg = [NSString stringWithFormat:@"%@", error];
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
                NSLog(@"fetchTerms - local returned %lu objects.", (unsigned long)objects.count);
                for (PFObject *object in objects) {
                    [termsArray addObject:object];
                }
                [self fetchRemainingObjectsFromParse];
            }
            else {
                NSString *errorMsg = [NSString stringWithFormat:@"%@", error];
                [self displayMessage:errorMsg];
            }
        }];
    }
    else {
        PFQuery *query = [PFQuery queryWithClassName:@"term"];
        [query orderByAscending:@"tid"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                NSLog(@"fetchTerms - parse returned %lu objects.", (unsigned long)objects.count);
                [PFObject pinAllInBackground:objects block:^(BOOL succeded, NSError *error) {
                    if (succeded) {
                        for (PFObject *object in objects) {
                            [termsArray addObject:object];
                        }
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
                [self displayMessage:errorMsg];
            }
        }];
    }
}

- (void)fetchRemainingObjectsFromParse {
    //NSUserDefaults to check if data has been downloaded.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *parseClasses = @[@"case_study", @"samples", @"video", @"testimonials"];

    for (NSString *parseClass in parseClasses) {
        if ([[defaults objectForKey:parseClass] isEqualToString:@"hasData"]) {
            [self fetchDataFromLocalDataStore:parseClass andSortedBy:@"field_term_reference"];
        }
        else {
            [self fetchDataFromParse:parseClass andSortedBy:@"field_term_reference"];
        }
    }

    if (![[defaults objectForKey:@"video"] isEqualToString:@"hasData"]) {
        [parsedownload downloadVideoFile:self.view forTerm:@""];
    }
    if (![[defaults objectForKey:@"overview"] isEqualToString:@"hasData"]) {
        [parsedownload downloadAndPinIndividualParseClass:@"overview"];
    }
    if (![[defaults objectForKey:@"team_member"] isEqualToString:@"hasData"]) {
        [parsedownload downloadAndPinIndividualParseClass:@"team_member"];
    }
}

//Download all the data from parse and pin it to the local datastore
- (void)reloadLocalDataStore:(UIButton *)sender {
    [parsedownload downloadAndPinPFObjects];
    [self removeEverything];
    
    [background addSubview:activityIndicator];
    [activityIndicator startAnimating];
}

//Once all data has been downloaded NSNotification is posted and this method is called to redraw the view.
- (void)redrawView:(NSNotification *)notification {
    [self drawViews];
    [activityIndicator stopAnimating];
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
-(void)moveFormFieldBackIntoPosition
{
    if(formSlidView.frame.origin.y < 0){
        [UIView animateWithDuration:0.9f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            formSlidView.frame = CGRectMake(160, 0, 685, 600);
        }completion:^(BOOL finished) {}];
    }
}

//deletgate function for UITextViews
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

//deletgate function for UITextViews
//this function is being used to detect the send button on the keyboard
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
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
                    //make sure the sender is connected to the internet
                    if([self connected]){
                        loadingView.alpha = 0.8;
                        [self moveFormFieldBackIntoPosition];
                        [self.view endEditing:NO];
                        
                        NSMutableDictionary *emailValues = [[NSMutableDictionary alloc] init];
                        [emailValues setValue:email.text forKey:@"email"];
                        [emailValues setValue:subject.text forKey:@"subject"];
                        [emailValues setValue:message.text forKey:@"message"];
                        [emailValues setValue:favoritedNIDs forKey:@"favorites"];
                        
                        //go out to the server if the user wants to log in
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [emailObject sendEmail:emailValues];
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
-(void)refreshEmailList
{
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
            
            UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, yVal, 600, 24)];
            messageLabel.font = [UIFont fontWithName:@"NimbusSanD-Regu" size:19.0];
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

-(void)emailResponse:(NSMutableDictionary *)emailData withFlag:(BOOL)flag
{
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
    // TODO: add presentation layout
    UILabel *companyNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 0, 200, 40)];
    companyNameLabel.textColor = [UIColor whiteColor];
    companyNameLabel.numberOfLines = 1;
    companyNameLabel.backgroundColor = [UIColor clearColor];
    companyNameLabel.textAlignment = NSTextAlignmentLeft;
    companyNameLabel.text = @"Enter Company Name:";
    [presentationContent addSubview:companyNameLabel];
    
    companyNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(24, 50, 400, 40)];
    companyNameTextField.textColor = [UIColor blackColor];
    companyNameTextField.font = [UIFont fontWithName:@"Helvetica" size:15];
    companyNameTextField.backgroundColor = [UIColor whiteColor];
    [companyNameTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [companyNameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [presentationContent addSubview:companyNameTextField];
    
    /*
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 130, 200, 40)];
    descLabel.textColor = [UIColor whiteColor];
    descLabel.numberOfLines = 1;
    descLabel.backgroundColor = [UIColor yellowColor];
    descLabel.textAlignment = NSTextAlignmentLeft;
    descLabel.text = @"PRESENTATION VIEW";
    [presentationContent addSubview:descLabel];
     */
}

- (void)buildOptions:(NSArray *)objects forView:(NSString *)contentView withTerm:(NSString *)tagReference {
    int y = 0;

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
            [catagoryLabel setFont:[UIFont fontWithName:@"NimbusSanD-Regu" size:25.0]];
            catagoryLabel.textColor = [UIColor whiteColor];
            catagoryLabel.numberOfLines = 1;
            catagoryLabel.backgroundColor = [UIColor clearColor];
            catagoryLabel.textAlignment = NSTextAlignmentLeft;
            
            if ([refId isEqual:@"N/A"]) {
                catagoryLabel.text = @"Brand Meets World";
            }
            else {
                catagoryLabel.text = [NSString stringWithFormat:@"%@", termName]; //object[tagReference]];
            }
            
            y += 35;
            
            lineView = [[UIView alloc] initWithFrame:CGRectMake(160, y, 550, 2)];
            lineView.backgroundColor = [UIColor lightGrayColor];
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
            [csContent addSubview:spaceView];
            [csContent addSubview:titleLabel];
            [csContent addSubview:mySwitch];
            [csContent addSubview:catagoryLabel];
            [csContent addSubview:lineView];
            [csContent setContentSize:CGSizeMake(background.bounds.size.width, (75 * objects.count))];
        }
        else if ([contentView isEqualToString:@"samples"]) {
            [sContent addSubview:spaceView];
            [sContent addSubview:titleLabel];
            [sContent addSubview:mySwitch];
            [sContent addSubview:catagoryLabel];
            [sContent addSubview:lineView];
            [sContent setContentSize:CGSizeMake(background.bounds.size.width, (75 * objects.count))];
        }
        else if ([contentView isEqualToString:@"video"]) {
            [vContent addSubview:spaceView];
            [vContent addSubview:titleLabel];
            [vContent addSubview:mySwitch];
            [vContent addSubview:catagoryLabel];
            [vContent addSubview:lineView];
            [vContent setContentSize:CGSizeMake(background.bounds.size.width, (75 * objects.count))];
        }
        else if ([contentView isEqualToString:@"testimonials"]) {
            [tContent addSubview:spaceView];
            [tContent addSubview:titleLabel];
            [tContent addSubview:mySwitch];
            [tContent addSubview:catagoryLabel];
            [tContent addSubview:lineView];
            [tContent setContentSize:CGSizeMake(background.bounds.size.width, (75 * objects.count))];
        }

        y += 35;
        tempId = refId;
    }
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
    lvc.companyName = [companyNameTextField.text uppercaseString];
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
}

// FIXME: This method is only here for development and testing.
- (void)resetDefaults {
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        [defs removeObjectForKey:key];
    }
    [defs synchronize];
}

@end
