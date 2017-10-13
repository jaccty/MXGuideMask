//
//  MXGuideMaskView.h
//  MXGuideMask
//
//  Created by Micheal Xiao on 2017/10/9.
//

#import <UIKit/UIKit.h>
@class MXGuideMaskView;
/**
 数据源协议
 */
@protocol MXGuideMaskViewDataSource<NSObject>

@required

/**
 item 的个数

 @param guideMaskView 引导蒙视图
 @return 返回Items的个数
 */
- (NSInteger)numberOfItemsInGuideMaskView:(MXGuideMaskView*)guideMaskView;

/**
 每个 item 的 view

 @param guideMaskView 引导蒙视图
 @param index 第几个
 @return 根据第 index 个 item 返回 view
 */
- (UIView *)guideMaskView:(MXGuideMaskView *)guideMaskView viewForItemAtIndex:(NSInteger)index;

/**
 每个 item 的文字

 @param guideMaskView 引导蒙视图
 @param index 第几个
 @return 根据第 index 个 item 返回文字
 */
- (NSString *)guideMaskView:(MXGuideMaskView *)guideMaskView descriptionForItemAtIndex:(NSInteger)index;

@optional
/**
 *  每个 item 的文字颜色：默认白色
 */
- (UIColor *)guideMaskView:(MXGuideMaskView *)guideMaskView colorForDescriptionAtIndex:(NSInteger)index;
/**
 *  每个 item 的文字字体：默认 [UIFont systemFontOfSize:13]
 */
- (UIFont *)guideMaskView:(MXGuideMaskView *)guideMaskView fontForDescriptionAtIndex:(NSInteger)index;

@end

@protocol MXGuideMaskViewLayout <NSObject>
@optional
/**
 *  每个 item 的 view 蒙板的圆角：默认为 5
 */
- (CGFloat)guideMaskView:(MXGuideMaskView*)guideMaskView cornerRadiusForViewAtIndex:(NSInteger)index;
/**
 *  每个 item 的 view 与蒙板的边距：默认 (-8, -8, -8, -8)
 */
- (UIEdgeInsets)guideMaskView:(MXGuideMaskView*)guideMaskView insertForViewAtIndex:(NSInteger)index;

/**
 *  每个 item 的子视图（当前介绍的子视图、箭头、描述文字）之间的间距：默认为 20
 */
- (CGFloat)guideMaskView:(MXGuideMaskView *)guideMaskView spaceForItemAtIndex:(NSInteger)index;
/**
 *  每个 item 的文字与左右边框间的距离：默认为 50
 */
- (CGFloat)guideMaskView:(MXGuideMaskView *)guideMaskView horizontalInsetForDescriptionAtIndex:(NSInteger)index;
@end

@interface MXGuideMaskView : UIView

/**
 箭头图片
 */
@property(nonatomic,strong)UIImage *arrowImage;

/**
 蒙板背景颜色：默认 黑色
 */
@property(nonatomic,strong)UIColor *maskBackgroundColor;

/**
 蒙板透明度：默认 .7f
 */
@property (nonatomic, assign)CGFloat maskAlpha;

/**
 数据源
 */
@property(nonatomic,weak)id<MXGuideMaskViewDataSource> dataSource;

/**
 布局
 */
@property(nonatomic,weak)id<MXGuideMaskViewLayout> layout;

/**
 根据一个数据源，来创建一个 guideView
 */
- (instancetype)initWithDataSource:(id<MXGuideMaskViewDataSource>)dataSource;

/**
 显示
 */
- (void)show;

@end
