//
//  ViewController.h
//  Animacao
//
//  Created by Bruna Garcia on 17/02/14.
//  Copyright (c) 2014 TokenLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *hideView;
@property (strong, nonatomic) IBOutlet UIScrollView *scroll;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end
