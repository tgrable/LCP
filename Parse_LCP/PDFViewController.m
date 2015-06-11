//
//  PDFViewController.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 6/10/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "PDFViewController.h"

@interface PDFViewController ()

@end

@implementation PDFViewController

- (BOOL)prefersStatusBarHidden {
    //Hide status bar
    return YES;
}

#pragma mark
#pragma mark - ViewController Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //UIView 36 pixels smaller than the device bounds used to hold the rest of the view objects
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(36, 36, (self.view.bounds.size.width - (36 * 2)), (self.view.bounds.size.height - (36 * 2)))];
    [background setBackgroundColor:[UIColor lightGrayColor]];
    [background setUserInteractionEnabled:YES];
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
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, background.bounds.size.width, background.bounds.size.height)];
    webView.delegate = self;
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;
    webView.scalesPageToFit = YES;
    webView.userInteractionEnabled = YES;
    webView.backgroundColor = [UIColor whiteColor];
    [background addSubview:webView];
    
    [self loadDocument:@"document.pdf" inView:webView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark - Load PDF
-(void)loadDocument:(NSString*)documentName inView:(UIWebView*)webView
{
    NSString *path = [[NSBundle mainBundle] pathForResource:documentName ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
}

#pragma mark
#pragma mark - Navigation
- (void)backNav:(id)sender {
    
    // Send the presenter back to the BrandMeetsWorldViewController
    [self.navigationController popViewControllerAnimated:YES];
    [self removeEverything];
}

-(void)backToDashboard:(id)sender {
    
    // Send the presenter back to the dashboard
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self removeEverything];
}

#pragma mark
#pragma mark - Memory Management
- (void)removeEverything {
    //Loop through and remove all the views in background
    for (UIView *v in [self.view subviews]) {
        [v removeFromSuperview];
    }
}

@end
