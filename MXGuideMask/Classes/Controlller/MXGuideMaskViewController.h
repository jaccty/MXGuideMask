//
//  MXGuideMaskViewController.h
//  MXGuideMask
//
//  Created by Micheal Xiao on 2017/10/12.
//

#import <UIKit/UIKit.h>

@interface MXGuideMaskViewController : UIViewController
///配置可见View数组和描述数组
- (void)maskConfigWithItemViews:(NSArray *)items andDescArr:(NSArray *)descArr;
///展示
- (void)showMask;

@end
