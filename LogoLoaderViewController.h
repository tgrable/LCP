//
//  LogoLoaderViewController.h
//  Parse_LCP
//
//  Created by Timothy C Grable on 2/24/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCPContent.h"

@interface LogoLoaderViewController : UIViewController

//The companyName property get set in ContentSettingsViewController
@property (strong, nonatomic) LCPContent *content;
@property (strong, nonatomic) NSString *companyName;
@property (strong, nonatomic) UIImage *companyLogo;

@end
