//
//  CaseStudyViewController.h
//  Parse_LCP
//
//  Created by Timothy C Grable on 2/18/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCPContent.h"

@interface CaseStudyViewController : UIViewController<UIScrollViewDelegate>

@property (strong, nonatomic) LCPContent *content;

@end
