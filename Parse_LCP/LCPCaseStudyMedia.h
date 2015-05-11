//
//  LCPCaseStudyMedia.h
//  Parse_LCP
//
//  Created by Timothy C Grable on 5/11/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LCPCaseStudyMedia : NSObject

@property (strong, nonatomic) NSString *csMediaTitle;
@property (strong, nonatomic) NSString *csMediaBody;
@property (strong, nonatomic) NSString *csMediaNodeId;
@property (strong, nonatomic) NSString *csMediaTermReferenceId;
@property (strong, nonatomic) UIImage *csMediaImage;
@property (strong, nonatomic) UIImage *csMediaThumb;

- (UIImage *)scaleImages:(UIImage *)originalImg withSize:(CGSize)size;

@end
