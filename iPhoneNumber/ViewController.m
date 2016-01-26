//
//  ViewController.m
//  iPhoneNumber
//
//  Created by qk365 on 16/1/25.
//  Copyright © 2016年 qk365. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)phoneAction:(id)sender {
    //设置delegate及presentViewController方法在viewdidAppear或者viewwillAppear中调用下面有效，在viewDidLoad中无效
    if (!self.picker) {
        self.picker = [[ABPeoplePickerNavigationController alloc] init];
//        self.picker.modalPresentationStyle = UIModalPresentationCurrentContext;
//        self.picker.modalInPopover = YES;
//        self.picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        self.picker.peoplePickerDelegate = self;
    }
    //显示一个viewController
    [self presentViewController:self.picker animated:YES completion:nil];
}

//关闭一个viewcontroller
- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    ABAddressBookRef abr = [self.picker addressBook];
    if (abr) {
        //取出所有联系人信息
        CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(abr);
        if (people) {
            UInt16 numberOfPersonsInAB = CFArrayGetCount(people);
            //复制CF数组对象
            ABRecordRef person = nil;
            CFStringRef firstName = nil;
            for (UInt16 i = 0; i < numberOfPersonsInAB; i++) {
                person = CFArrayGetValueAtIndex(people, i);
                firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
                NSLog(@"%@",firstName);
            }
            //CFRelease不能释放nil的对象，会crash
            if (person) {
                CFRelease(person);
            }
            if (firstName) {
                CFRelease(firstName);
            }
            if (people) {
                CFRelease(people);
            }
        }
    }
}

/**
 *  该方法在用户选择通讯录一级列表的某一项时被调用，通过person可以获得选中联系人的所有信息，但当选中的联系人有多个号码，而我们又希望用户可以明确的指定一个号码时(如拨打电话),返回YES允许通讯录进入联系人详情界面：
 *
 *  @param peoplePicker <#peoplePicker description#>
 *  @param person       <#person description#>
 *
 *  @return <#return value description#>
 */
//ios8之前才调用
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    CFStringRef firstName,lastName;
    firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    lastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    
    UIAlertView *myAlertView;
    myAlertView = [[UIAlertView alloc] initWithTitle:@"你选中了" message:[NSString stringWithFormat:@"%@.%@",lastName,firstName] delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
    //点击后弹出该对话框
    [myAlertView show];
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
    //虽然使用了ARC模式，但是Core Foundation框架（CoreFoundation.frameworj）PS:CF开头的仍然需要手动控制内存(CFRELESE)
    CFRelease(firstName);
    CFRelease(lastName);
    return YES;
}
//当用户进入单个联系人信息(二级页面)点击某个字段时，会调用如下方法，返回YES继续进入下一步,点击NO不进入下一步，比如点击电话，返回YES就拨打电话，返回NO不会拨打电话
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    if (property == kABPersonPhoneProperty) {
        ABMutableMultiValueRef phoneMulti = ABRecordCopyValue(phoneMulti, property);
        
        int index = ABMultiValueGetIndexForIdentifier(phoneMulti, identifier);
        NSString *ns = [NSString stringWithFormat:@"%@",ABMultiValueCopyValueAtIndex(phoneMulti, index)];
        
        UIAlertView *myAlertView;
        myAlertView = [[UIAlertView alloc] initWithTitle:@"你选中了" message:ns delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        //点击后弹出改对话框
        [myAlertView show];
        [peoplePicker dismissViewControllerAnimated:YES completion:nil];
    }
    return YES;
}

//当用户离开单个联系人信息(二级页面)点击某个字段时调用
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}

//8.0之后才调用
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    ABMutableMultiValueRef phoneMulti = ABRecordCopyValue(person, kABPersonPhoneProperty);
    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    if (firstName == nil) {
        firstName = @" ";
    }
    
    NSString *lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    if (lastName == nil) {
        lastName = @" ";
    }
    
    NSMutableArray *phones = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < ABMultiValueGetCount(phoneMulti); i++) {
        NSString *aPhone = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneMulti, i);
        [phones addObject:aPhone];
    }
    NSString *phone = @"";
    if (phones.count > 0) {
        phone = [phones objectAtIndex:0];
    }
    NSDictionary *dic = @{
                          @"fullname":[NSString stringWithFormat:@"%@%@",firstName,lastName],
                          @"phone":phone
                          };
    [self.picker dismissViewControllerAnimated:YES completion:nil];
    //不执行默认的操作，如打电话
//    return NO;
}
















@end
