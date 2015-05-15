//
//  SendEmail.h
//  Parse_LCP
//
//  Created by Trekk mini-1 on 3/31/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking/AFHTTPRequestOperationManager.h"
#import "AFNetworking/AFHTTPRequestOperation.h"

//email delegate for sending responses and data to the view controllers
@protocol EmailDelegate <NSObject>
@optional
-(void)emailResponse:(NSMutableDictionary *)userData withFlag:(BOOL)flag;

@end

@interface SendEmail : NSObject{
    NSString *url;
    NSMutableDictionary *returnData, *requestData;
}
typedef void(^completeBlockValue)(BOOL completionFlag, NSString * passwordData);
@property (weak, nonatomic) id <EmailDelegate> delegate;
@property (strong) NSMutableDictionary *returnData, *requestData;
-(void)getRequestToken;

@end
