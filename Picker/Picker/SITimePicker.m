//
//  SITimePicker.m
//  SIAPP
//
//  Created by Lenven on 16/7/25.
//  Copyright © 2016年 localadmin. All rights reserved.
//

#import "SITimePicker.h"
#define kRowHeight 34
#define SITimePickerScale [[UIScreen mainScreen] bounds].size.height/568.0f
#define RGBA(r, g, b, a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define SITimePickerScreenWidth [[UIScreen mainScreen] bounds].size.width
#define SITimePickerScreenHeight [[UIScreen mainScreen] bounds].size.height
#define SI_IS_IPHONE                   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define SI_IS_IPHONE_6P                (SI_IS_IPHONE && SITimePickerScreenHeight == 736.0f)
#define SI_IS_IPHONE_4                 (SI_IS_IPHONE && SITimePickerScreenHeight == 480.0f)
#define SI_IS_IPHONE_6                 (SI_IS_IPHONE && SITimePickerScreenHeight == 667.0f)
#define SIPickerColorFromRGB(rgbValue)   [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define KWS(weakSelf) __weak __typeof(&*self) weakSelf=self

@interface SITimePicker ()<UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic,strong)UIView *bgV;

@property (nonatomic,strong)UIButton *cancelBtn;

@property (nonatomic,strong)UIButton *completeBtn;

@property (nonatomic,strong)UIPickerView *pickerV;

@property (nonatomic,strong)NSMutableArray *array; ///< 数据源

@property (nonatomic, assign) NSInteger selectedRow; ///< 选中行

@property (nonatomic, strong) NSString *selectedYear; ///< 选中年份


@end

@implementation SITimePicker
- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        [self initData];
        self.frame = CGRectMake(0, 0, SITimePickerScreenWidth, SITimePickerScreenHeight);
        self.backgroundColor = RGBA(51, 51, 51, 0.8);
        self.bgV = [[UIView alloc]initWithFrame:CGRectMake(0, SITimePickerScreenHeight, SITimePickerScreenWidth, [self getHeightOfSelectView])];
        self.bgV.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.bgV];
        [self showAnimation];
        self.pickerV = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,180 * SITimePickerScale)];
        self.pickerV.backgroundColor = SIPickerColorFromRGB(0xffffff);
        self.pickerV.delegate = self;
        self.pickerV.dataSource = self;
        [self.bgV addSubview:self.pickerV];
        
//        UIView *buttonBackView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.pickerV.frame) + 10, kScreenWidth, kScreenHeight - self.pickerV.maxY)];
//        [self.bgV addSubview:buttonBackView];
        UIView * cancelLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.pickerV.frame) + 10, [UIScreen mainScreen].bounds.size.width, 1* SITimePickerScale)];
        cancelLine.backgroundColor = SIPickerColorFromRGB(0x979797);
        [self.bgV addSubview:cancelLine];
        //取消
        self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cancelBtn.frame = CGRectMake(0, CGRectGetMaxY(cancelLine.frame), [UIScreen mainScreen].bounds.size.width/2 - 1, [self getHeightOfSelectView] - cancelLine.frame.origin.y);
        self.cancelBtn.backgroundColor = SIPickerColorFromRGB(0xffffff);
        self.cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
//        [self.cancelBtn setTitleEdgeInsets:UIEdgeInsetsMake(-60, 0, 0, 0)];
        [self.cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.cancelBtn setTitleColor:SIPickerColorFromRGB(0x999999) forState:UIControlStateNormal];
        [self.bgV addSubview:self.cancelBtn];
        
        UIView * middleView;
        middleView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.cancelBtn.frame), CGRectGetMaxY(cancelLine.frame), 1, [self getHeightOfSelectView] - cancelLine.frame.origin.y)];
        middleView.backgroundColor = SIPickerColorFromRGB(0x979797);
        [self.bgV addSubview:middleView];
        //确定
        self.completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.completeBtn.backgroundColor = SIPickerColorFromRGB(0xffffff);
        self.completeBtn.frame = CGRectMake(CGRectGetMaxX(middleView.frame), CGRectGetMaxY(cancelLine.frame), [UIScreen mainScreen].bounds.size.width/2 -1, [self getHeightOfSelectView] - cancelLine.frame.origin.y);
        self.completeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.completeBtn setTitle:@"确定" forState:UIControlStateNormal];
//        [self.completeBtn setTitleEdgeInsets:UIEdgeInsetsMake(-60, 0, 0, 0)];
        [self.completeBtn addTarget:self action:@selector(completeBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.completeBtn setTitleColor:SIPickerColorFromRGB(0x35c7fa) forState:UIControlStateNormal];
        [self.bgV addSubview:self.completeBtn];
        
    }
    return self;
}
- (void)setPickerBlock:(PickerViewBlock)pickerBlock {
    _pickerBlock = pickerBlock;
}
- (void)setIsHaveButton:(BOOL)isHaveButton {
    _isHaveButton = isHaveButton;
    if (!_isHaveButton) {
        [self.completeBtn removeFromSuperview];
        self.completeBtn = nil;
        [self.cancelBtn removeFromSuperview];
        self.cancelBtn = nil;
        CGRect frame = self.bgV.frame;
        frame.origin.y = SITimePickerScreenHeight - 64 - 180 * SITimePickerScale;
        self.bgV.frame = frame;
//        self.bgV.frame.origin.y =[UIScreen mainScreen].bounds.size.height - 64 - 180 * SITimePickerScale;
        CGRect frameY = self.bgV.frame;
        frameY.size.height = 180 * SITimePickerScale;
        self.bgV.frame = frameY;
//        self.bgV.height = 180 * SITimePickerScale;
;
    }
}

- (void)initData {
    self.array = [NSMutableArray array];
    //-1 代表未选中
    self.selectedRow = -1;
    self.isHaveButton = YES;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents *components = [calendar components:unitFlags fromDate:[NSDate date]];
    NSInteger iCurYear = [components year];
    self.selectedYear = [NSString stringWithFormat:@"%ld",(long)iCurYear];
}

- (void)setCustomArr:(NSArray *)customArr{
    _customArr = customArr;
    [self.array addObject:customArr];
    
}

- (void)setArrayType:(ARRAYTYPE)arrayType
{
    NSDate *date = [NSDate date];
    NSCalendar *c = [NSCalendar currentCalendar];
    NSRange days = [c rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    _arrayType = arrayType;
//    _arrayType = DateArray;
    NSMutableArray *yearArray = [NSMutableArray array];
    for (int i = 2016; i <= 2050; i++) {
        [yearArray addObject:[NSString stringWithFormat:@"%02d",i]];
    }
    
    NSMutableArray *monthArray = [[NSMutableArray alloc]init];
    for (int i = 1; i < 13; i ++) {
            
        [monthArray addObject:[NSString stringWithFormat:@"%02d",i]];
    }
    
    NSMutableArray *daysArray = [[NSMutableArray alloc]init];
    for (int i = 1; i <= days.length; i ++) {
        
        [daysArray addObject:[NSString stringWithFormat:@"%02d",i]];
    }
    NSMutableArray *hourArray  = [NSMutableArray array];
    for (int i = 0; i < 24; i ++) {
            
        [hourArray addObject:[NSString stringWithFormat:@"%02d",i]];
    }
    
    NSMutableArray *minuteArray = [NSMutableArray array];
    for (int i = 0; i < 60; i ++) {
        [minuteArray addObject:[NSString stringWithFormat:@"%02d",i]];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8*3600]];
    if (_arrayType == YearArray) {
        [self.array addObject:yearArray];
        [self createCenterViewLabelInfo];
        [formatter setDateFormat:@"yyyy"];
        NSString *currentYear = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
        [self.pickerV selectRow:[yearArray indexOfObject:currentYear] + 35*10 inComponent:0 animated:YES];
        [self pickerView:self.pickerV didSelectRow:[yearArray indexOfObject:currentYear] + 35*10 inComponent:0];
        return;
    }
    else if (_arrayType == MonthArray) {
        [self.array addObject:monthArray];
        [self createCenterViewLabelInfo];
        [formatter setDateFormat:@"MM"];
        NSString *currentMonth = [NSString stringWithFormat:@"%02ld",(long)[[formatter stringFromDate:date]integerValue]];
        [self.pickerV selectRow:[monthArray indexOfObject:currentMonth] + 12*10 inComponent:0 animated:YES];
        [self pickerView:self.pickerV didSelectRow:[monthArray indexOfObject:currentMonth] + 12 * 10 inComponent:1];
        return;
    }
    else if (_arrayType == DaysArray) {
        [self.array addObject:daysArray];
        [self createCenterViewLabelInfo];
        [formatter setDateFormat:@"dd"];
        NSString *currentDay = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
        [self.pickerV selectRow:[daysArray indexOfObject:currentDay] inComponent:0 animated:YES];
        [self pickerView:self.pickerV didSelectRow:[daysArray indexOfObject:currentDay] inComponent:2];
        return;
    }
    else if (_arrayType == CommonArray) {
        [self.array addObject:yearArray];
        [self.array addObject:monthArray];
        [self.array addObject:daysArray];
    }
    else if (_arrayType == DateArray) {
        [self.array addObject:yearArray];
        [self.array addObject:monthArray];
        [self.array addObject:daysArray];
        [self.array addObject:hourArray];
        [self.array addObject:minuteArray];
    }
    [self createCenterViewLabelInfo];
    NSInteger  componentCount = self.array.count;
    [formatter setDateFormat:@"yyyy"];
    NSString *currentYear = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
    [self.pickerV selectRow:[yearArray indexOfObject:currentYear] + 35*10 inComponent:0 animated:YES];
    [self pickerView:self.pickerV didSelectRow:[yearArray indexOfObject:currentYear] + 35*10 inComponent:0];

    [formatter setDateFormat:@"MM"];
    NSString *currentMonth = [NSString stringWithFormat:@"%02ld",(long)[[formatter stringFromDate:date]integerValue]];
    [self.pickerV selectRow:[monthArray indexOfObject:currentMonth] + 12*10 inComponent:1 animated:YES];
    [self pickerView:self.pickerV didSelectRow:[monthArray indexOfObject:currentMonth] + 12 * 10 inComponent:1];

    [formatter setDateFormat:@"dd"];
    NSString *currentDay = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
    [self.pickerV selectRow:[daysArray indexOfObject:currentDay] inComponent:2 animated:YES];
    [self pickerView:self.pickerV didSelectRow:[daysArray indexOfObject:currentDay] inComponent:2];
    if (_arrayType == CommonArray) {
        return;
    }
    if (3 == componentCount) {
        return;
    }
    [formatter setDateFormat:@"HH"];
    NSString *currentHour = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
    [self.pickerV selectRow:[hourArray indexOfObject:currentHour] + 24*10 inComponent:3 animated:YES];
    [self pickerView:self.pickerV didSelectRow:[hourArray indexOfObject:currentHour] + 24 * 10 inComponent:3];

    [formatter setDateFormat:@"mm"];
    NSString *currentMinute = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
    [self.pickerV selectRow:[minuteArray indexOfObject:currentMinute] + 60*10 inComponent:4 animated:YES];
    [self pickerView:self.pickerV didSelectRow:[minuteArray indexOfObject:currentMinute] + 60 * 10 inComponent:4];
}



- (void)createCenterViewLabelInfo {
    CGFloat labelW = SITimePickerScreenWidth/self.array.count;
    CGFloat labelH = self.pickerV.center.y - kRowHeight/2;
    NSArray *titleArr = @[@"年", @"月", @"日", @"时", @"分"];
    for (int i = 1; i <= self.array.count; i++) {
        UILabel *label = [[UILabel alloc] init];
        if (_arrayType == CommonArray) {
            label.frame = CGRectMake(labelW * i - labelW/2 + 14, labelH, 20, kRowHeight);
        }
        else if (_arrayType == YearArray || _arrayType == MonthArray || _arrayType == DaysArray) {
            label.frame = CGRectMake(labelW * i - labelW/2 + 14, labelH, 20, kRowHeight);
        }
        else {
            label.frame = CGRectMake(labelW * i - 20, labelH, 20, kRowHeight);
        }
        if (i == 1) {
            CGRect frame = label.frame;
            frame.origin.x = frame.origin.x + 14;
            label.frame = frame;
        }
        label.font = [UIFont systemFontOfSize:18.f];
        if (_arrayType == MonthArray) {
            label.text = titleArr[1];
        }
        else if (_arrayType == YearArray) {
            label.text = titleArr[0];
        }
        else if (_arrayType == DaysArray) {
            label.text = titleArr[2];
        } else {
            label.text = titleArr[i - 1];
        }
        label.backgroundColor = [UIColor clearColor];
        [self.bgV addSubview:label];
    }
    
    

}
#pragma mark-----UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return self.array.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    NSArray * arr = (NSArray *)[self.array objectAtIndex:component];
    
    return arr.count * 2000;
    
}

- (CGFloat) pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return kRowHeight;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    
    if (!pickerLabel)
    {
        
        pickerLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, SITimePickerScreenWidth/self.array.count, 35)];
        pickerLabel.backgroundColor = SIPickerColorFromRGB(0xffffff);
        pickerLabel.font = [UIFont systemFontOfSize:18.f];
        [pickerLabel setNeedsDisplay];
        pickerLabel.textAlignment = NSTextAlignmentCenter;
    }
    if (row == self.selectedRow) {
        NSArray *arr = (NSArray *)[self.array objectAtIndex:component];
        NSString *title = [arr objectAtIndex:row % arr.count];
        pickerLabel.font = [UIFont systemFontOfSize:20.f];
        pickerLabel.text = title;
//添加下划线和颜色
//        NSString *selectString = title;
//        NSDictionary *attributeDict =@{NSForegroundColorAttributeName : [UIColor orangeColor]};
//        
//        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:selectString attributes:attributeDict];
//        
//        NSRange stringRange = {0,[attributedString length]};
//        [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:stringRange];
//        pickerLabel.attributedText = attributedString;
        
    }else{
        
        pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
        
    }
    return pickerLabel;

    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSArray *arr = (NSArray *)[self.array objectAtIndex:component];
    return [arr objectAtIndex:row % arr.count];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedRow = row;
    if (component == 0) {
        if (_arrayType == DateArray || _arrayType == CommonArray || _arrayType == YearArray) {
            NSArray *arr = (NSArray *)[self.array objectAtIndex:0];
            NSString *year =  [arr objectAtIndex:row % arr.count];
            self.selectedYear = year;
        }
    }
    if (component == 1) {
        if (_arrayType == DateArray || _arrayType == CommonArray) {
            [self changeDaysDataWith:component  selectRow:row];//改变数据源
        }
    }
    if (_arrayType == DaysArray || _arrayType == MonthArray) {
        return;
    }
    [self.pickerV selectRow:row inComponent:component animated:YES];
    [self.pickerV reloadComponent:component];
    UILabel *selectedLabel = (UILabel *)[pickerView viewForRow:row forComponent:component];
    selectedLabel.font = [UIFont systemFontOfSize:20.f];
    
    
}
/**
 *  选择月份改变天数
 */
- (void)changeDaysDataWith:(NSInteger)component  selectRow:(NSInteger)row {
    NSArray *monthArr = (NSArray *)[self.array objectAtIndex:component];
    NSString *month = [monthArr objectAtIndex:row % monthArr.count];
    NSString *dateStr= [self.selectedYear stringByAppendingString:month];// 2012-05-17 11:23:23
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyyMM"];
    NSDate *fromdate=[format dateFromString:dateStr];
    NSCalendar *c = [NSCalendar currentCalendar];
    NSRange days = [c rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:fromdate];
    NSMutableArray *daysArray = [[NSMutableArray alloc]init];
    for (int i = 1; i <= days.length; i ++) {
        [daysArray addObject:[NSString stringWithFormat:@"%02d",i]];
    }
    [self.array replaceObjectAtIndex:component + 1 withObject:daysArray];
    [self.pickerV reloadComponent:component + 1];
    NSInteger dayRow = [self.pickerV selectedRowInComponent:component + 1];
    UILabel *selectedLabel = (UILabel *)[self.pickerV viewForRow:dayRow forComponent:component + 1];
    selectedLabel.font = [UIFont systemFontOfSize:20.f];

}
#pragma mark-----点击方法

- (void)cancelBtnClick{
    
    [self hideAnimation];
    
}
- (void)completeBtnClick{
    
    NSString *fullStr = [NSString string];
    for (int i = 0; i < self.array.count; i++) {
        NSArray *arr = [self.array objectAtIndex:i];
        NSString *str = [arr objectAtIndex:[self.pickerV selectedRowInComponent:i] % arr.count];
        fullStr = [fullStr stringByAppendingString:[NSString stringWithFormat:@"|%@",str]];
    }

    if (_pickerBlock) {
        _pickerBlock(fullStr);
    }
    [self.delegate PickerSelectorIndixString:fullStr];
    [self hideAnimation];
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self hideAnimation];
    
}
//隐藏动画
- (void)hideAnimation{
    KWS(ws);
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = ws.bgV.frame;
        frame.origin.y = SITimePickerScreenHeight;
        ws.bgV.frame = frame;
        ws.bgV.backgroundColor = RGBA(51, 51, 51, 0);
        
    } completion:^(BOOL finished) {
        self.bgV.backgroundColor = SIPickerColorFromRGB(0xfbfbfb);
        [ws.bgV removeFromSuperview];
        [ws removeFromSuperview];
    }];
    
}
//显示动画
- (void)showAnimation{
    KWS(ws);
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = ws.bgV.frame;
        frame.origin.y = SITimePickerScreenHeight-[self getHeightOfSelectView];
        ws.bgV.frame = frame;
    }];
    
}

-(float)getHeightOfSelectView{
    float height =0;
    if (SI_IS_IPHONE_4) {
        height = 310*SITimePickerScale;
    }
    else if (SI_IS_IPHONE_6P) {
        height = 290*SITimePickerScale;
    }
    
    else if(SI_IS_IPHONE_6){
        height = 220*SITimePickerScale;
        
    }
    else{
        height = 305*SITimePickerScale;
    }
    
    return height;
    
}

@end

