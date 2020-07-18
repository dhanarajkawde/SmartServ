//
//  RealmProductDetails.h
//  SmartServ Test
//
//  Created by Dhanraj Kawade on 17/07/20.
//  Copyright © 2020 SmartServ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

/// class to determine product object
@interface RealmProductDetails : RLMObject

@property NSString *subcategory;
@property NSString *title;
@property long long price;
@property long long popularity;
@property NSString *productId;

@end

NS_ASSUME_NONNULL_END
