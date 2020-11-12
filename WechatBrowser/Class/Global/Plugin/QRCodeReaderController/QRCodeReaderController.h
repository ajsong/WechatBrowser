//
//  QRCodeReaderController.h
//
//  Created by ajsong on 15/12/6.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRCodeGenerator.h"
@class QRCodeReaderController;

@protocol QRCodeReaderDelegate<NSObject>
@optional
- (void)QRCodeReader:(QRCodeReaderController *)reader scanResult:(NSString *)result;
@end

@interface QRCodeReaderController : UIViewController
@property (nonatomic,weak) id<QRCodeReaderDelegate> delegate;
@property (nonatomic,strong) UIView *doorUp; //上门
@property (nonatomic,strong) UIView *doorDown; //下门
@property (nonatomic,assign) BOOL enabledDoor; //显示上下门
@property (nonatomic,strong) UILabel *label; //提示文字
@property (nonatomic,strong) UIButton *cancelBtn; //返回按钮
@property (nonatomic,assign) BOOL autoStart; //自动开始扫描
@property (nonatomic,assign) BOOL isFullscreen; //全屏
@property (nonatomic,assign) BOOL enabledMusic; //播放提示声
@property (nonatomic,assign) BOOL showFlashBtn; //显示闪光灯按钮
@property (nonatomic,assign) BOOL showGalleryBtn; //显示相册按钮
@property (nonatomic,assign) CGFloat scanBoxWidth; //扫描框宽度
@property (nonatomic,assign) CGFloat scanBoxHeight; //扫描框高度
@property (nonatomic,assign) CGRect scanFrame; //扫描框frame
@property (nonatomic,strong) UIImageView *scanCursor; //扫描光标
@property (nonatomic,strong) UIImageView *scanBorder; //扫描框边框
@property (nonatomic,copy) void(^scanResult)(QRCodeReaderController *reader, NSString *result); //扫描结果
@property (nonatomic,assign) NSInteger tag;
- (void)setTip:(NSString*)string font:(UIFont*)font;
- (void)pushReturn;
- (void)start;
- (void)stop;
- (void)toggleLightIsOn:(BOOL)on;
- (void)selectImage;
- (void)QRCodeReaderScanResult:(NSString *)result;
@end
