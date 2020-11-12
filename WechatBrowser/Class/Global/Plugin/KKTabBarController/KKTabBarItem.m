// KKTabBarItem.h
// KKTabBarController
//
// Copyright (c) 2013 Robert Dimitrov
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

#import "KKTabBarItem.h"

@interface KKTabBarItem () {
    NSString *_title;
    UIOffset _imagePositionAdjustment;
    NSDictionary *_unselectedTitleAttributes;
    NSDictionary *_selectedTitleAttributes;
	UIImageView *_badgeBackgroundImageView;
}

@property UIImage *unselectedBackgroundImage;
@property UIImage *selectedBackgroundImage;
@property UIImage *unselectedImage;
@property UIImage *selectedImage;

@end

@implementation KKTabBarItem

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (void)commonInitialization {
    // Setup defaults
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    _title = @"";
    _titlePositionAdjustment = UIOffsetZero;
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        _unselectedTitleAttributes = @{
                                       NSFontAttributeName: [UIFont systemFontOfSize:12],
                                       NSForegroundColorAttributeName: [UIColor blackColor],
                                       };
    } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
        _unselectedTitleAttributes = @{
                                       UITextAttributeFont: [UIFont systemFontOfSize:12],
                                       UITextAttributeTextColor: [UIColor blackColor],
                                       };
#endif
    }
    
    _selectedTitleAttributes = [_unselectedTitleAttributes copy];
    _badgeBackgroundColor = [UIColor redColor];
    _badgeTextColor = [UIColor whiteColor];
    _badgeTextFont = FONT(11);
	_badgeHeight = 16*SCREEN_SCALE;
    _badgePositionAdjustment = UIOffsetMake(3*SCREEN_SCALE, 3*SCREEN_SCALE);
}

- (void)drawRect:(CGRect)rect {
    CGSize frameSize = self.frame.size;
    CGSize imageSize = CGSizeZero;
    CGSize titleSize = CGSizeZero;
    NSDictionary *titleAttributes = nil;
    UIImage *backgroundImage = nil;
    UIImage *image = nil;
	CGFloat imageStartingY = 0.0f;
	CGFloat titleStartingY = 0.0f;
	
    if ([self isSelected]) {
        image = [self selectedImage];
        backgroundImage = [self selectedBackgroundImage];
        titleAttributes = [self selectedTitleAttributes];
        
        if (!titleAttributes) {
            titleAttributes = [self unselectedTitleAttributes];
        }
    } else {
        image = [self unselectedImage];
        backgroundImage = [self unselectedBackgroundImage];
        titleAttributes = [self unselectedTitleAttributes];
    }
	
	imageSize = [image size];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    [backgroundImage drawInRect:self.bounds];
    
    // Draw image and title
    if (![_title length]) {
		
		CGFloat itemHeight = self.itemHeight;
		if (!itemHeight) itemHeight = frameSize.height;
		imageSize.width = itemHeight * imageSize.width / imageSize.height;
		imageSize.height = itemHeight;
		
		if (image) {
			[image drawInRect:CGRectMake(roundf(frameSize.width / 2 - imageSize.width / 2) +
										 _imagePositionAdjustment.horizontal,
										 roundf(frameSize.height / 2 - imageSize.height / 2) +
										 _imagePositionAdjustment.vertical,
										 imageSize.width, imageSize.height)];
		}
    } else {
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
			NSDictionary *fontDic = nil;
			UIColor *fontColor = [UIColor blackColor];
			if (titleAttributes.isDictionary) {
				if (titleAttributes[NSFontAttributeName]) {
					fontDic = @{NSFontAttributeName: titleAttributes[NSFontAttributeName]};
				}
				if (titleAttributes[NSForegroundColorAttributeName]) {
					fontColor = titleAttributes[NSForegroundColorAttributeName];
				}
			}
			
            titleSize = [_title boundingRectWithSize:CGSizeMake(frameSize.width, 20)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:fontDic
                                                    context:nil].size;
			
			if (image) {
				imageStartingY = roundf((frameSize.height - imageSize.height - titleSize.height) / 2);
				
				[image drawInRect:CGRectMake(roundf(frameSize.width / 2 - imageSize.width / 2) +
											 _imagePositionAdjustment.horizontal,
											 imageStartingY + _imagePositionAdjustment.vertical,
											 imageSize.width, imageSize.height)];
				
				titleStartingY = imageStartingY + imageSize.height + _titlePositionAdjustment.vertical;
			} else {
				//imageSize = CGSizeZero;
				titleStartingY = roundf(frameSize.height / 2 - titleSize.height / 2) + _titlePositionAdjustment.vertical;
			}
			
            CGContextSetFillColorWithColor(context, [fontColor CGColor]);
			
            [_title drawInRect:CGRectMake(roundf(frameSize.width / 2 - titleSize.width / 2) + _titlePositionAdjustment.horizontal,
                                          titleStartingY, titleSize.width, titleSize.height)
                withAttributes:titleAttributes];
        } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            titleSize = [_title sizeWithFont:titleAttributes[UITextAttributeFont]
                                  constrainedToSize:CGSizeMake(frameSize.width, 20)];
            UIOffset titleShadowOffset = [titleAttributes[UITextAttributeTextShadowOffset] UIOffsetValue];
            imageStartingY = roundf((frameSize.height - imageSize.height - titleSize.height) / 2);
            
            [image drawInRect:CGRectMake(roundf(frameSize.width / 2 - imageSize.width / 2) +
                                         _imagePositionAdjustment.horizontal,
                                         imageStartingY + _imagePositionAdjustment.vertical,
                                         imageSize.width, imageSize.height)];
            
            CGContextSetFillColorWithColor(context, [titleAttributes[UITextAttributeTextColor] CGColor]);
            
            UIColor *shadowColor = titleAttributes[UITextAttributeTextShadowColor];
            
            if (shadowColor) {
                CGContextSetShadowWithColor(context, CGSizeMake(titleShadowOffset.horizontal, titleShadowOffset.vertical),
                                            1.0, [shadowColor CGColor]);
            }
            
            [_title drawInRect:CGRectMake(roundf(frameSize.width / 2 - titleSize.width / 2) +
                                          _titlePositionAdjustment.horizontal,
                                          imageStartingY + imageSize.height + _titlePositionAdjustment.vertical,
                                          titleSize.width, titleSize.height)
                      withFont:titleAttributes[UITextAttributeFont]
                 lineBreakMode:NSLineBreakByTruncatingTail];
#endif
        }
    }
    
	// Draw badges
	if (_badge) [_badge removeFromSuperview];
	if (_badgeBackgroundImageView) [_badgeBackgroundImageView removeFromSuperview];
	
    if ([[self badgeValue] length]) {
		
        CGSize badgeSize = CGSizeZero;
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            badgeSize = [_badgeValue boundingRectWithSize:CGSizeMake(frameSize.width, _badgeHeight)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:[self badgeTextFont]}
                                                  context:nil].size;
        } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            badgeSize = [_badgeValue sizeWithFont:[self badgeTextFont]
                                constrainedToSize:CGSizeMake(frameSize.width, _badgeHeight)];
#endif
        }
        
		CGFloat textOffset = _badgeValue.length==1 ? (_badgeHeight - badgeSize.width) / 2 : 5.f;
		CGFloat badgeWidth = badgeSize.width + textOffset * 2;
		
		if (badgeWidth < _badgeHeight) badgeWidth = _badgeHeight;
		if (_badgeHeight <= 10 && badgeWidth > _badgeHeight) badgeWidth = _badgeHeight;
		badgeSize = CGSizeMake(badgeWidth, _badgeHeight);
        if (badgeSize.width < badgeSize.height) {
            badgeSize = CGSizeMake(badgeSize.height, badgeSize.height);
        }
        
        CGRect badgeBackgroundFrame = CGRectMake(roundf( (frameSize.width - badgeSize.width) / 2 + (badgeSize.width / 2) ) +
                                                 _badgePositionAdjustment.horizontal, _badgePositionAdjustment.vertical,
                                                 badgeSize.width, badgeSize.height);
		if (badgeBackgroundFrame.origin.x + badgeBackgroundFrame.size.width > frameSize.width) {
			badgeBackgroundFrame.origin.x = frameSize.width - badgeBackgroundFrame.size.width - 2;
		}
		
		_badge = [[UILabel alloc]initWithFrame:badgeBackgroundFrame];
		_badge.text = [self badgeValue];
		_badge.textColor = [self badgeTextColor];
		_badge.textAlignment = NSTextAlignmentCenter;
		_badge.font = [self badgeTextFont];
		_badge.backgroundColor = [UIColor clearColor];
		[self addSubview:_badge];
		
		if ([self badgeBackgroundImage]) {
			UIImage *backgroundImage = [self badgeBackgroundImage];
			badgeBackgroundFrame = CGRectMake(badgeBackgroundFrame.origin.x + roundf( (badgeBackgroundFrame.size.width - backgroundImage.size.width) / 2 ),
											  badgeBackgroundFrame.origin.y + roundf( (badgeBackgroundFrame.size.height - backgroundImage.size.height) / 2 ),
											  backgroundImage.size.width, backgroundImage.size.height);
			_badgeBackgroundImageView = [[UIImageView alloc]initWithFrame:badgeBackgroundFrame];
			_badgeBackgroundImageView.image = backgroundImage;
			[self addSubview:_badgeBackgroundImageView];
			[self bringSubviewToFront:_badge];
		} else if ([self badgeBackgroundColor]) {
			_badge.backgroundColor = [self badgeBackgroundColor];
			_badge.layer.masksToBounds = YES;
			_badge.layer.cornerRadius = badgeBackgroundFrame.size.height / 2;
        }
    }
    
    CGContextRestoreGState(context);
}

#pragma mark - Image configuration

- (UIImage *)finishedSelectedImage {
    return [self selectedImage];
}

- (UIImage *)finishedUnselectedImage {
    return [self unselectedImage];
}

- (void)setImage:(UIImage *)unselectedImage withSelectedImage:(UIImage *)selectedImage {
	if (selectedImage && (selectedImage != [self selectedImage])) {
		[self setSelectedImage:selectedImage];
	}
	
	if (unselectedImage && (unselectedImage != [self unselectedImage])) {
		[self setUnselectedImage:unselectedImage];
	}
}

- (void)setImageUrl:(NSString *)unselectedImageUrl withSelectedImageUrl:(NSString *)selectedImageUrl {
	[@[unselectedImageUrl, selectedImageUrl] loadImageAndCompletion:^(NSArray *images) {
		if (images.isArray && images.count>1) {
			if ([images[0] isKindOfClass:[UIImage class]]) [self setUnselectedImage:images[0]];
			if ([images[1] isKindOfClass:[UIImage class]]) [self setSelectedImage:images[1]];
			[self setNeedsDisplay];
		}
	}];
}

- (void)setBadgeValue:(NSString *)badgeValue {
    _badgeValue = badgeValue;
    
    [self setNeedsDisplay];
}

#pragma mark - Background configuration

- (UIImage *)backgroundSelectedImage {
    return [self selectedBackgroundImage];
}

- (UIImage *)backgroundUnselectedImage {
    return [self unselectedBackgroundImage];
}

- (void)setBackgroundImage:(UIImage *)selectedImage withSelectedImage:(UIImage *)unselectedImage {
    if (selectedImage && (selectedImage != [self selectedBackgroundImage])) {
        [self setSelectedBackgroundImage:selectedImage];
    }
    
    if (unselectedImage && (unselectedImage != [self unselectedBackgroundImage])) {
        [self setUnselectedBackgroundImage:unselectedImage];
    }
}

- (void)setBackgroundUnselectedColor:(UIColor *)backgroundUnselectedColor{
	[self setBackgroundColor:backgroundUnselectedColor];
}

- (void)setSelected:(BOOL)selected{
	[super setSelected:selected];
	if (selected) {
		if ([self backgroundSelectedColor]) {
			[self setBackgroundColor:[self backgroundSelectedColor]];
		} else {
			[self setBackgroundColor:[UIColor clearColor]];
		}
	} else {
		if ([self backgroundUnselectedColor]) {
			[self setBackgroundColor:[self backgroundUnselectedColor]];
		} else {
			[self setBackgroundColor:[UIColor clearColor]];
		}
	}
}

@end
