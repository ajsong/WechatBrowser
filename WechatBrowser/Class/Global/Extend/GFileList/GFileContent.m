//
//  GFileContent.m
//
//  Created by ajsong on 15/6/30.
//  Copyright (c) 2014 @jsong. All rights reserved.
//

#import "GFileContent.h"

@interface GFileContent ()

@end

@implementation GFileContent

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = COLORWHITE;
	self.edgesForExtendedLayout = UIRectEdgeNone;
	
	UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
	[self.view addSubview:scrollView];
	
	NSData *data = [Global getFileData:_filePath];
	if ([data isImage]) {
		if (!self.title.length) self.title = @"图片";
		UIImage *image = [UIImage imageWithData:data];
		image = [image fitToSize:CGSizeMake(SCREEN_WIDTH, self.height)];
		if ([data isGIF]) {
			GIFImageView *imageView = [[GIFImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-image.size.width)/2, (self.height-image.size.height)/2, image.size.width, image.size.height)];
			imageView.image = [GIFImage imageWithData:data];
			[scrollView addSubview:imageView];
			[imageView longClickInTarget:self action:^(id target, UIView *sender, UIGestureRecognizer *recognizer) {
				UIImageWriteToSavedPhotosAlbum(imageView.image, target, @selector(image:didFinishSavingWithError:contextInfo:), nil);
			}];
		} else {
			UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-image.size.width)/2, (self.height-image.size.height)/2, image.size.width, image.size.height)];
			imageView.image = image;
			[scrollView addSubview:imageView];
			[imageView longClickInTarget:self action:^(id target, UIView *sender, UIGestureRecognizer *recognizer) {
				UIImageWriteToSavedPhotosAlbum(imageView.image, target, @selector(image:didFinishSavingWithError:contextInfo:), nil);
			}];
		}
	} else {
		if (!self.title.length) self.title = @"内容";
		UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.height)];
		textView.text = [[_filePath getSuffix]isEqualToString:@"plist"] ? [[Global getPlistDictionary:_filePath]jsonString:NSJSONWritingPrettyPrinted] : [Global getFileText:_filePath];
		textView.textColor = [UIColor blackColor];
		textView.font = FONT(13);
		textView.backgroundColor = [UIColor clearColor];
		[scrollView addSubview:textView];
		KKNavigationBarItem *item = [self.navigationItem setItemWithTitle:@"保存" textColor:COLORNAVTEXT fontSize:14 itemType:KKNavigationItemTypeRight];
		[item addTarget:self action:^(id target, id sender) {
			if ([[_filePath getSuffix]isEqualToString:@"plist"]) {
				[Global savePlist:_filePath data:textView.text.jsonValue];
			} else {
				[Global saveFile:_filePath content:textView.text new:NO];
			}
			[[target view] endEditing:YES];
			[ProgressHUD showSuccess:@"已保存"];
			[[target navigationController] popViewControllerAnimated:YES];
		}];
	}
}

- (void)image:(UIImage*)image didFinishSavingWithError:(NSError *)error contextInfo:(void*)contextInfo{
	if (error) {
		[ProgressHUD showError:@"保存失败"];
	} else {
		[ProgressHUD showSuccess:@"保存成功"];
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	if (self.view.window==nil) {
		self.view = nil;
	}
}

@end
