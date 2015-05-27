//
//  ParseDownload.h
//  Parse_LCP
//
//  Created by Tim Grable on 3/27/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ParseDownload : NSObject

@property BOOL videoFileBeingDownloaded;

- (void)downloadAndPinPFObjects;
- (void)downloadAndPinIndividualParseClass:(NSString *)parseClass;

- (void)downloadVideoFile:(UIView *)view forTerm:(NSString *)termId;

- (void)unpinAllPFObjects;
- (BOOL)checkForValidEmail:(NSString *)email;
- (void)unpinIndividualParseClass:(NSString *)parseClass;
- (void)addOrRemoveFavoriteNodeID:(NSString *)nid nodeTitle:(NSString *)title nodeType:(NSString *)type withAddOrRemoveFlag:(BOOL)flag;
@end
