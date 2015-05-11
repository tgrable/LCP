//
//  LCPCaseStudyMedia.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 5/11/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "LCPCaseStudyMedia.h"

@implementation LCPCaseStudyMedia
@synthesize csMediaTitle;
@synthesize csMediaBody;
@synthesize csMediaNodeId;
@synthesize csMediaTermReferenceId;
@synthesize csMediaImage;
@synthesize csMediaThumb;

- (UIImage *)scaleImages:(UIImage *)originalImg withSize:(CGSize)size {
    CGSize destinationSize = size;
    UIGraphicsBeginImageContext(destinationSize);
    [originalImg drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


@end
