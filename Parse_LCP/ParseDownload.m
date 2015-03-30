//
//  ParseDownload.m
//  Parse_LCP
//
//  Created by Tim Grable on 3/27/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "ParseDownload.h"
#import "Reachability.h"
#import "AFNetworking.h"
#import <Parse/Parse.h>

@interface ParseDownload ()

@property (strong, nonatomic) NSMutableDictionary *parseClassDictionary;

@end

@implementation ParseDownload

@synthesize parseClassDictionary;

- (void)downloadAndPinPFObjects {
    NSArray *parseClassTypes = @[@"term",@"case_study",@"overview",@"samples",@"team_member",@"testimonials"];
    parseClassDictionary = [[NSMutableDictionary alloc] init];
    
    for (NSString *parseClass in parseClassTypes) {
        [self fetchDataFromParse:parseClass];
    }
}

- (void)unpinAllPFObjects {
    NSArray *parseClassTypes = @[@"term",@"case_study",@"overview",@"samples",@"team_member",@"testimonials"];
    
    for (NSString *parseClass in parseClassTypes) {
        [self clearLocalDataStore:parseClass];
    }
}

- (BOOL)checkForValidEmail:(NSString *)email
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark
#pragma mark - Parse
- (void)fetchDataFromParse:(NSString *)forParseClassType {
    
    if ([self connected]) {
        PFQuery *query = [PFQuery queryWithClassName:forParseClassType];
        [query orderByAscending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error) {
                [PFObject pinAllInBackground:objects block:^(BOOL succeded, NSError *error) {
                    if (!error) {
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setObject:@"hasData" forKey:forParseClassType];
                        [defaults synchronize];
                    }
                }];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Error" message:@"There was an error downloading the data." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [alert show];
            }
        }];
        
    }
}

- (void)clearLocalDataStore:(NSString *)forParseClassType{
    PFQuery *query = [PFQuery queryWithClassName:forParseClassType];
    [query fromLocalDatastore];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                [object unpinInBackground];
                NSLog(@"%@", object.objectId);
                [parseClassDictionary setObject:forParseClassType forKey:@"dataRemoved"];
            }
        }
    }];
}


#pragma mark
#pragma mark - Reachability
- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

@end
