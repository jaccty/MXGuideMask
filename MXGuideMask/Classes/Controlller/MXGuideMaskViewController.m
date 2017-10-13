//
//  MXGuideMaskViewController.m
//  MXGuideMask
//
//  Created by Micheal Xiao on 2017/10/12.
//

#import "MXGuideMaskViewController.h"
#import "MXGuideMaskView.h"
@interface MXGuideMaskViewController ()<MXGuideMaskViewLayout,MXGuideMaskViewDataSource>
@property(nonatomic,strong,nonnull)NSArray* itemViews;
@property(nonatomic,strong)NSArray* descArr;
@end

@implementation MXGuideMaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)maskConfigWithItemViews:(NSArray *)items andDescArr:(NSArray *)descArr{
    self.itemViews = items;
    self.descArr = descArr;
}

- (void)showMask{
    MXGuideMaskView *maskView = [[MXGuideMaskView alloc] initWithDataSource:self];
    maskView.layout = self;
    [maskView show];
}

#pragma  mark - Delegate Method
- (UIView *)guideMaskView:(MXGuideMaskView *)guideMaskView viewForItemAtIndex:(NSInteger)index{
    return self.itemViews[index];
}

- (NSString *)guideMaskView:(MXGuideMaskView *)guideMaskView descriptionForItemAtIndex:(NSInteger)index{
    return self.descArr[index];
}

- (NSInteger)numberOfItemsInGuideMaskView:(MXGuideMaskView *)guideMaskView{
    return self.itemViews.count;
}
- (CGFloat)guideMaskView:(MXGuideMaskView *)guideMaskView cornerRadiusForViewAtIndex:(NSInteger)index
{
//    if (index == self.itemViews.count - 1)
//    {
//        return 25;
//    }
    
    return 5;
}

@end
