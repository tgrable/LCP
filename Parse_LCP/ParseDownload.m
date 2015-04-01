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
    NSArray *parseClassTypes = @[@"term", @"overview" ,@"case_study", @"samples", @"video", @"team_member",@"testimonials"];
    parseClassDictionary = [[NSMutableDictionary alloc] init];
    
    for (NSString *parseClass in parseClassTypes) {
        [self fetchDataFromParse:parseClass];
    }
}

- (void)downloadAndPinIndividualParseClass:(NSString *)parseClass {
    [self fetchDataFromParse:parseClass];
}

- (void)unpinAllPFObjects {
    NSArray *parseClassTypes = @[@"term", @"overview" ,@"case_study", @"samples", @"video", @"team_member",@"testimonials"];
    
    for (NSString *parseClass in parseClassTypes) {
        [self clearLocalDataStore:parseClass];
    }
}

- (void)unpinIndividualParseClass:(NSString *)parseClass {
    [self clearLocalDataStore:parseClass];
}

- (void)downloadVideoFile {
    PFQuery *query = [PFQuery queryWithClassName:@"video"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableDictionary *videoDataDict = [[NSMutableDictionary alloc] init];
            for (PFObject *object in objects) {
                NSLog(@"%@", [object objectForKey:@"field_video"]);
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[object objectForKey:@"field_video"]]]];
                AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                
                NSString * videoName = [[object objectForKey:@"field_video"] componentsSeparatedByString:@"/videos/"][1];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:videoName];
                operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
                
                [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"Successfully downloaded file to %@", path);
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    
                    videoDataDict[videoName] = [object objectForKey:@"field_term_reference"];
                    
                    [defaults setObject:@"hasData" forKey:videoName];
                    [defaults setObject:videoDataDict forKey:@"VideoDataDictionary"];
                    [defaults synchronize];
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                }];
                [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                    
                    NSLog(@"Download = %f", (float)totalBytesRead / totalBytesExpectedToRead);
                    
                }];
                [operation start];
            }
        }
    }];
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
            }
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"dataRemoved" forKey:forParseClassType];
            [defaults synchronize];
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
