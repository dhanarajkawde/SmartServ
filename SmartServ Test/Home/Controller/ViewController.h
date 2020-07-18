//
//  ViewController.h
//  SmartServ Test
//
//  Created by Dhanraj Kawade on 17/07/20.
//  Copyright © 2020 SmartServ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductListTableViewCell.h"
#import "APIManager.h"
#import "RealmProductDetails.h"
#import <Realm/Realm.h>

/// class show product list
@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

{
    RLMResults *arrProduct;
    RLMResults *arrTempProduct;
    long selectedIndex;
    BOOL isSetPriceFilter;
}

@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet UITextField *txtPriceFilter;
@property (weak, nonatomic) IBOutlet UITableView *tblProductList;

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *arrSort;

- (void)getProductList;

@end

