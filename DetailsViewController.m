//
//  SampleDetailsViewController.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 5/4/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "DetailsViewController.h"
#import "ParseDownload.h"
#import "NSString+HTML.h"

@interface DetailsViewController ()

@property (strong, nonatomic) ParseDownload *parsedownload;

@end

@implementation DetailsViewController

@synthesize content;
@synthesize contentID;
@synthesize contentObject;
@synthesize contentType;
@synthesize parsedownload;                           //ParseDownload

- (void)viewDidLoad {
    [super viewDidLoad];
    parsedownload = [[ParseDownload alloc] init];
    
    PFFile *file;
    if ([contentType isEqualToString:@"samples"]) {
       file = contentObject[@"field_sample_image_img"];
    }
    else {
        file = contentObject[@"field_image_img"];
    }
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage *img = [[UIImage alloc] initWithData:data];
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(36, 36, self.view.bounds.size.width - (36 * 2), 560)];
        [imgView setImage:img];
        [imgView setUserInteractionEnabled:YES];
        imgView.alpha = 1.0;
        [self.view addSubview:imgView];
    }];

    
    UIView *infoBar = [[UIView alloc] initWithFrame:CGRectMake(36, 616, self.view.bounds.size.width - (36 *2), self.view.bounds.size.height - 652)];
    [infoBar setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:infoBar];
    
    UITextView *title = [[UITextView alloc] initWithFrame:CGRectMake(20, 0, infoBar.bounds.size.width * 0.25, self.view.bounds.size.height - 652)];
    [title setFont:[UIFont fontWithName:@"Oswald-Bold" size:20.0f]];
    title.editable = NO;
    title.clipsToBounds = YES;
    title.scrollEnabled = NO;
    title.textColor = [UIColor blackColor];
    title.backgroundColor = [UIColor clearColor];
    title.text = [[contentObject objectForKey:@"title"] uppercaseString];
    [infoBar addSubview:title];
    
    NSArray *bodyArray = [contentObject objectForKey:@"body"];
    NSLog(@"%@", bodyArray);
    NSMutableDictionary *bodyDict = [[NSMutableDictionary alloc] init];
    bodyDict = bodyArray[1];
    
    NSString *temp = [NSString stringWithFormat:@"%@", [bodyDict objectForKey:@"value"]];
    UITextView *body = [[UITextView alloc] initWithFrame:CGRectMake((infoBar.bounds.size.width * 0.25) + 14, 0, infoBar.bounds.size.width * 0.5, self.view.bounds.size.height - 652)];
    body.font = [UIFont fontWithName:@"AktivGrotesk-Regular" size:16.0f];
    body.editable = NO;
    body.clipsToBounds = YES;
    body.scrollEnabled = YES;
    body.textColor = [UIColor blackColor];
    body.backgroundColor = [UIColor clearColor];
    body.text = temp.stringByConvertingHTMLToPlainText;
    [infoBar addSubview:body];
    
    UIButton *favButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [favButton setFrame:CGRectMake((infoBar.bounds.size.width - 124), 20, 24, 24)];
    [favButton addTarget:self action:@selector(setContentAsFavorite:)forControlEvents:UIControlEventTouchUpInside];
    favButton.showsTouchWhenHighlighted = YES;
    favButton.tag = [[contentObject objectForKey:@"objectId"] integerValue];
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"contentFavorites"] objectForKey:[contentObject objectForKey:@"nid"]] != nil){
        [favButton setBackgroundImage:[UIImage imageNamed:@"ico-fav-active"] forState:UIControlStateNormal];
    }else{
        [favButton setBackgroundImage:[UIImage imageNamed:@"ico-fav-inactive"] forState:UIControlStateNormal];
    }
    
    [infoBar addSubview:favButton];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setFrame:CGRectMake((infoBar.bounds.size.width - 80), 20, 60, 30)];
    [doneButton addTarget:self action:@selector(backToSamples:)forControlEvents:UIControlEventTouchUpInside];
    doneButton.showsTouchWhenHighlighted = YES;
    doneButton.tag = 1;
    [doneButton setBackgroundImage:[UIImage imageNamed:@"btn-done"] forState:UIControlStateNormal];
    [infoBar addSubview:doneButton];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma
#pragma mark - Favorite Functionality

//pick the current nid of the content and save it to the NSUserDefault
-(void)setContentAsFavorite:(UIButton *)sender
{
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"contentFavorites"] objectForKey:[contentObject objectForKey:@"nid"]] == nil){
        [parsedownload addOrRemoveFavoriteNodeID:[contentObject objectForKey:@"nid"]
                                       nodeTitle:[contentObject objectForKey:@"title"]
                                        nodeType:@"Samples"
                             withAddOrRemoveFlag:YES];
        [sender setBackgroundImage:[UIImage imageNamed:@"ico-fav-active"] forState:UIControlStateNormal];
    }else{
        [parsedownload addOrRemoveFavoriteNodeID:[contentObject objectForKey:@"nid"]
                                       nodeTitle:@""
                                        nodeType:@""
                             withAddOrRemoveFlag:NO];
        [sender setBackgroundImage:[UIImage imageNamed:@"ico-fav-inactive"] forState:UIControlStateNormal];
    }
}


// Send the presenter back to the dashboard
-(void)backToSamples:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    [self removeEverything];
}

#pragma mark
#pragma mark - Memory Management
- (void)removeEverything {
    for (UIView *v in [self.view subviews]) {
        [v removeFromSuperview];
    }
}

@end