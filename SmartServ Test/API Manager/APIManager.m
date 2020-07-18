//
//  APIManager.m
//  SmartServ Test
//
//  Created by Dhanraj Kawade on 17/07/20.
//  Copyright © 2020 SmartServ. All rights reserved.
//

#import "APIManager.h"

@implementation APIManager

static APIManager *sharedManager = nil;

+ (APIManager*)sharedManager {
    static dispatch_once_t once;
    dispatch_once(&once, ^
    {
        sharedManager = [[APIManager alloc] init];
    });
    return sharedManager;
}

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}

/// API call
/// @param methodType method type
/// @param extendedUrl url
/// @param completion completion
-(void)APICall:(NSString *)methodType with:(NSString *)extendedUrl block:(APIResponse) completion {
    
    [self showProgressHUD];

    NSURLSessionConfiguration *config=[NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session=[NSURLSession sessionWithConfiguration:config];
    
    NSURL *url = [NSURL URLWithString:extendedUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    //[request setValue:[[NSUserDefaults standardUserDefaults]valueForKey:@"Auth"] forHTTPHeaderField:@"Authorization"]; for token request
    [request setHTTPMethod:methodType];

    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (data != nil) { /// check for nil
            
            NSDictionary *outerDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            completion(outerDic);
        }
        else {
            completion(data);
        }
    }];

    [dataTask resume];
}

/// Show progress bar
- (void)showProgressHUD {
    [self hideProgressHUD];
    self.progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
    [self.progressHUD removeFromSuperViewOnHide];
    self.progressHUD.bezelView.color = [UIColor colorWithWhite:0.0 alpha:1.0];
    self.progressHUD.contentColor = [UIColor blackColor];
}

/// hide progree bar
- (void)hideProgressHUD {
    if (self.progressHUD != nil) {
        [self.progressHUD hideAnimated:YES];
        [self.progressHUD removeFromSuperview];
        self.progressHUD = nil;
    }
}

/// check internet connectivity
- (BOOL)connectedToInternet
{
    NSString *urlString = @"http://www.google.com/";
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"HEAD"];
    NSHTTPURLResponse *response;

    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: NULL];

    return ([response statusCode] == 200) ? YES : NO;
}

@end
