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

typedef void(^completeBlock)(BOOL);

@property (strong, nonatomic) LCPContent *content;
@property (strong, nonatomic) NSString *nodeId;
@property BOOL isIndividualCaseStudy;

@end
