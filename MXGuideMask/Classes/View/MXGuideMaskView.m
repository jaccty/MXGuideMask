//
//  MXGuideMaskView.m
//  MXGuideMask
//
//  Created by Micheal Xiao on 2017/10/9.
//  自定义引导介绍视图 🐾

#import "MXGuideMaskView.h"

#pragma mark - 👀 enum 👀 💤
typedef NS_ENUM(NSInteger,MXGuideMaskItemRegion) {
    ///左上
    MXGuideMaskItemRegionLeftTop = 0,
    ///左下
    MXGuideMaskItemRegionLeftBottom,
    ///右上
    MXGuideMaskItemRegionRightTop,
    ///右下
    MXGuideMaskItemRegionRightBottom
};

@interface MXGuideMaskView()

/** 蒙版 */
@property(nonatomic,strong)UIView* maskView;
/** 箭头图片  */
@property(nonatomic,strong)UIImageView* arrowImgView;
/** 描述LB  */
@property(nonatomic,strong)UILabel *textLB;
/** 蒙版层 */
@property(nonatomic,strong)CAShapeLayer* maskLayer;
/** 当前正在引导的item下标  */
@property(nonatomic,assign)NSInteger currentIndex;
@end

@implementation MXGuideMaskView
{
    NSInteger _count;
    CGRect _visualFrame;
}

#pragma mark - init Method
- (instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:[UIScreen mainScreen].bounds]) {
        ///初始化UI
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithDataSource:(id<MXGuideMaskViewDataSource>)dataSource{
    MXGuideMaskView * guideView = [[MXGuideMaskView alloc]initWithFrame:CGRectZero];
    guideView.dataSource = dataSource;
    return guideView;
}

- (void)setupUI{
    ///添加子控件
    [self addSubview:self.maskView];
    [self addSubview:self.arrowImgView];
    [self addSubview:self.textLB];
    
    ///设置默认值
    NSBundle * currentBundle = [NSBundle bundleForClass:[self class]];
    NSString * path = [currentBundle pathForResource:@"guide_arrow@3x.png" ofType:nil];
    self.arrowImage = [UIImage imageWithContentsOfFile:path];
//    self.arrowImage = [UIImage imageNamed:@"guide_arrow"];
    self.maskBackgroundColor = [UIColor blackColor];
    self.maskAlpha = .7f;
    self.backgroundColor = [UIColor clearColor];
    
    self.textLB.textColor = [UIColor whiteColor];
    self.textLB.font = [UIFont systemFontOfSize:13];
}

#pragma mark - LazyLoad Method
-(UIView *)maskView{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:self.bounds];
    }
    return _maskView;
}

- (UIImageView *)arrowImgView{
    if (!_arrowImgView) {
        _arrowImgView = [[UIImageView alloc] init];
    }
    return  _arrowImgView;
}

- (UILabel *)textLB{
    if (!_textLB) {
        _textLB = [[UILabel alloc]init];
        _textLB.numberOfLines = 0;
    }
    return _textLB;
}

-  (CAShapeLayer *)maskLayer{
    if (!_maskLayer) {
        _maskLayer =  [CAShapeLayer layer];
    }
    return _maskLayer;
}

#pragma mark -  Setter Method
- (void)setArrowImage:(UIImage *)arrowImage{
    _arrowImage = arrowImage;
    self.arrowImgView.image = arrowImage;
}

- (void)setMaskAlpha:(CGFloat)maskAlpha{
    _maskAlpha = maskAlpha;
    self.maskView.alpha = maskAlpha;
}

- (void)setMaskBackgroundColor:(UIColor *)maskBackgroundColor{
    _maskBackgroundColor = maskBackgroundColor;
    self.maskView.backgroundColor = maskBackgroundColor;
}

- (void)setCurrentIndex:(NSInteger)currentIndex{
    _currentIndex = currentIndex;
    
    //显示蒙版
    [self showMask];
    
    //设置子视图的frame
    [self configItemsFrame];
}

#pragma mark - Private Method

- (void)showMask{
    CGPathRef fromPath = self.maskLayer.path;
    
    ///整个蒙版
    self.maskLayer.frame = self.bounds;
    self.maskLayer.fillColor = [UIColor blackColor].CGColor;
    
    ///小提示框的圆角
    CGFloat maskCornerRadius = 5;
    
    ///执行代理方法
    if (self.layout&&[self.layout respondsToSelector:@selector(guideMaskView:cornerRadiusForViewAtIndex:)]) {
        maskCornerRadius = [self.layout guideMaskView:self cornerRadiusForViewAtIndex:self.currentIndex];
    }
    
    ///获取可见区域的路径（开始路径）ps:一个圆角矩形的路径
    _visualFrame = [self fetchVisualFrame];
    UIBezierPath *visualPath = [UIBezierPath bezierPathWithRoundedRect:_visualFrame cornerRadius:maskCornerRadius];
    
    ///终点路径
    UIBezierPath * toPath = [UIBezierPath bezierPathWithRect:self.bounds];
    [toPath appendPath:visualPath];
    
    ///遮盖路径
    self.maskLayer.path = toPath.CGPath;
    self.maskLayer.fillRule = kCAFillRuleEvenOdd;
    self.layer.mask = self.maskLayer;
    
    ///开始移动
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
    anim.duration = 0.3;
    anim.fromValue = (__bridge id _Nullable)(fromPath);
    anim.toValue = (__bridge id _Nullable)(toPath.CGPath);
    [self.maskLayer addAnimation:anim forKey:nil];
}
///获取可见视图的frame
- (CGRect)fetchVisualFrame{
    if (self.currentIndex>=_count) {
        return CGRectZero;
    }
    ///获取可见视图
    UIView *view = [self.dataSource guideMaskView:self viewForItemAtIndex:self.currentIndex];
    ///转化坐标
    CGRect visualRect = [self convertRect:view.frame fromView:view.superview];
    
    ///设置每个item的view与蒙版的边距
    UIEdgeInsets markInsets  = UIEdgeInsetsMake(-8, -8, -8, -8);
    if (self.layout&&[self.layout respondsToSelector:@selector(guideMaskView:insertForViewAtIndex:)]) {
        markInsets = [self.layout guideMaskView:self insertForViewAtIndex:self.currentIndex];
    }
    
    ///根据边距来设置可见视图的frame
    visualRect.origin.x += markInsets.left;
    visualRect.origin.y += markInsets.top;
    visualRect.size.width -= (markInsets.left + markInsets.right);
    visualRect.size.height -= (markInsets.top + markInsets.bottom);
    
    return visualRect;
}


- (void)configItemsFrame{
    ///文字颜色
    if (self.dataSource&&[self.dataSource respondsToSelector:@selector(guideMaskView:colorForDescriptionAtIndex:)]) {
        self.textLB.textColor = [self.dataSource guideMaskView:self colorForDescriptionAtIndex:self.currentIndex];
    }
    ///文字字体
    if (self.dataSource&&[self.dataSource respondsToSelector:@selector(guideMaskView:fontForDescriptionAtIndex:)]) {
        self.textLB.font = [self.dataSource guideMaskView:self fontForDescriptionAtIndex:self.currentIndex];
    }
    ///描述文字
    NSString *desc = [self.dataSource guideMaskView:self descriptionForItemAtIndex:self.currentIndex];
    
    self.textLB.text = desc;
    
    CGFloat descInsetsX = 50;
    ///每个 item 的文字与左右边框间的距离：默认为 50
    if (self.layout&&[self.layout respondsToSelector:@selector(guideMaskView:horizontalInsetForDescriptionAtIndex:)]) {
        descInsetsX = [self.layout guideMaskView:self horizontalInsetForDescriptionAtIndex:self.currentIndex];
    }
    
    CGFloat space = 20;
    ///每个 item 的子视图（当前介绍的子视图、箭头、描述文字）之间的间距：默认为 20
    if (self.layout&&[self.layout respondsToSelector:@selector(guideMaskView:spaceForItemAtIndex:)]) {
        space = [self.layout guideMaskView:self spaceForItemAtIndex:self.currentIndex];
    }

    CGRect textRect,arrowRect;
    CGFloat x = 0;
    CGSize imgSize = self.arrowImgView.image.size;
    CGFloat maxWidth = self.bounds.size.width - 2*descInsetsX;
    
    ///根据文字的长度，字体等来确定size
    CGSize textSize = [desc boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : self.textLB.font} context:NULL].size;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    ///获取item的方位
    MXGuideMaskItemRegion itemRegion = [self fetchVisualRegion];
    switch (itemRegion) {
        case MXGuideMaskItemRegionLeftTop:
        {
            ///左上
            ///箭头图片翻转（默认是右上）
            transform = CGAffineTransformMakeScale(-1, 1);
            arrowRect = CGRectMake(CGRectGetMidX(_visualFrame) - imgSize.width * 0.5, CGRectGetMaxY(_visualFrame) + space, imgSize.width, imgSize.height);
            
            ///设置文字frame
            if (textSize.width < _visualFrame.size.width) {
                ///文字少就以箭头图片居中
                x = CGRectGetMaxX(arrowRect) - textSize.width * 0.5;
            }else{
                ///文字多就以默认边距来确定
                x = descInsetsX;
            }
            textRect = CGRectMake(x, CGRectGetMaxY(arrowRect) + space, textSize.width, textSize.height);
            break;
        }
            
        case MXGuideMaskItemRegionRightTop:
        {
            ///右上
            ///图片不用动
            arrowRect = CGRectMake(CGRectGetMidX(_visualFrame) - imgSize.width *  0.5, CGRectGetMaxY(_visualFrame) + space, imgSize.width, imgSize.height);
            
            ///设置文字frame
            if (textSize.width < _visualFrame.size.width) {
                x = CGRectGetMinX(arrowRect) - textSize.width * 0.5;
            }else{
                x = maxWidth + descInsetsX - textSize.width;
            }
            textRect = CGRectMake(x, CGRectGetMaxY(arrowRect) + space, imgSize.width, imgSize.height);
            break;
        }
        case MXGuideMaskItemRegionLeftBottom:
        {
            ///左下
            ///图片翻转
            transform = CGAffineTransformMakeScale(-1, -1);
            arrowRect = CGRectMake(CGRectGetMidX(_visualFrame) - imgSize.width * 0.5, CGRectGetMinY(_visualFrame) - space - imgSize.height, imgSize.width, imgSize.height);
            
            ///设置文字frame
            if (textSize.width < _visualFrame.size.width) {
                x = CGRectGetMaxX(arrowRect) - textSize.width * 0.5;
            }else{
                x = descInsetsX;
            }
            textRect = CGRectMake(x, CGRectGetMinY(arrowRect) - space - textSize.height, textSize.width, textSize.height);
            break;
        }
        case MXGuideMaskItemRegionRightBottom:
        {
            ///右下
            ///图片翻转
            transform = CGAffineTransformMakeScale(1, -1);
            arrowRect = CGRectMake(CGRectGetMidX(_visualFrame) - imgSize.width * 0.5, CGRectGetMinY(_visualFrame) - space - imgSize.height, imgSize.width,imgSize.height);
            
            if (textSize.width < _visualFrame.size.width) {
                x = CGRectGetMinX(arrowRect) - textSize.width * 0.5;
            }else{
                x = maxWidth + descInsetsX - textSize.width;
            }
            textRect = CGRectMake(x, CGRectGetMinY(arrowRect) - space - textSize.height, textSize.width, textSize.height);
            break;
        }
    }
    ///箭头和文字动画
    [UIView animateWithDuration:0.3 animations:^{
        self.arrowImgView.frame = arrowRect;
        self.arrowImgView.transform = transform;
        self.textLB.frame = textRect;
    }];
}

///获取可见区域的方位
- (MXGuideMaskItemRegion)fetchVisualRegion{
    ///可见区域的中心坐标
    CGPoint visualCenterPoint = CGPointMake(CGRectGetMidX(_visualFrame), CGRectGetMidY(_visualFrame));
    ///self的中心坐标
    CGPoint viewCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    if (visualCenterPoint.x <= viewCenter.x && visualCenterPoint.y <= viewCenter.y) {
        ///可见区域在左上
        return MXGuideMaskItemRegionLeftTop;
    }
    if (visualCenterPoint.x > viewCenter.x && visualCenterPoint.y <= viewCenter.y){
        ///可见区域在右上
        return MXGuideMaskItemRegionRightTop;
    }
    if (visualCenterPoint.x <= viewCenter.x && visualCenterPoint.y > viewCenter.y) {
        ///可见区域在左下
        return MXGuideMaskItemRegionLeftBottom;
    }
    ///其他当成右下
    return MXGuideMaskItemRegionRightBottom;
    
}

#pragma mark - Public Method
///展示
- (void)show{
    if (self.dataSource) {
        _count =  [self.dataSource numberOfItemsInGuideMaskView:self];
    }
    
    ///如果没有可以展示的item
    if (_count < 1) {
        return;
    }
    ///如果有可以展示的item,将该蒙版加载在keywindow上
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    ///设置透明度
    self.alpha = 0;
    [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 1;
    }];
    
    ///从0开始展示
    self.currentIndex = 0;
    
}

#pragma mark - Action Method
- (void)hide{
    [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.currentIndex < _count - 1) {
        self.currentIndex ++;
    }else{
        [self hide];
    }
}
@end
