//
//  ProductListTableViewCell.h
//  SmartServ Test
//
//  Created by Dhanraj Kawade on 17/07/20.
//  Copyright © 2020 SmartServ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// class show details of product
@interface ProductListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgViwProduct;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;

@end

NS_ASSUME_NONNULL_END
