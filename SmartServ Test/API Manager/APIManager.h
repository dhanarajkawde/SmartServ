//
//  APIManager.h
//  SmartServ Test
//
//  Created by Dhanraj Kawade on 17/07/20.
//  Copyright © 2020 SmartServ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject

@property (nonatomic, strong) MBProgressHUD *progressHUD;

typedef void(^APIResponse)(id);

+ (id)sharedManager;

- (void)APICall:(NSString *)methodType with:(NSString *)extendedUrl block:(APIResponse) completion;
- (void)showProgressHUD;
- (void)hideProgressHUD;
- (BOOL)connectedToInternet;

@end

NS_ASSUME_NONNULL_END
