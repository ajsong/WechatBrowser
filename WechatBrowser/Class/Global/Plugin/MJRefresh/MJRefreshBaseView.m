//
//  MJRefreshBaseView.m
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <objc/message.h>
#import "MJRefreshConst.h"
#import "MJRefreshBaseView.h"
#import "UIView+MJRefreshExtension.h"
#import "UIScrollView+MJRefreshExtension.h"
#import "UIBezierPath+ZRCovertString.h"

@interface  MJRefreshBaseView()
{
	__weak UILabel *_statusLabel;
	__weak UIImageView *_arrowImage;
	__weak UIActivityIndicatorView *_activityView;
	__weak UIImageView *_imagesView;
	__weak GIFImageView *_gifView;
	__weak GIFImageView *_animatedView;

	NSMutableArray *_subPaths;
	CAShapeLayer *_animationLayer;
	NSMutableArray<CAShapeLayer *> *_dropLayers;
	UIBezierPath *_textPath;
	CAAnimation *_pullingAnimation;
	CAAnimation *_refreshingAnimation;
	float _startSpeed;
}
@end

@implementation MJRefreshBaseView

#pragma mark - 控件初始化
/**
 *  状态标签
 */
- (UILabel *)statusLabel
{
	if (!_statusLabel) {
		UILabel *statusLabel = [[UILabel alloc] init];
		statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		statusLabel.font = FONTBOLD(13);
		statusLabel.textColor = MJRefreshsLabelTextColor;
		statusLabel.textAlignment = NSTextAlignmentCenter;
		statusLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_statusLabel = statusLabel];
		[self sendSubviewToBack:_statusLabel];

		if (self.images) _statusLabel.hidden = YES;
	}
	return _statusLabel;
}

/**
 *  箭头图片
 */
- (UIImageView *)arrowImage
{
	if (!_arrowImage) {
		UIImageView *arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 22*SCREEN_SCALE, 22*SCREEN_SCALE)];
		arrowImage.image = [UIImage imageNamed:MJRefreshArrowImageName];
		arrowImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[self addSubview:_arrowImage = arrowImage];

		if (self.images) _arrowImage.hidden = YES;
	}
	return _arrowImage;
}

/**
 *  设定箭头图片
 */
- (void)setArrowImageName:(NSString *)arrowImageName
{
	_arrowImage.image = [UIImage imageNamed:arrowImageName];
	_arrowImageName = arrowImageName;
}

/**
 *  状态标签
 */
- (UIActivityIndicatorView *)activityView
{
	if (!_activityView) {
		UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		activityView.bounds = self.arrowImage.bounds;
		activityView.autoresizingMask = self.arrowImage.autoresizingMask;
		[self addSubview:_activityView = activityView];

		if (self.images) _activityView.hidden = YES;
	}
	return _activityView;
}

- (UIImageView*)imagesView{
	if (!self.images) return nil;
	if (!_imagesView) {
		CGRect frame = CGRectMake((self.frame.size.width-self.imagesSize.width)/2+self.imagesOffset.horizontal,
								  (self.frame.size.height-self.imagesSize.height)/2+self.imagesOffset.vertical,
								  self.imagesSize.width, self.imagesSize.height);
		UIImageView *imagesView = [[UIImageView alloc]initWithFrame:frame];
		[self addSubview:_imagesView = imagesView];
	}
	return _imagesView;
}

- (GIFImageView*)gifView{
	if (!_imagesView || !_gif) return nil;
	if (!_gifView) {
		GIFImageView *gifView = [[GIFImageView alloc]initWithFrame:_imagesView.frame];
		gifView.image = _gif;
		gifView.hidden = YES;
		[self addSubview:_gifView = gifView];
	}
	return _gifView;
}

#pragma mark - 初始化方法
+ (MJRefreshBaseView *)createWithFrame:(CGRect)frame subviews:(void (^)(MJRefreshBaseView *))subviews changeState:(void (^)(MJRefreshStates, id))changeState{
	MJRefreshBaseView *baseView = [[MJRefreshBaseView alloc]initWithFrame:frame];
	if (subviews) subviews(baseView);
	if (changeState) baseView.changeState = changeState;
	return baseView;
}

- (instancetype)initWithFrame:(CGRect)frame {
	if (!frame.size.height) frame.size.height = MJRefreshViewHeight;
	if (self = [super initWithFrame:frame]) {
		// 1.自己的属性
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor clearColor];

		// 2.设置默认状态
		_state = MJRefreshStatesNormal;

		self.imagesSize = CGSizeMake(16.f*SCREEN_SCALE, 16.f*SCREEN_SCALE);

		_text = MJREFRESH_WRITE_TEXT.length ? [MJREFRESH_WRITE_TEXT uppercaseString] : @"Loading";
		_textFont = MJREFRESH_WRITE_FONT;
		_textColor = [COLORMAIN setAlpha:0.5];
		_refresingLineColor = COLORMAIN;
		_startSpeed = 10;
		_animationLayer = [CAShapeLayer layer];
		_animationLayer.bounds = self.bounds;
		_animationLayer.position = self.center;
		_animationLayer.strokeColor = _refresingLineColor.CGColor;
		_animationLayer.fillColor = [UIColor clearColor].CGColor;
		_animationLayer.lineJoin = kCALineJoinRound;
		_animationLayer.lineCap = kCALineCapRound;
		_animationLayer.lineWidth = 1;
		_animationLayer.strokeStart = 0;
		_animationLayer.strokeEnd = 0;
		[self.layer addSublayer:_animationLayer];

		_indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		_indicatorView.frame = CGRectMake(0, 0, 20, 20);
		_indicatorView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
		_indicatorView.hidesWhenStopped = YES;
		[self addSubview:_indicatorView];
		[_indicatorView startAnimating];
	}
	return self;
}

- (void)setLoadingType:(MJRefreshLoadingType)loadingType{
	_loadingType = loadingType;
	switch (loadingType) {
		case MJRefreshLoadingTypeNormal:{
			self.layer.geometryFlipped = NO;
			_animationLayer.hidden = YES;
			[_indicatorView stopAnimating];
			break;
		}
		case MJRefreshLoadingTypeWrite:{
			self.layer.geometryFlipped = YES;
			_animationLayer.hidden = NO;
			[_indicatorView stopAnimating];
			break;
		}
		case MJRefreshLoadingTypeActivity:{
			self.layer.geometryFlipped = NO;
			_animationLayer.hidden = YES;
			[_indicatorView startAnimating];
			break;
		}
		default:{
			self.layer.geometryFlipped = NO;
			_animationLayer.hidden = YES;
			[_indicatorView stopAnimating];
			break;
		}
	}
}

- (void)configPath{
	_textPath = [UIBezierPath bezierPathWithCovertedString:_text attrinbutes:@{NSFontAttributeName:_textFont}];
	_animationLayer.path = _textPath.CGPath;

	if (_dropLayers) {
		[_dropLayers enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			[obj removeFromSuperlayer];
		}];
		[_dropLayers removeAllObjects];
	}else{
		_dropLayers = [NSMutableArray array];
	}
	_subPaths = [_textPath subpath];
	[_subPaths enumerateObjectsUsingBlock:^(UIBezierPath *obj, NSUInteger idx, BOOL * _Nonnull stop) {
		CAShapeLayer *dropLayer = [self dropAnimationLayerWithPath:obj];
		[self.layer addSublayer:dropLayer];
		[_dropLayers addObject:dropLayer];
	}];
	[self placeLayer];
	[_animationLayer removeFromSuperlayer];
	[self.layer addSublayer:_animationLayer];
}

//对layar布局
- (void)placeLayer{
	if (!_textPath) return;
	CGRect stringBounds = _textPath.bounds;
	CGFloat paddingX = (self.bounds.size.width - stringBounds.size.width) / 2;
	CGFloat paddingY = (self.bounds.size.height - stringBounds.size.height) / 2;
	CGRect layerFrame = CGRectMake(paddingX, paddingY, stringBounds.size.width, stringBounds.size.height);
	_animationLayer.frame = layerFrame;
	[_dropLayers enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		obj.frame = layerFrame;
	}];
}
//刷新文字
- (void)reloadPath{
	if (self.superview) {
		[self configPath];
	}
}
- (void)executeDropAnimationWithProgresss:(CGFloat)progress{
	NSInteger count = _dropLayers.count - 1;
	[_dropLayers enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		//控制动画完成速率，保证动画逐步完成
		CGFloat timeOffset = progress * (count * 2 - idx) / count;
		timeOffset = MIN(timeOffset, 1);
		obj.timeOffset = timeOffset;
	}];
}
- (void)executeRefreshAnimaiton{
	[_animationLayer addAnimation:[self refreshingAnimation] forKey:nil];
}
- (CAShapeLayer *)dropAnimationLayerWithPath: (UIBezierPath *)path {
	CAShapeLayer *dropLayer = [CAShapeLayer layer];
	dropLayer.strokeColor = _textColor.CGColor;
	dropLayer.fillColor = [UIColor clearColor].CGColor;
	dropLayer.lineJoin = kCALineJoinRound;
	dropLayer.lineCap = kCALineCapRound;
	dropLayer.lineWidth = 1;
	dropLayer.speed = _startSpeed;
	dropLayer.path = path.CGPath;
	[dropLayer addAnimation:[self pullingAnimation] forKey:nil];
	return dropLayer;
}
- (CAAnimation *)pullingAnimation{
	CGFloat randomness = 150.f;
	CGFloat viewHeight = self.frame.size.height;
	CGFloat translationX = arc4random_uniform(randomness) * 3 - randomness;
	CABasicAnimation *translation = [CABasicAnimation animationWithKeyPath:@"transform"];
	translation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
	translation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(translationX, viewHeight/2, 0)];

	CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
	rotationAnimation.toValue = @(0);
	rotationAnimation.fromValue = @(M_PI_4);

	CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
	scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1)];

	NSMutableArray *animations = [NSMutableArray arrayWithObjects:translation,rotationAnimation,scaleAnimation, nil];
	CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
	animationGroup.animations = animations;
	animationGroup.duration = 1;
	_pullingAnimation = animationGroup;

	return _pullingAnimation;
}
- (CAAnimation *)refreshingAnimation{
	_refreshingAnimation = [self refreshingWormlike];
	_refreshingAnimation.repeatCount = HUGE_VALF;
	_refreshingAnimation.duration = 1.f;
	_refreshingAnimation.autoreverses = YES;
	return _refreshingAnimation;
}
- (CAAnimation *)refreshingWormlike{
	CABasicAnimation *endAnimaiton = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
	endAnimaiton.fromValue = @0;
	endAnimaiton.toValue = @1;

	CABasicAnimation *startAnimaiton = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
	startAnimaiton.fromValue = @0;
	startAnimaiton.toValue = @1;
	startAnimaiton.beginTime = 0.2;

	CAAnimationGroup *group = [CAAnimationGroup animation];
	group.animations = @[endAnimaiton,startAnimaiton];
	return group;
}
- (void)setPullingProgress:(CGFloat)pullingProgress{
	if (_pullingProgress != pullingProgress) {
		_pullingProgress = pullingProgress;
		[self executeDropAnimationWithProgresss:pullingProgress];
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	switch (_loadingType) {
		case MJRefreshLoadingTypeNormal:{
			// 1.箭头
			CGFloat arrowX = self.mj_width * 0.5 - 100*SCREEN_SCALE;
			self.arrowImage.center = CGPointMake(arrowX, self.mj_height * 0.5);
			// 2.指示器
			self.activityView.center = self.arrowImage.center;
			break;
		}
		case MJRefreshLoadingTypeWrite:{
			[self placeLayer];
			break;
		}
		case MJRefreshLoadingTypeActivity:{

			break;
		}
		default:{

			break;
		}
	}
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
	[super willMoveToSuperview:newSuperview];

	// 旧的父控件
	_scrollViewOriginalInset = ((UIScrollView*)self.superview).contentInset;
	if (isX && _scrollViewOriginalInset.bottom>0) {
		UIEdgeInsets insets = _scrollViewOriginalInset;
		insets.bottom -= 34;
		_scrollViewOriginalInset = insets;
	}
	[self.superview removeObserver:self forKeyPath:MJRefreshContentOffset context:nil];

	if (newSuperview) { // 新的父控件
		[newSuperview addObserver:self forKeyPath:MJRefreshContentOffset options:NSKeyValueObservingOptionNew context:nil];

		// 设置宽度
		self.mj_width = newSuperview.mj_width;
		// 设置位置
		self.mj_x = 0;

		// 记录UIScrollView
		_scrollView = (UIScrollView *)newSuperview;
		// 记录UIScrollView最开始的contentInset
		_scrollViewOriginalInset = _scrollView.contentInset;

		switch (_loadingType) {
			case MJRefreshLoadingTypeWrite:{
				[self configPath];
				break;
			}
			case MJRefreshLoadingTypeActivity:{
				_indicatorView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
				break;
			}
			default:{

				break;
			}
		}
	}
}

#pragma mark - 显示到屏幕上
- (void)drawRect:(CGRect)rect
{
	if (self.state == MJRefreshStatesWillRefreshing) {
		self.state = MJRefreshStatesRefreshing;
	}
}

#pragma mark - 按状态显示提示图片
- (void)setImage:(UIImage *)image forState:(MJRefreshStates)state{
	self.loadingType = MJRefreshLoadingTypeWrite;
	if (!image) return;
	if (!_animatedView) {
		CGRect frame = CGRectMake((self.frame.size.width-self.imagesSize.width)/2+self.imagesOffset.horizontal,
								  (self.frame.size.height-self.imagesSize.height)/2+self.imagesOffset.vertical,
								  self.imagesSize.width, self.imagesSize.height);
		GIFImageView *imagesView = [[GIFImageView alloc]initWithFrame:frame];
		[self addSubview:_animatedView = imagesView];
	}
}

#pragma mark - 刷新相关
#pragma mark 是否正在刷新
- (BOOL)isRefreshing
{
	return MJRefreshStatesRefreshing == self.state || MJRefreshStatesWillRefreshing == self.state;
}

#pragma mark 开始刷新
typedef void (*send_type)(void *, SEL, UIView *);
- (void)beginRefreshing
{
	if ([self isRefreshing]) return;
	if (self.state == MJRefreshStatesRefreshing) {
		// 回调
		if ([self.beginRefreshingTaget respondsToSelector:self.beginRefreshingAction]) {
			msgSend((__bridge void *)(self.beginRefreshingTaget), self.beginRefreshingAction, self);
		}

		if (self.beginRefreshingCallback) {
			self.beginRefreshingCallback();
		}
	} else {
		if (self.window) {
			self.state = MJRefreshStatesRefreshing;
		} else {
			//不能调用set方法
			_state = MJRefreshStatesWillRefreshing;
			[super setNeedsDisplay];
		}
	}
}

#pragma mark 结束刷新
- (void)endRefreshing
{
	if (![self isRefreshing]) return;
	double delayInSeconds = 0.3;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		self.state = MJRefreshStatesNormal;
	});
}

#pragma mark - 设置状态
- (void)setPullToRefreshText:(NSString *)pullToRefreshText
{
	_pullToRefreshText = [pullToRefreshText copy];
	[self settingLabelText];
}
- (void)setReleaseToRefreshText:(NSString *)releaseToRefreshText
{
	_releaseToRefreshText = [releaseToRefreshText copy];
	[self settingLabelText];
}
- (void)setRefreshingText:(NSString *)refreshingText
{
	_refreshingText = [refreshingText copy];
	[self settingLabelText];
}
- (void)settingLabelText
{
	if (self.loadingType==MJRefreshLoadingTypeWrite) return;
	switch (self.state) {
		case MJRefreshStatesNormal:
			// 设置文字
			self.statusLabel.text = self.pullToRefreshText;
			break;
		case MJRefreshStatesPulling:
			// 设置文字
			self.statusLabel.text = self.releaseToRefreshText;
			break;
		case MJRefreshStatesRefreshing:
			// 设置文字
			self.statusLabel.text = self.refreshingText;
			break;
		default:
			break;
	}
}

- (void)setState:(MJRefreshStates)state
{
	// 0.存储当前的contentInset
	if (self.state != MJRefreshStatesRefreshing) {
		_scrollViewOriginalInset = self.scrollView.contentInset;
	}

	// 1.一样的就直接返回(暂时不返回)
	if (self.state == state) return;

	if (self.changeState) self.changeState(state, self);

	// 2.根据状态执行不同的操作
	switch (state) {
		case MJRefreshStatesNormal: // 普通状态
		{
			if (self.state == MJRefreshStatesRefreshing) {
				[UIView animateWithDuration:MJRefreshsSlowAnimationDuration * 0.6 animations:^{
					switch (_loadingType) {
						case MJRefreshLoadingTypeNormal:{
							self.activityView.alpha = 0.0;
							break;
						}
						default:{
							//[_indicatorView stopAnimating];
							break;
						}
					}
				} completion:^(BOOL finished) {
					switch (_loadingType) {
						case MJRefreshLoadingTypeNormal:{
							// 停止转圈圈
							[self.activityView stopAnimating];
							// 恢复alpha
							self.activityView.alpha = 1.0;
							break;
						}
						default:{

							break;
						}
					}

					// 动画停止后执行
					if ([self.didEndRefreshTaget respondsToSelector:self.didEndRefreshAction]) {
						objc_msgSend(self.didEndRefreshTaget, self.didEndRefreshAction, self);
					}

					if (self.didEndRefreshCallback) {
						self.didEndRefreshCallback();
					}
				}];
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MJRefreshsSlowAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
					// 再次设置回normal
					_state = MJRefreshStatesPulling;
					self.state = MJRefreshStatesNormal;

					switch (_loadingType) {
						case MJRefreshLoadingTypeWrite:{
							[_animationLayer removeAllAnimations];
							if (_startSpeed>0) {
								_startSpeed = 0;
								[_dropLayers enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
									[obj removeFromSuperlayer];
								}];
								[_dropLayers removeAllObjects];
								[_subPaths enumerateObjectsUsingBlock:^(UIBezierPath *obj, NSUInteger idx, BOOL * _Nonnull stop) {
									CAShapeLayer *dropLayer = [self dropAnimationLayerWithPath:obj];
									[self.layer addSublayer:dropLayer];
									[_dropLayers addObject:dropLayer];
								}];
								[self placeLayer];
								[_animationLayer removeFromSuperlayer];
								[self.layer addSublayer:_animationLayer];
							}
							return;
							break;
						}
						default:{

							break;
						}
					}
					if (self.images) {
						if (self.gif) {
							self.imagesView.hidden = NO;
							self.gifView.hidden = YES;
						} else {
							[self.imagesView stopAnimating];
							self.imagesView.animationImages = nil;
						}
					}
				});
				// 直接返回
				return;
			} else {
				switch (_loadingType) {
					case MJRefreshLoadingTypeNormal:{
						// 显示箭头
						if (!self.images) self.arrowImage.hidden = NO;
						// 停止转圈圈
						[self.activityView stopAnimating];
						break;
					}
					default:{

						break;
					}
				}
			}
			break;
		}

		case MJRefreshStatesPulling:
			break;

		case MJRefreshStatesRefreshing:
		{
			switch (_loadingType) {
				case MJRefreshLoadingTypeNormal:{
					// 隐藏箭头
					self.arrowImage.hidden = YES;
					// 开始转圈圈
					if (!self.images) [self.activityView startAnimating];
					break;
				}
				case MJRefreshLoadingTypeWrite:{
					[self executeRefreshAnimaiton];
					break;
				}
				case MJRefreshLoadingTypeActivity:{

					break;
				}
				default:{

					break;
				}
			}

			// 回调
			if ([self.beginRefreshingTaget respondsToSelector:self.beginRefreshingAction]) {
				objc_msgSend(self.beginRefreshingTaget, self.beginRefreshingAction, self);
			}

			if (self.beginRefreshingCallback) {
				self.beginRefreshingCallback();
			}
			break;
		}

		default:
			break;
	}

	// 3.存储状态
	_state = state;

	switch (_loadingType) {
		case MJRefreshLoadingTypeNormal:{
			// 4.设置文字
			[self settingLabelText];
			break;
		}
		default:{

			break;
		}
	}
}

@end
