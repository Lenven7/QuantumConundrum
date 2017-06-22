//
//  ViewController.m
//  Picker
//
//  Created by LENVEN on 2017/6/22.
//  Copyright © 2017年 LENVEN. All rights reserved.
//

#import "ViewController.h"
#import "SITimePicker.h"
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
@interface ViewController ()
@property (nonatomic, assign) BOOL isHide;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHide = false;
    [self createPicker];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self createPicker];
}

- (void)createPicker {
    SITimePicker *picker = [[SITimePicker alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 100)];
    picker.arrayType = DateArray;
//    picker.arrayType = YearArray;
//    picker.arrayType = DaysArray;
//    picker.arrayType = MonthArray;
//    picker.arrayType = CommonArray;
    
    picker.pickerBlock = ^(NSString *dateStr) {
        NSLog(@"%@", dateStr);
    };
    [self.view addSubview:picker];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
