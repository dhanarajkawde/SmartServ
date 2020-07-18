//
//  ViewController.m
//  SmartServ Test
//
//  Created by Dhanraj Kawade on 17/07/20.
//  Copyright © 2020 SmartServ. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - View Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.txtSearch addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self setUpPicker];
    self.txtPriceFilter.tintColor = [UIColor clearColor];
    
    self.arrSort = @[@"Popularity", @"Price -- Low to High", @"Price -- High to Low", @"Price -- ₹0 To ₹5000", @"Price -- ₹5000 To ₹10000", @"Price -- ₹10000 To ₹20000", @"Price -- ₹20000 To ₹40000", @"Price -- More than ₹40000"];
    
    isSetPriceFilter = NO;
    selectedIndex = 0;
    
    if ([[APIManager sharedManager] connectedToInternet]) { ///check internet connectivity
        
        [self getProductList];
    }
    else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            self->arrProduct = [RealmProductDetails allObjects];
            self->arrTempProduct = self->arrProduct;
            
            [self.tblProductList reloadData];
        });
    }
}

/// set Up picker
- (void)setUpPicker {
    
    self.pickerView = [[UIPickerView alloc] init];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.txtPriceFilter.inputView = self.pickerView;
}

/// hide pickerview
/// @param sender sender
-(void)hidePickerView:(id)sender
{
    [self.txtPriceFilter resignFirstResponder];
    [self filterProduct:selectedIndex];
}

#pragma mark - API Calls

/// product list API call
-(void)getProductList {
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [[APIManager sharedManager] showProgressHUD];
    });
    
    [[APIManager sharedManager] APICall:@"GET" with:@"https://s3.amazonaws.com/open-to-cors/assignment.json" block:^(id response) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [[APIManager sharedManager] hideProgressHUD];
        });
        
        if (response != nil) { /// check for nil
            
            NSDictionary *productListDic = response;
            
            if([productListDic isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *productDic = [productListDic valueForKey:@"products"];
                
                if([productDic isKindOfClass:[NSDictionary class]])
                {
                    NSArray *productKeys = [productDic allKeys];
                    
                    for (int i = 0; i < productKeys.count; i++)
                    {
                        NSDictionary *singleProduct = [productDic valueForKey:[productKeys objectAtIndex:i]];
                        
                        RealmProductDetails *product = [[RealmProductDetails alloc] init];
                        product.productId = [productKeys objectAtIndex:i];
                        product.subcategory = [singleProduct valueForKey:@"subcategory"];
                        product.title = [singleProduct valueForKey:@"title"];
                        product.price = [[singleProduct valueForKey:@"price"] longLongValue];
                        product.popularity = [[singleProduct valueForKey:@"popularity"] longLongValue];
                        
                        // Persist your data
                        RLMRealm *realm = [RLMRealm defaultRealm];
                        [realm transactionWithBlock:^{
                            [realm addOrUpdateObject:product];
                        }];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                       
                        self->arrProduct = [[RealmProductDetails allObjects] sortedResultsUsingKeyPath:@"popularity" ascending:false];
                        self->arrTempProduct = self->arrProduct;
                                            
                        [self.tblProductList reloadData];
                    });
                }
                else
                {
                    [self showAlert:@"Invalid Data"];
                }
            }
            else
            {
                [self showAlert:@"Invalid Data"];
            }
        }
        else {
            [self showAlert:@"Server Error"];
        }
    }];
}

- (void)showAlert:(NSString *)msg {
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
       UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:msg preferredStyle:UIAlertControllerStyleAlert];
       UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
       [alert addAction:ok];
       [self presentViewController:alert animated:YES completion:nil];
    });
}

/// sort as typing
/// @param textField textField description
- (void)textFieldDidChange:(UITextField*)textField
{
    dispatch_async(dispatch_get_main_queue(), ^{
       
        if ([textField.text isEqualToString:@""]) { /// if search text empty
            self->arrTempProduct = self->arrProduct;
        }
        else {
            if (self->isSetPriceFilter == YES) { /// price filter selected
                [self filterProduct:self->selectedIndex];
            }
            else {
                self->arrTempProduct = [self->arrProduct objectsWhere:@"title CONTAINS[cd] %@", textField.text];
            }
        }
                            
        [self.tblProductList reloadData];
    });
}

/// apply filter as per picker selection
/// @param index index description
- (void)filterProduct:(long)index {
    
    if (index == 0) { /// popularity
        
        [self filterProductByRelevance:@"popularity" and:false];
        isSetPriceFilter = NO;
    }
    else if (index == 1) { /// price low to high
        
        [self filterProductByRelevance:@"price" and:true];
        isSetPriceFilter = NO;
    }
    else if (index == 2) { /// price high to low
        
        [self filterProductByRelevance:@"price" and:false];
        isSetPriceFilter = NO;
    }
    else if (index == 3) { /// price 0 to 5000
        
        [self filterProductByPrice:0 and:5000];
        isSetPriceFilter = YES;
    }
    else if (index == 4) { /// price 5000 to 10000
        
        [self filterProductByPrice:5000 and:10000];
        isSetPriceFilter = YES;
    }
    else if (index == 5) { /// price 10000 to 20000
        
        [self filterProductByPrice:10000 and:20000];
        isSetPriceFilter = YES;
    }
    else if (index == 6) { /// price 20000 to 40000
        
        [self filterProductByPrice:20000 and:40000];
        isSetPriceFilter = YES;
    }
    else {
        
        [self filterProductByPrice:40000 and:0];
        isSetPriceFilter = YES;
    }
}

/// Filter product by popularity and price
/// @param type popularity/price
/// @param ascending ascending order
- (void)filterProductByRelevance:(NSString *)type and:(BOOL)ascending {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self->arrProduct = [[RealmProductDetails allObjects] sortedResultsUsingKeyPath:type ascending:ascending];
        
        if (![self.txtSearch.text isEqualToString:@""]) {
            
            self->arrTempProduct = [self->arrProduct objectsWhere:@"title CONTAINS[cd] %@", self.txtSearch.text];
        }
        else {
            self->arrTempProduct = self->arrProduct;
        }
                            
        [self.tblProductList reloadData];
    });
}

/// filter product by price
/// @param min min range
/// @param max max range
- (void)filterProductByPrice:(long long)min and:(long long)max {
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        if (min == 40000) { /// more than 40000
            if ([self.txtSearch.text isEqualToString:@""]) {
                
                self->arrTempProduct = [self->arrProduct objectsWhere:@"price >= %lld", min];
            }
            else {
                self->arrTempProduct = [self->arrProduct objectsWhere:@"title CONTAINS[cd] %@ && price >= %lld", self.txtSearch.text, min];
            }
        }
        else {
            if ([self.txtSearch.text isEqualToString:@""]) {
                self->arrTempProduct = [self->arrProduct objectsWhere:@"price >= %lld && price <= %lld", min, max];
            }
            else {
                self->arrTempProduct = [self->arrProduct objectsWhere:@"title CONTAINS[cd] %@ && price >= %lld && price <= %lld", self.txtSearch.text, min, max];
            }
        }
                            
        [self.tblProductList reloadData];
    });
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [arrTempProduct count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ProductListTableViewCell *productListTableViewCell = [_tblProductList dequeueReusableCellWithIdentifier:@"ProductListTableViewCell" forIndexPath:indexPath];
    
    productListTableViewCell.lblName.text = [[arrTempProduct objectAtIndex:indexPath.row] title];
    productListTableViewCell.lblPrice.text = [NSString stringWithFormat:@"Price: ₹%lld",[[arrTempProduct objectAtIndex:indexPath.row] price]];
    
    if ([productListTableViewCell.lblName.text localizedCaseInsensitiveContainsString:@"apple"]) { /// check for apple product
        productListTableViewCell.imgViwProduct.image = [UIImage imageNamed:@"ios"];
    }
    else {
        productListTableViewCell.imgViwProduct.image = [UIImage imageNamed:@"android"];
    }
        
    return productListTableViewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 100;
}

#pragma mark - UIPickerViewDataSource, UIPickerViewDelegate

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (pickerView == self.pickerView) {
        return 1;
    }
    return 0;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.pickerView) {
        return [self.arrSort count];
    }
    return 0;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == self.pickerView) {
        return self.arrSort[row];
    }
    return nil;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.pickerView) {
        self.txtPriceFilter.text = self.arrSort[row];
        selectedIndex = row;
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (textField == self.txtPriceFilter) {
        
        UIToolbar *toolBar = [[UIToolbar alloc] init];
        toolBar.barStyle = UIBarStyleDefault;
        toolBar.translucent = YES;
        [toolBar sizeToFit];
        toolBar.userInteractionEnabled = true;
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(hidePickerView:)];
        NSArray *toolbarItems = [NSArray arrayWithObjects:doneButton, nil];
        [toolBar setItems:toolbarItems];
        
        textField.inputAccessoryView = toolBar;
    }
    return YES;
}

@end
