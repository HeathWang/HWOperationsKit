//
//  HWViewController.m
//  HWOperationsKit
//
//  Created by wangcongling on 07/17/2019.
//  Copyright (c) 2019 wangcongling. All rights reserved.
//

#import "HWViewController.h"
#import <HWOperationsKit/HWOperationsKit.h>

@interface HWViewController ()

@property (nonatomic, strong) UIButton *button;

@end

@implementation HWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor colorWithRed:0.000 green:1.000 blue:0.800 alpha:1.00];
    [button setTitle:@"测试" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:button];
    self.button = button;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGSize size = CGSizeMake(100, 60);
    CGRect rect = self.view.bounds;
    self.button.frame = CGRectMake((CGRectGetWidth(rect) - size.width) / 2, (CGRectGetHeight(rect) - size.height) / 2, size.width, size.height);
}

@end
