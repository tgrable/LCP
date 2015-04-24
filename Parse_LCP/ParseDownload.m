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

@interface ParseDownload () {
    int __block count;
}

@property (strong, nonatomic) NSArray *parseClassTypes;
@property (strong, nonatomic) NSMutableDictionary *parseClassDictionary;

@end

@implementation ParseDownload

@synthesize parseClassTypes;
@synthesize parseClassDictionary;

#pragma mark
#pragma mark - Public API
- (void)downloadAndPinPFObjects {
    parseClassTypes = @[@"term", @"overview" ,@"case_study", @"samples", @"video", @"team_member",@"testimonials"];
    parseClassDictionary = [[NSMutableDictionary alloc] init];
    count = 0;
    for (NSString *parseClass in parseClassTypes) {
        [self fetchDataFromParse:parseClass];
    }
}

- (void)downloadAndPinIndividualParseClass:(NSString *)parseClass {
    [self fetchDataFromParse:parseClass];
}

- (void)unpinAllPFObjects {
    parseClassTypes = @[@"term", @"overview" ,@"case_study", @"samples", @"video", @"team_member",@"testimonials"];
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

//add or remove the favorited node information
- (void)addOrRemoveFavoriteNodeID:(NSString *)nid nodeTitle:(NSString *)title nodeType:(NSString *)type withAddOrRemoveFlag:(BOOL)flag
{
    //get the defaults and pick the content favorites out from this defaults list
    NSMutableDictionary *favoriteList = [[[NSUserDefaults standardUserDefaults] objectForKey:@"contentFavorites"] mutableCopy];
    
    dispatch_queue_t _savingQueue = dispatch_queue_create("savingQueue", NULL);
    
    //if the flag is yes then we add to the dictionary
    if(flag){
        //make sure the value is not already in the dictionary
        if([favoriteList objectForKey:nid] == nil){
            //create an altered title to display our content type associated with the favorited content
            NSString *alteredTitle = [NSString stringWithFormat:@"%@ -- %@", title, type];
            
            [favoriteList setValue:alteredTitle forKey:nid];
        }
        
        //if the flag is no then we remove from the dictionary
    }else{
        if([favoriteList objectForKey:nid] != nil){
            [favoriteList removeObjectForKey:nid];
        }
    }
    //synchronize the data
    dispatch_async(_savingQueue, ^{
        [[NSUserDefaults standardUserDefaults] setObject:favoriteList forKey:@"contentFavorites"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
}

- (void)unpinIndividualParseClass:(NSString *)parseClass {
    [self clearLocalDataStore:parseClass];
}

#pragma mark
#pragma mark - AFNetworking
- (void)downloadVideoFile:(UIView *)view forTerm:(NSString *)termId {

    UIActivityIndicatorView *activityIndicator  = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                                                   UIActivityIndicatorViewStyleWhiteLarge];
    
    [activityIndicator setCenter:CGPointMake(view.frame.size.width/2.0, view.frame.size.height/2.0)];
    activityIndicator.hidesWhenStopped = YES;

    [view addSubview:activityIndicator];
    
    PFQuery *query = [PFQuery queryWithClassName:@"video"];
    if (termId.length) {
       [query whereKey:@"field_term_reference" equalTo:termId];
    }
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
                    NSLog(@"%@", videoDataDict);
                    
                    [activityIndicator stopAnimating];
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Error" message:@"There was an error downloading the data." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    [alert show];
                    NSLog(@"Error: %@", error);
                }];
                [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                    [activityIndicator startAnimating];
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    [PFObject pinAllInBackground:objects block:^(BOOL succeded, NSError *error) {
                        if (!error) {
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            [defaults setObject:@"hasData" forKey:forParseClassType];
                            [defaults synchronize];
                            NSLog(@"Fetch: %@ and set NSUserDefault to %@", forParseClassType, [defaults objectForKey:forParseClassType]);
                            count++;
                            if (count >= parseClassTypes.count) {
                                NSLog(@"Now when do I run");
                                [self postNotificationToRefresh];
                            }
                        }
                    }];
                });
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
            dispatch_async(dispatch_get_main_queue(), ^{
                for (PFObject *object in objects) {
                    NSLog(@"clearLocalData: %@", [object objectForKey:@"title"]);
                    [object unpinInBackground];
                }
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:@"dataRemoved" forKey:forParseClassType];
                [defaults synchronize];
            });
        }
    }];
}

- (void)postNotificationToRefresh {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshParseData" object:nil userInfo:nil];
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
