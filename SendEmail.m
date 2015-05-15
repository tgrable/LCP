//
//  SendEmail.m
//  Parse_LCP
//
//  Created by Trekk mini-1 on 3/31/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "SendEmail.h"
#import <Security/Security.h>
#import "NSData+Base64Additions.h"

#import "SendEmail.h"
#import <Security/Security.h>
#import "NSData+Base64Additions.h"

//this is a local macro that sets up a class wide logging scheme
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

@implementation SendEmail
@synthesize returnData, requestData;

- (id)init
{
    self = [super init];
    
    if (self != nil){
        // TODO: FIX ME BEFORE DEPLOYING
        url = @"http://dev-lcp-app.pantheon.io";
        returnData = [[NSMutableDictionary alloc] init];
        requestData = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)getRequestToken
{
    [returnData removeAllObjects];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *formattedURL = [NSString stringWithFormat:@"%@/application/token/trekkadmin", url];
    [manager GET:formattedURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        if ([json objectForKey:@"token"] != nil) {
            [requestData setObject:[json objectForKey:@"token"] forKey:@"token"];
            [requestData setObject:[json objectForKey:@"date_stamp"] forKey:@"date_stamp"];
            
            if ([requestData objectForKey:@"token"] != nil && [requestData objectForKey:@"date_stamp"] != nil) {
                //send the user email
                [self sendEmail];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [returnData setValue:@"There was an issue authenticating your request" forKey:@"error"];
                    [_delegate emailResponse:returnData withFlag:NO];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [returnData setValue:@"There was an issue authenticating your request" forKey:@"error"];
                [_delegate emailResponse:returnData withFlag:NO];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ALog(@"Error: %@", error);
        //error
        dispatch_async(dispatch_get_main_queue(), ^{
            [returnData setValue:[error description] forKey:@"error"];
            [_delegate emailResponse:returnData withFlag:NO];
        });
    }];
}

-(void)sendEmail
{
    [returnData removeAllObjects];
    NSString *email = [requestData objectForKey:@"email"];
    NSString *message = [requestData objectForKey:@"message"];
    NSString *subject = [requestData objectForKey:@"subject"];
    NSString *token = [requestData objectForKey:@"token"];
    NSString *date_stamp = [requestData objectForKey:@"date_stamp"];
    NSString *nidList = @"";
    
    NSString *data_key = [NSString stringWithFormat:@"data_%@", token];
    NSString *message_key = [NSString stringWithFormat:@"message_%@", token];
    NSString *subject_key = [NSString stringWithFormat:@"subject_%@", token];
    NSString *nids_key = [NSString stringWithFormat:@"nids_%@", token];
    
    int i = 0;
    for (NSString *nid in [requestData objectForKey:@"favorites"]) {
        if (i > 0) {
            nidList = [NSString stringWithFormat:@"%@,%@", nidList, nid];
        } else {
            nidList = [NSString stringWithFormat:@"%@,",nid];
        }
        i++;
    }
    
    message = [message stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    subject = [subject stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    message = [self base64EncodeString:message];
    subject = [self base64EncodeString:subject];
    
    [self encryptEmail:email complete:^(BOOL completeFlag, NSString *emailData){
        if (completeFlag) {
            NSString *formattedURL = [NSString stringWithFormat:@"%@/application/email", url];
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.requestSerializer.timeoutInterval = 60;
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
            NSDictionary *parameters = @{
                                         data_key: emailData,
                                         message_key: message,
                                         subject_key: subject,
                                         nids_key: nidList,
                                         @"date_stamp": date_stamp,
                                         @"token": token
                                         };
            //ALog(@"Parameters %@", parameters);
            
            [manager POST:formattedURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                ALog(@"Response %@", json);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_delegate emailResponse:responseObject withFlag:YES];
                });
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                ALog(@"Error: %@", error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [returnData setObject:[error description] forKey:@"error"];
                    [_delegate emailResponse:returnData withFlag:NO];
                });
            }];
        } else {
            ALog(@"Your email did not encrypt correctly");
            //error
            dispatch_async(dispatch_get_main_queue(), ^{
                [returnData setValue:@"Your email did not encrypt correctly" forKey:@"error"];
                [_delegate emailResponse:returnData withFlag:NO];
            });
            
        }
    }];
    
}

-(void)encryptEmail:(NSString *)email complete:(void (^)(BOOL completionFlag, NSString * key))doneBlock
{
    
    NSData *inputData = [email dataUsingEncoding:NSUTF8StringEncoding];
    const void *bytes = [inputData bytes];
    int length = [inputData length];
    uint8_t *plainText = malloc(length);
    memcpy(plainText, bytes, length);
    
    /* Open and parse the cert*/
    NSData *certData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"public_key" ofType:@"der"]];
    SecCertificateRef cert = SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)certData);
    SecPolicyRef policy = SecPolicyCreateBasicX509();
    SecTrustRef trust;
    OSStatus status = SecTrustCreateWithCertificates(cert, policy, &trust);
    
    /* You can ignore the SecTrustResultType, but you have to run SecTrustEvaluate
     * before you can get the public key */
    SecTrustResultType trustResult;
    if (status == noErr) {
        status = SecTrustEvaluate(trust, &trustResult);
    }
    
    /* Now grab the public key from the cert */
    SecKeyRef publicKey = SecTrustCopyPublicKey(trust);
    
    /* allocate a buffer to hold the cipher text */
    size_t cipherBufferSize;
    uint8_t *cipherBuffer;
    cipherBufferSize = SecKeyGetBlockSize(publicKey);
    cipherBuffer = malloc(cipherBufferSize);
    
    /* encrypt!! */
    SecKeyEncrypt(publicKey, kSecPaddingPKCS1, plainText, length, cipherBuffer, &cipherBufferSize);
    
    
    NSData *d = [NSData dataWithBytes:cipherBuffer length:cipherBufferSize];
    NSString *encryptedString = [d encodeBase64ForData];
    encryptedString = [encryptedString stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    
    /* Free the Security Framework Five! */
    CFRelease(cert);
    CFRelease(policy);
    CFRelease(trust);
    CFRelease(publicKey);
    free(cipherBuffer);
    
    
    if ([encryptedString length] > 0) {
        doneBlock(YES, encryptedString);
    } else {
        doneBlock(NO, encryptedString);
    }
}

-(NSString *)base64EncodeString:(NSString *)string
{
    NSData *plainData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedString = [plainData base64EncodedStringWithOptions:0];
    
    return [encodedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
