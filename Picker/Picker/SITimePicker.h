//
//  SITimePicker.h
//  SIAPP
//
//  Created by Lenven on 16/7/25.
//  Copyright © 2016年 localadmin. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ARRAYTYPE) {
    DateArray, ///< 年月日时分
    YearArray, ///< 年
    DaysArray, ///< 日
    MonthArray,///< 月
    CommonArray ///< 年月日
    
};
typedef void(^PickerViewBlock) (NSString *dateStr);
@protocol SITimePickerDelegate <NSObject>
@optional;
- (void)PickerSelectorIndixString:(NSString *)str;

@required


@end

@interface SITimePicker : UIView
@property (nonatomic, assign) ARRAYTYPE arrayType;

@property (nonatomic, strong) NSArray *customArr; ///自定义数据源

@property (nonatomic,strong)UILabel *selectLb;

@property (nonatomic, copy)PickerViewBlock pickerBlock; ///< 回传选择时间的block

@property (nonatomic, assign) BOOL isHaveButton; ///< 是否要有取消确定按钮


@property (nonatomic,assign)id<SITimePickerDelegate>delegate;


@end

