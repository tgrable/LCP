//
//  DetailsViewController.m
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

@synthesize content;        //LCPContent
@synthesize contentObject;  //PFObject
@synthesize contentType;    //NSString
@synthesize parsedownload;  //ParseDownload

- (void)viewDidLoad {
    [super viewDidLoad];
    parsedownload = [[ParseDownload alloc] init];
    
    //Create the main image
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
    
    //Info content
    UIView *infoBar = [[UIView alloc] initWithFrame:CGRectMake(36, 616, self.view.bounds.size.width - (36 *2), self.view.bounds.size.height - 652)];
    [infoBar setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:infoBar];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, infoBar.bounds.size.width * 0.25, 50)];
    titleLabel.numberOfLines = 0;
    NSMutableParagraphStyle *styleTitle  = [[NSMutableParagraphStyle alloc] init];
    styleTitle.minimumLineHeight = 26.0f;
    styleTitle.maximumLineHeight = 26.0f;
    NSDictionary *titleAttributtes = @{NSParagraphStyleAttributeName : styleTitle,};
    titleLabel.attributedText = [[NSAttributedString alloc] initWithString:[[contentObject objectForKey:@"title"] uppercaseString] attributes:titleAttributtes];
    titleLabel.font = [UIFont fontWithName:@"Oswald-Bold" size:20.0];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    [titleLabel sizeToFit];
    [infoBar addSubview:titleLabel];
    
    NSArray *bodyArray = [contentObject objectForKey:@"body"];
    NSMutableDictionary *bodyDict = [[NSMutableDictionary alloc] init];
    bodyDict = bodyArray[1];
    
    UIScrollView *summaryScroll = [[UIScrollView alloc] initWithFrame:CGRectMake((infoBar.bounds.size.width * 0.25) + 14, 0, infoBar.bounds.size.width * 0.60, self.view.bounds.size.height - 652)];
    summaryScroll.layer.borderWidth = 1.0f;
    summaryScroll.layer.borderColor = [UIColor whiteColor].CGColor;
    summaryScroll.backgroundColor = [UIColor clearColor];
    [infoBar addSubview:summaryScroll];
    
    NSString *introText = [NSString stringWithFormat:@"%@",[bodyDict objectForKey:@"value"]];
    UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 0, summaryScroll.bounds.size.width - (24 * 2), summaryScroll.bounds.size.height - 48)];
    myLabel.numberOfLines = 0;
    NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
    style.minimumLineHeight = 18.0f;
    style.maximumLineHeight = 18.0f;
    NSDictionary *attributtes = @{NSParagraphStyleAttributeName : style,};
    myLabel.attributedText = [[NSAttributedString alloc] initWithString:introText.stringByConvertingHTMLToPlainText attributes:attributtes];
    myLabel.font = [UIFont fontWithName:@"AktivGrotesk-Regular" size:16.0];
    myLabel.backgroundColor = [UIColor clearColor];
    myLabel.textColor = [UIColor blackColor];
    [myLabel sizeToFit];
    [summaryScroll addSubview:myLabel];
    
    [summaryScroll setContentSize:CGSizeMake(summaryScroll.bounds.size.width, myLabel.frame.size.height)];
    
    UIButton *favButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [favButton setFrame:CGRectMake((infoBar.bounds.size.width - 124), 0, 24, 24)];
    [favButton addTarget:self action:@selector(setContentAsFavorite:)forControlEvents:UIControlEventTouchUpInside];
    favButton.showsTouchWhenHighlighted = YES;
    favButton.tag = [[contentObject objectForKey:@"objectId"] integerValue];
    favButton.titleLabel.text = contentType;
    [favButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"contentFavorites"] objectForKey:[contentObject objectForKey:@"nid"]] != nil){
        [favButton setBackgroundImage:[UIImage imageNamed:@"ico-fav-active"] forState:UIControlStateNormal];
    }else{
        [favButton setBackgroundImage:[UIImage imageNamed:@"ico-fav-inactive"] forState:UIControlStateNormal];
    }
    
    [infoBar addSubview:favButton];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setFrame:CGRectMake((infoBar.bounds.size.width - 80), 0, 60, 30)];
    [doneButton addTarget:self action:@selector(backToContent:)forControlEvents:UIControlEventTouchUpInside];
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
-(void)setContentAsFavorite:(UIButton *)sender {
    NSLog(@"%@", sender.titleLabel.text);
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"contentFavorites"] objectForKey:[contentObject objectForKey:@"nid"]] == nil){
        [parsedownload addOrRemoveFavoriteNodeID:[contentObject objectForKey:@"nid"]
                                       nodeTitle:[contentObject objectForKey:@"title"]
                                        nodeType:sender.titleLabel.text
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
-(void)backToContent:(id)sender {
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
