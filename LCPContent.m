//
//  LCPContent.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 2/19/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "LCPContent.h"

@implementation LCPContent
@synthesize btnIcons;

- (id) init {
    if (self = [super init])
    {
        btnIcons = [[NSMutableArray alloc] initWithCapacity:6];
    }
    return self;
}
@end
