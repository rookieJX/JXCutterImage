//
//  ViewController.m
//  JXCutterImage
//
//  Created by yuezuo on 16/5/4.
//  Copyright © 2016年 yuezuo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
/** 创建view */
@property (nonatomic,weak) UIView * cutterView;
/** 开始值 */
@property (nonatomic,assign) CGPoint startP;
@property (weak, nonatomic) IBOutlet UIImageView *iamgeView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:pan];
}

- (void)pan:(UIPanGestureRecognizer *)gesture {
    CGPoint currentP ;
    if (gesture.state == UIGestureRecognizerStateBegan) {// 当开始点击拖动的时候
        // 记录当前的view
        self.startP = [gesture locationInView:self.view];
    } else if (gesture.state == UIGestureRecognizerStateChanged) { // 当在拖拽中的时候
        // 记录拖动的时候的当前view
        currentP = [gesture locationInView:self.view];
        // 记录拖动的矩形
        CGFloat currentW = currentP.x - self.startP.x;
        CGFloat currentH = currentP.y - self.startP.y;
        // 当前的矩形
        self.cutterView.frame = CGRectMake(self.startP.x, self.startP.y, currentW, currentH);
    } else if (gesture.state == UIGestureRecognizerStateEnded) { // 当拖拽结束的时候开始截屏
        // 停止拖拽的时候隐藏view
        
        // 裁剪图片
        // 1. 获取图片位图上下文
        UIGraphicsBeginImageContextWithOptions(self.iamgeView.bounds.size, NO, 0);
        
#warning 注意，这里要先设置裁剪区域之后才能进行渲染，因为在裁剪之后我们裁剪之外会变成白色，如果顺序颠倒之后的话就是将整个图形全部渲染到self.iamgeView.layer上
        // 2. 设置裁剪区域
        UIBezierPath * path = [UIBezierPath bezierPathWithRect:self.cutterView.frame];
        
        // 3. 裁剪
        [path addClip];
        
        // 1.1 获取上下文
        CGContextRef ctf = UIGraphicsGetCurrentContext();
        // 1.2 渲染上下文
        [self.iamgeView.layer renderInContext:ctf];
        
        // 4. 获取图片
        self.iamgeView.image = UIGraphicsGetImageFromCurrentImageContext();
        
        // 5. 关闭位图
        UIGraphicsEndImageContext();
        
        
        // 先将view从父控件中移除
        [self.cutterView removeFromSuperview];
        // 将其指针置空
        self.cutterView = nil;
        
    }
    
}

#pragma mark - 懒加载
- (UIView *)cutterView {
    if (_cutterView == nil) {
        // 因为_cutterView是一个弱引用，会一出生就直接死亡，需要一个强引用
        UIView * view = [[UIView alloc] init];
        view.backgroundColor = [UIColor blackColor];
        view.alpha = 0.4;
        // 当强引用走完这个方法之后也回死亡，只有加入到self.view中才能保证view一直存在
        [self.view addSubview:view];
        _cutterView = view;
    }
    return _cutterView;
}
@end
