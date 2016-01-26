//
//  AppDelegate.m
//  Parse_LCP
//
//  Created by Timothy C Grable on 1/23/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios_guide#localdatastore/iOS
        [Parse enableLocalDatastore];
        
        // Initialize Parse.
        
         // Producion
         [Parse setApplicationId:@"RoGfDFAHxmi2QxOk2vqhPbRLMtwGwDCK1QU1ownD"
                      clientKey:@"dLKyqbHeZkMeeHyPldsVdl73HktnVUHnq0KgduBV"];
         
        // Dev
        /*
        [Parse setApplicationId:@"HSahbYRu1Fnkjq5Y1BMVQbx67r7DgVpsWglTzND4"
                      clientKey:@"N1fnetz4MSeMZ9BNuOhLaghyU38qYzvrzFDBEU8m"];
         */

        
        // [Optional] Track statistics around application opens.
        [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    });
    
    //register and set the favorite dictionary the user defaults if not present
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"contentFavorites"] == nil){
        dispatch_queue_t _savingQueue = dispatch_queue_create("savingQueue", NULL);
        dispatch_async(_savingQueue, ^{
            NSMutableDictionary *contentFavorites = [[NSMutableDictionary alloc] init];
            [[NSUserDefaults standardUserDefaults] setObject:contentFavorites forKey:@"contentFavorites"];
        });
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
