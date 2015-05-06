//
//  VideoLibraryViewController.h
//  Parse_LCP
//
//  Created by Timothy C Grable on 5/5/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCPContent.h"

@interface LibraryViewController : UIViewController<UIScrollViewDelegate>

@property (strong, nonatomic) LCPContent *content;
@property (strong, nonatomic) NSString *contentType;

@end
