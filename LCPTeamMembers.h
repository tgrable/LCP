//
//  LCPTeamMembers.h
//  Parse_LCP
//
//  Created by Timothy C Grable on 2/20/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LCPTeamMembers : NSObject

@property (strong, nonatomic) NSString *teamMemberName;
@property (strong, nonatomic) NSString *teamMemberTitle;
@property (strong, nonatomic) NSString *teamMemberBio;
@property (strong, nonatomic) NSString *teamMemberCatagoryId;
@property (strong, nonatomic) UIImage *teamMemberPhoto;
@property (strong, nonatomic) NSString *btnTag;
@property (strong, nonatomic) NSNumber *sortOrder;
@property (nonatomic) BOOL isTeamMember;

@end
