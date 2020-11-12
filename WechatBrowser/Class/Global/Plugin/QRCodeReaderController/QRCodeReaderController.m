//
//  QRCodeReaderController.m
//
//  Created by ajsong on 15/12/6.
//  Copyright (c) 2014 @MARIO. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "QRCodeReaderController.h"
#import "KKNavigationController.h"

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

@interface QRCodeReaderController ()<AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
	AVCaptureSession *_session;
	UIButton *_flashBtn;
	UIButton *_galleryBtn;
	BOOL _isLighting;
	BOOL _breakMesh;
	UIStatusBarStyle _originStatusBarStyle;
	CGFloat _screenHeight;
	BOOL _isRunning;
	BOOL _isNavigationBarHidden;
}
@end

@implementation QRCodeReaderController

- (instancetype)init{
	self = [super init];
	if (self) {
		_autoStart = YES;
		_isFullscreen = YES;
		_enabledDoor = YES;
		_enabledMusic = YES;
		_scanBoxWidth = 200*SCREEN_SCALE;
		_scanBoxHeight = 200*SCREEN_SCALE;
		_isNavigationBarHidden = APPCurrentController.navigationController.navigationBarHidden;
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:_isFullscreen animated:YES];
	if (_isFullscreen) [self statusBarOpacityTo:0];
	if (self.navigationController && [self.navigationController isKindOfClass:[KKNavigationController class]]) {
		((KKNavigationController*)self.navigationController).disableDragBack = YES;
	}
	_breakMesh = NO;
	[self moveMesh];
	if (_autoStart) [self start];
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	[self.navigationController setNavigationBarHidden:_isNavigationBarHidden animated:YES];
	[self stop];
	[self statusBarOpacityTo:1];
	if (self.navigationController && [self.navigationController isKindOfClass:[KKNavigationController class]]) {
		((KKNavigationController*)self.navigationController).disableDragBack = NO;
	}
	_breakMesh = YES;
}

- (void)pushReturn{
	if (self.navigationController) {
		[self.navigationController popViewControllerAnimated:YES];
	} else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor whiteColor];
	[self.navigationController setNavigationBarHidden:_isFullscreen animated:YES];
	self.edgesForExtendedLayout = UIRectEdgeNone;
	
	_screenHeight = SCREEN_HEIGHT;
	if (!_isFullscreen) _screenHeight = SCREEN_HEIGHT - 64;
	CGFloat width = _scanBoxWidth;
	CGFloat height = _scanBoxHeight;
	CGFloat overlayWidth = (SCREEN_WIDTH - width) / 2;
	CGFloat overlayHeight = (_screenHeight - height) / 2;
	UIColor *color = [UIColor colorWithWhite:0 alpha:0.7];
	
	_doorUp = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, _screenHeight/2)];
	_doorUp.backgroundColor = [UIColor whiteColor];
	_doorUp.hidden = !_enabledDoor;
	[self.view addSubview:_doorUp];
	
	_doorDown = [[UIView alloc]initWithFrame:CGRectMake(0, _screenHeight/2, SCREEN_WIDTH, _screenHeight/2)];
	_doorDown.backgroundColor = [UIColor whiteColor];
	_doorDown.hidden = !_enabledDoor;
	[self.view addSubview:_doorDown];
	
	UIView *overlay = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, overlayHeight)];
	overlay.backgroundColor = color;
	[self.view addSubview:overlay];
	
	overlay = [[UIView alloc]initWithFrame:CGRectMake(0, overlayHeight, overlayWidth, height)];
	overlay.backgroundColor = color;
	[self.view addSubview:overlay];
	
	UIView *scanBox = [[UIView alloc]initWithFrame:CGRectMake(overlayWidth, overlayHeight, width, height)];
	scanBox.clipsToBounds = YES;
	[self.view addSubview:scanBox];
	
	overlay = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-overlayWidth, overlayHeight, overlayWidth, height)];
	overlay.backgroundColor = color;
	[self.view addSubview:overlay];
	
	overlay = [[UIView alloc]initWithFrame:CGRectMake(0, _screenHeight-overlayHeight, SCREEN_WIDTH, overlayHeight)];
	overlay.backgroundColor = color;
	[self.view addSubview:overlay];
	
	self.scanFrame = scanBox.frame;
	
	_scanCursor = [[UIImageView alloc]initWithFrame:CGRectMake(0, -110*SCREEN_SCALE, scanBox.frame.size.width, 110*SCREEN_SCALE)];
	_scanCursor.image = [UIImage imageNamed:@"qrcode-scan-cursor"];
	[scanBox addSubview:_scanCursor];
	
	_scanBorder = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-205*SCREEN_SCALE)/2, (_screenHeight-205*SCREEN_SCALE)/2, 205*SCREEN_SCALE, 205*SCREEN_SCALE)];
	_scanBorder.image = [UIImage imageNamed:@"qrcode-scan-border"];
	[self.view addSubview:_scanBorder];
	
	_label = [[UILabel alloc]initWithFrame:CGRectMake(25*SCREEN_SCALE, 0, SCREEN_WIDTH-25*SCREEN_SCALE*2, 0)];
	_label.text = @"请将二维码图像置于方框内，离手机摄像头10CM左右，系统将会自动识别。";
	_label.textColor = COLORWHITE;
	_label.font = FONTBOLD(15);
	_label.backgroundColor = [UIColor clearColor];
	[self.view addSubview:_label];
	_label.autoHeight = UIEdgeInsetsZero;
	_label.top = _scanBorder.frame.origin.y - (iPhone5?50:30)*SCREEN_SCALE - _label.height;
	
	_cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(18*SCREEN_SCALE, _scanBorder.frame.origin.y+_scanBorder.frame.size.height+50*SCREEN_SCALE, SCREEN_WIDTH-18*SCREEN_SCALE*2, 40*SCREEN_SCALE)];
	_cancelBtn.titleLabel.font = _label.font;
	_cancelBtn.backgroundColor = [UIColor clearColor];
	[_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
	[_cancelBtn setTitleColor:COLORWHITE forState:UIControlStateNormal];
	_cancelBtn.layer.borderColor = COLORWHITE.CGColor;
	_cancelBtn.layer.borderWidth = 1.0;
	_cancelBtn.layer.masksToBounds = YES;
	_cancelBtn.layer.cornerRadius = 4;
	[_cancelBtn addTarget:self action:@selector(pushReturn) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_cancelBtn];
	
	_flashBtn = [[UIButton alloc]initWithFrame:CGRectMake(10*SCREEN_SCALE, 10*SCREEN_SCALE, 44*SCREEN_SCALE, 44*SCREEN_SCALE)];
	_flashBtn.backgroundColor = [UIColor clearColor];
	_flashBtn.adjustsImageWhenHighlighted = NO;
	[_flashBtn setBackgroundImage:[UIImage imageNamed:@"qrcode-flash"] forState:UIControlStateNormal];
	[_flashBtn addTarget:self action:@selector(toggleLightBtn) forControlEvents:UIControlEventTouchUpInside];
	_flashBtn.selected = NO;
	_flashBtn.alpha = 0.3;
	_flashBtn.hidden = YES;
	[self.view addSubview:_flashBtn];
	
	_galleryBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-44*SCREEN_SCALE-10*SCREEN_SCALE, 10*SCREEN_SCALE, 44*SCREEN_SCALE, 44*SCREEN_SCALE)];
	_galleryBtn.backgroundColor = [UIColor clearColor];
	[_galleryBtn setBackgroundImage:[UIImage imageNamed:@"qrcode-gallery"] forState:UIControlStateNormal];
	[_galleryBtn addTarget:self action:@selector(selectImage) forControlEvents:UIControlEventTouchUpInside];
	_galleryBtn.hidden = YES;
	[self.view addSubview:_galleryBtn];
	
	CGRect imageRect = CGRectMake((SCREEN_WIDTH-width)/2, (_screenHeight-height)/2, width, height);
	CGRect scanCrop = [self getScanCrop:imageRect readerViewBounds:self.view.frame];
	
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo]; //获取摄像设备
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil]; //创建输入流
	AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init]; //创建输出流
	[output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()]; //设置代理 在主线程里刷新
	output.rectOfInterest = scanCrop;
	
	_session = [[AVCaptureSession alloc]init]; //初始化链接对象
	[_session setSessionPreset:AVCaptureSessionPresetHigh]; //高质量采集率
	if (input && [_session canAddInput:input]) [_session addInput:input];
#if !TARGET_IPHONE_SIMULATOR
	if (output && [_session canAddOutput:output]) {
		[_session addOutput:output];
		//设置扫码支持的编码格式(下面设置条形码和二维码兼容)
		NSMutableArray *types = [[NSMutableArray alloc]init];
		if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
			[types addObject:AVMetadataObjectTypeQRCode];
		}
		if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN13Code]) {
			[types addObject:AVMetadataObjectTypeEAN13Code];
		}
		if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN8Code]) {
			[types addObject:AVMetadataObjectTypeEAN8Code];
		}
		if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
			[types addObject:AVMetadataObjectTypeCode128Code];
		}
		output.metadataObjectTypes = types;
		//output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
	}
	
	AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
	layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	layer.frame = self.view.layer.bounds;
	[self.view.layer insertSublayer:layer atIndex:0];
#endif
}

- (void)moveMesh{
	if (_breakMesh) return;
	CGRect frame = _scanCursor.frame;
	frame.origin.y = _scanCursor.superview.frame.size.height;
	[UIView animateWithDuration:3.0 animations:^{
		_scanCursor.frame = frame;
	} completion:^(BOOL finished) {
		CGRect frame = _scanCursor.frame;
		frame.origin.y = -_scanCursor.frame.size.height;
		_scanCursor.frame = frame;
		[self moveMesh];
	}];
}

- (void)setTip:(NSString *)string font:(UIFont*)font{
	CGFloat y = (_screenHeight-_scanBoxHeight)/2;
	if (!font) font = FONTBOLD(15);
	_label.frame = CGRectMake(25*SCREEN_SCALE, 0, SCREEN_WIDTH-25*SCREEN_SCALE*2, 0);
	_label.text = string;
	_label.font = font;
	_label.autoHeight = UIEdgeInsetsZero;
	_label.top = y-(y-_label.height)/2-_label.height;
	if (_label.height > ceilf(font.lineHeight)) {
		_label.textAlignment = NSTextAlignmentLeft;
	} else {
		_label.textAlignment = NSTextAlignmentCenter;
	}
}

- (UIView*)statusBar{
	UIView *statusBar = nil;
	NSData *data = [NSData dataWithBytes:(unsigned char []){0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x42, 0x61, 0x72} length:9];
	NSString *key = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	id object = [UIApplication sharedApplication];
	if ([object respondsToSelector:NSSelectorFromString(key)]) statusBar = [object valueForKey:key];
	return statusBar;
}

- (void)statusBarOpacityTo:(CGFloat)opacity{
	UIView *statusBar = [self statusBar];
	[UIView animateWithDuration:0.3 animations:^{
		statusBar.alpha = opacity;
	}];
}

- (CGRect)getScanCrop:(CGRect)rect readerViewBounds:(CGRect)readerViewBounds{
	CGFloat x, y, width, height;
	x = (CGRectGetHeight(readerViewBounds)-CGRectGetHeight(rect))/2/CGRectGetHeight(readerViewBounds);
	y = (CGRectGetWidth(readerViewBounds)-CGRectGetWidth(rect))/2/CGRectGetWidth(readerViewBounds);
	width = CGRectGetHeight(rect)/CGRectGetHeight(readerViewBounds);
	height = CGRectGetWidth(rect)/CGRectGetWidth(readerViewBounds);
	return CGRectMake(x, y, width, height);
}

#pragma mark - 闪光灯
- (void)setShowFlashBtn:(BOOL)showFlashBtn{
	_flashBtn.hidden = !showFlashBtn;
}
- (void)toggleLightBtn{
	_flashBtn.selected = !_flashBtn.selected;
	if (_flashBtn.selected) {
		_flashBtn.alpha = 1.0;
	} else {
		_flashBtn.alpha = 0.3;
	}
	[self toggleLightIsOn:_flashBtn.selected];
}
- (void)toggleLightIsOn:(BOOL)on{
	Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
	if (captureDeviceClass != nil) {
		AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
		if ([device hasTorch] && [device hasFlash]){
			[device lockForConfiguration:nil];
			if (on) {
				[device setTorchMode:AVCaptureTorchModeOn];
				[device setFlashMode:AVCaptureFlashModeOn];
			} else {
				[device setTorchMode:AVCaptureTorchModeOff];
				[device setFlashMode:AVCaptureFlashModeOff];
			}
			[device unlockForConfiguration];
		}
	}
}

#pragma mark - 选择图片
- (void)setShowGalleryBtn:(BOOL)showGalleryBtn{
	_galleryBtn.hidden = !showGalleryBtn;
}
- (void)selectImage{
	_originStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	imagePicker.allowsEditing = YES;
	[self presentViewController:imagePicker animated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	[[UIApplication sharedApplication] setStatusBarStyle:_originStatusBarStyle animated:YES];
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
	[self dismissViewControllerAnimated:YES completion:^{
		NSString *result = [QRCodeGenerator QRStringFromImage:image];
		[self ScanCompletion:result];
	}];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
	[self dismissViewControllerAnimated:YES completion:^{
		[[UIApplication sharedApplication] setStatusBarStyle:_originStatusBarStyle animated:YES];
	}];
}

- (void)setEnabledDoor:(BOOL)enabledDoor{
	_enabledDoor = enabledDoor;
	_doorUp.hidden = _doorDown.hidden = !enabledDoor;
}

- (void)start{
	if (_isRunning) return;
	_isRunning = YES;
#if !TARGET_IPHONE_SIMULATOR
	[_session startRunning];
#endif
	CGRect frameUp = _doorUp.frame;
	CGRect frameDown = _doorDown.frame;
	frameUp.origin.y = -_screenHeight/2;
	frameDown.origin.y = _screenHeight;
	[UIView animateWithDuration:0.25 animations:^{
		_doorUp.frame = frameUp;
		_doorDown.frame = frameDown;
	}];
}

- (void)stop{
	if (!_isRunning) return;
	_isRunning = NO;
#if !TARGET_IPHONE_SIMULATOR
	[_session stopRunning];
#endif
	CGRect frameUp = _doorUp.frame;
	CGRect frameDown = _doorDown.frame;
	frameUp.origin.y = 0;
	frameDown.origin.y = _screenHeight/2;
	[UIView animateWithDuration:0.25 animations:^{
		_doorUp.frame = frameUp;
		_doorDown.frame = frameDown;
	}];
}

#pragma mark - 扫描结果
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
	[self stop];
	if (metadataObjects && metadataObjects.count>0) {
		//播放扫描二维码的声音
		if (_enabledMusic) {
			SystemSoundID soundID;
			NSString *strSoundFile = [[NSBundle mainBundle] pathForResource:@"noticeMusic" ofType:@"mp3"];
			AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
			AudioServicesPlaySystemSound(soundID);
		}
		//输出扫描字符串
		AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
		NSString *result = metadataObject.stringValue;
		[self ScanCompletion:result];
	}
}

- (void)ScanCompletion:(NSString*)result{
	[self QRCodeReaderScanResult:result];
	if (_scanResult) _scanResult(self, result);
	if (_delegate && [_delegate respondsToSelector:@selector(QRCodeReader:scanResult:)]) {
		[_delegate QRCodeReader:self scanResult:result];
	}
}

- (void)QRCodeReaderScanResult:(NSString *)result{
	/* Subclasses should override */
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) {
		self.view = nil;
	}
}

@end
