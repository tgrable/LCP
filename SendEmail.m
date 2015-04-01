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

//this is a local macro that sets up a class wide logging scheme
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

@implementation SendEmail

- (id)init
{
    self = [super init];
    
    if (self != nil){
        url = @"";
    }
    return self;
}

-(void)sendEmail:(NSDictionary *)emailData
{
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc] init];
    NSString *email = [emailData objectForKey:@"email"];
    NSString *message = [emailData objectForKey:@"message"];
    NSString *subject = [emailData objectForKey:@"subject"];
    NSString *nidList = @"";
    int i = 0;
    for(NSString *nid in [emailData objectForKey:@"favorites"]){
        if(i > 0){
          nidList = [NSString stringWithFormat:@"%@,%@", nidList, nid];
        }else{
          nidList = [NSString stringWithFormat:@"%@,",nid];
        }
        i++;
    }
    
    message = [message stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    subject = [subject stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    message = [self base64EncodeString:message];
    subject = [self base64EncodeString:subject];
    
    [self encryptEmail:email complete:^(BOOL completeFlag, NSString *emailData){
        if(completeFlag){
            ALog(@"YES");
            //url = [NSString stringWithFormat:@"http://cae.trekkweb.com/data/api/user/login/%@/%@", username, passwordData];
            ALog(@"URL %@", url);
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.requestSerializer.timeoutInterval = 60;
            manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
            NSDictionary *parameters = @{@"data": emailData, @"message": message, @"subject": subject, @"nids": nidList };
            
            [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    ALog(@"JSON: %@", responseObject);
                    [_delegate emailResponse:responseObject withFlag:YES];
                });
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                ALog(@"Error: %@", error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [returnData setObject:[error description] forKey:@"error"];
                    [_delegate emailResponse:returnData withFlag:NO];
                });
            }];
        }else{
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
    
    
    if([encryptedString length] > 0){
        doneBlock(YES, encryptedString);
    }else{
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
