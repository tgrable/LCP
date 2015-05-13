//
//  SampleDetailsViewController.h
//  Parse_LCP
//
//  Created by Timothy C Grable on 5/4/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "LCPContent.h"

@interface DetailsViewController : UIViewController

@property (strong, nonatomic) LCPContent *content;
@property (strong, nonatomic) PFObject *contentObject;
@property (strong, nonatomic) NSString *contentType;

@end
