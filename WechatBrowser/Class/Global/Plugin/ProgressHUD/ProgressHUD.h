//
// Copyright (c) 2013 Related Code - http://relatedcode.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

@interface hudBar : UIToolbar
@end

@interface ProgressHUD : UIView
@property (atomic,strong) UIWindow *window;
@property (atomic,strong) UIView *bg;
@property (atomic,strong) hudBar *hud;
@property (atomic,strong) UIColor *hudColor;
@property (atomic,strong) UIActivityIndicatorView *spinner;
@property (atomic,strong) UIColor *spinnerColor;
@property (atomic,strong) UIImageView *image;
@property (atomic,strong) UIImage *successImage;
@property (atomic,strong) UIImage *errorImage;
@property (atomic,strong) UILabel *label;
@property (atomic,strong) UIColor *textColor;
@property (atomic,strong) UIFont *textFont;
@property (atomic,assign) BOOL hiding;
@property (nonatomic,assign) BOOL hiddenBg;
+ (ProgressHUD*)shared;
+ (void)dismiss;
+ (void)dismiss:(NSTimeInterval)delay;
+ (void)show:(NSString*)status;
+ (void)show:(NSString*)status image:(UIImage*)image imageSize:(CGSize)imageSize;
+ (void)showNormal:(NSString*)status;
+ (void)showSuccess:(NSString*)status;
+ (void)showError:(NSString*)status;
+ (void)showTrouble:(NSString*)status;
+ (void)showWarning:(NSString*)status;
+ (void)showProgress:(double)totalCount completed:(double)completed;
+ (BOOL)isShowing;
+ (void)hiddenBg:(BOOL)hidden;
@end
