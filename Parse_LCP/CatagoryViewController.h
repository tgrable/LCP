//
//  CatagoryViewController.h
//  Parse_LCP
//
//  Created by Timothy C Grable on 2/11/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCPContent.h"
#import <MediaPlayer/MediaPlayer.h>

@interface CatagoryViewController : UIViewController<UIScrollViewDelegate>

@property (strong, nonatomic) LCPContent *content;

@end
