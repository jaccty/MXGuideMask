//
//  MXViewController.m
//  MXGuideMask
//
//  Created by 848941531@qq.com on 10/09/2017.
//  Copyright (c) 2017 848941531@qq.com. All rights reserved.
//

#import "MXViewController.h"

@interface MXViewController ()
///自定义顺序将UIView添加进数组
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *collectionViews;

- (IBAction)show;

@end

@implementation MXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self maskConfigWithItemViews:self.collectionViews andDescArr:@[@"1111111111",@"222222222",@"3333333333",@"444444444",@"555555555"]];
}

- (IBAction)show {
    [self showMask];
}

@end
