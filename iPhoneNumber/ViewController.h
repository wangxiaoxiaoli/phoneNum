//
//  ViewController.h
//  iPhoneNumber
//
//  Created by qk365 on 16/1/25.
//  Copyright © 2016年 qk365. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>

@interface ViewController : UIViewController<ABPeoplePickerNavigationControllerDelegate>

/**
 *  picker系统内置的联系人view对象，此对象来自于引入的AddressBookUI.framework,系统内置的联系人view对象
 */
//保存联系人姓名数组
@property (nonatomic,strong) NSMutableArray *contactNames;
//保存联系人ID数组属性
@property (nonatomic,strong) NSMutableArray *contactIDs;
@property (nonatomic) ABPeoplePickerNavigationController *picker;

@property (weak, nonatomic) IBOutlet UIButton *photoBtn;

- (IBAction)phoneAction:(id)sender;


@end

